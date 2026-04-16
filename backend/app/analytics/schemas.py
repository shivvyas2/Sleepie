from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class SleepSummary(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    total_sessions: int = Field(alias="totalSessions")
    average_score_7d: float = Field(alias="averageScore7d")
    average_score_30d: float = Field(alias="averageScore30d")
    average_duration_minutes: float = Field(alias="averageDurationMinutes")
    best_score: int | None = Field(None, alias="bestScore")
    best_date: str | None = Field(None, alias="bestDate")
    worst_score: int | None = Field(None, alias="worstScore")
    worst_date: str | None = Field(None, alias="worstDate")


class DailyScore(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    date: str
    score: int | None
    duration_minutes: float = Field(alias="durationMinutes")


class TrendData(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    daily_scores: list[DailyScore] = Field(alias="dailyScores")
    rolling_average_7d: list[float] = Field(alias="rollingAverage7d")
    trend: str  # "improving", "declining", "stable"
