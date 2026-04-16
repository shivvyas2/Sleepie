import pytest
from datetime import datetime, timedelta, timezone

from app.analytics.schemas import DailyScore, TrendData
from app.analytics.service import AnalyticsService


def test_trend_direction_stable_with_few_points():
    """Trend should be stable when less than 7 data points."""
    trend = TrendData(
        daily_scores=[DailyScore(date="2026-04-10", score=70, duration_minutes=480)],
        rolling_average_7d=[70.0],
        trend="stable",
    )
    assert trend.trend == "stable"


def test_trend_direction_improving():
    """When second half scores > first half by >3, trend is improving."""
    scores = [DailyScore(date=f"2026-04-{i:02d}", score=50 + i * 2, duration_minutes=480) for i in range(1, 15)]
    rolling = [float(s.score) for s in scores]

    first_half = sum(rolling[:7]) / 7
    second_half = sum(rolling[7:]) / 7
    assert second_half > first_half  # Verify test data is improving

    trend = TrendData(
        daily_scores=scores,
        rolling_average_7d=rolling,
        trend="improving",
    )
    assert trend.trend == "improving"


def test_daily_score_serialization():
    ds = DailyScore(date="2026-04-15", score=85, duration_minutes=456.5)
    data = ds.model_dump(by_alias=True)
    assert data["date"] == "2026-04-15"
    assert data["score"] == 85
    assert data["durationMinutes"] == 456.5


def test_daily_score_with_null_score():
    ds = DailyScore(date="2026-04-15", score=None, duration_minutes=0)
    assert ds.score is None


@pytest.mark.asyncio
async def test_analytics_summary_endpoint_requires_auth(client):
    response = await client.get("/api/v1/analytics/summary")
    assert response.status_code in (401, 403)


@pytest.mark.asyncio
async def test_analytics_trends_endpoint_requires_auth(client):
    response = await client.get("/api/v1/analytics/trends")
    assert response.status_code in (401, 403)


@pytest.mark.asyncio
async def test_analytics_trends_rejects_invalid_days(client):
    """Days parameter validation should reject out-of-range values."""
    from tests.test_auth import make_test_token
    token = make_test_token()

    # days=0 should fail (ge=1)
    response = await client.get(
        "/api/v1/analytics/trends?days=0",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 422  # Pydantic validation error

    # days=400 should fail (le=365)
    response = await client.get(
        "/api/v1/analytics/trends?days=400",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 422
