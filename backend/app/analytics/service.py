from datetime import datetime, timedelta, timezone
from uuid import UUID

from supabase import Client

from app.analytics.schemas import DailyScore, SleepSummary, TrendData


class AnalyticsService:
    def __init__(self, supabase: Client):
        self.supabase = supabase

    async def get_summary(self, user_id: UUID) -> SleepSummary:
        result = (
            self.supabase.table("sleep_sessions")
            .select("*")
            .eq("user_id", str(user_id))
            .order("started_at", desc=True)
            .execute()
        )
        sessions = result.data or []

        if not sessions:
            return SleepSummary(
                total_sessions=0,
                average_score_7d=0,
                average_score_30d=0,
                average_duration_minutes=0,
            )

        now = datetime.now(timezone.utc)
        cutoff_7d = now - timedelta(days=7)
        cutoff_30d = now - timedelta(days=30)

        scored = [s for s in sessions if s.get("sleep_score") is not None]
        scored_7d = [s for s in scored if datetime.fromisoformat(s["started_at"]) >= cutoff_7d]
        scored_30d = [s for s in scored if datetime.fromisoformat(s["started_at"]) >= cutoff_30d]

        avg_7d = sum(s["sleep_score"] for s in scored_7d) / len(scored_7d) if scored_7d else 0
        avg_30d = sum(s["sleep_score"] for s in scored_30d) / len(scored_30d) if scored_30d else 0

        durations = []
        for s in sessions:
            if s.get("ended_at") and s.get("started_at"):
                start = datetime.fromisoformat(s["started_at"])
                end = datetime.fromisoformat(s["ended_at"])
                durations.append((end - start).total_seconds() / 60)
        avg_duration = sum(durations) / len(durations) if durations else 0

        best = max(scored, key=lambda s: s["sleep_score"]) if scored else None
        worst = min(scored, key=lambda s: s["sleep_score"]) if scored else None

        return SleepSummary(
            total_sessions=len(sessions),
            average_score_7d=round(avg_7d, 1),
            average_score_30d=round(avg_30d, 1),
            average_duration_minutes=round(avg_duration, 1),
            best_score=best["sleep_score"] if best else None,
            best_date=best["started_at"][:10] if best else None,
            worst_score=worst["sleep_score"] if worst else None,
            worst_date=worst["started_at"][:10] if worst else None,
        )

    async def get_trends(self, user_id: UUID, days: int = 30) -> TrendData:
        if days <= 0 or days > 365:
            raise ValueError("Days must be between 1 and 365")

        cutoff = datetime.now(timezone.utc) - timedelta(days=days)

        result = (
            self.supabase.table("sleep_sessions")
            .select("*")
            .eq("user_id", str(user_id))
            .gte("started_at", cutoff.isoformat())
            .order("started_at")
            .execute()
        )
        sessions = result.data or []

        # Group by date
        daily: dict[str, list[dict]] = {}
        for s in sessions:
            date_str = s["started_at"][:10]
            daily.setdefault(date_str, []).append(s)

        daily_scores: list[DailyScore] = []
        for date_str, day_sessions in sorted(daily.items()):
            scored = [s for s in day_sessions if s.get("sleep_score") is not None]
            avg_score = round(sum(s["sleep_score"] for s in scored) / len(scored)) if scored else None

            total_dur = 0.0
            for s in day_sessions:
                if s.get("ended_at") and s.get("started_at"):
                    start = datetime.fromisoformat(s["started_at"])
                    end = datetime.fromisoformat(s["ended_at"])
                    total_dur += (end - start).total_seconds() / 60

            daily_scores.append(DailyScore(
                date=date_str,
                score=avg_score,
                duration_minutes=round(total_dur, 1),
            ))

        # Rolling 7-day average
        rolling: list[float] = []
        scores_only = [d.score for d in daily_scores]
        for i in range(len(scores_only)):
            window = [s for s in scores_only[max(0, i - 6):i + 1] if s is not None]
            rolling.append(round(sum(window) / len(window), 1) if window else 0)

        # Trend direction
        if len(rolling) >= 7:
            first_half = sum(rolling[:len(rolling) // 2]) / max(len(rolling) // 2, 1)
            second_half = sum(rolling[len(rolling) // 2:]) / max(len(rolling) - len(rolling) // 2, 1)
            if second_half - first_half > 3:
                trend = "improving"
            elif first_half - second_half > 3:
                trend = "declining"
            else:
                trend = "stable"
        else:
            trend = "stable"

        return TrendData(
            daily_scores=daily_scores,
            rolling_average_7d=rolling,
            trend=trend,
        )
