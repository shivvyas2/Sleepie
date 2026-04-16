from app.sessions.schemas import SleepStage, SleepStageInterval


def compute_sleep_score(
    total_duration_minutes: float,
    stages: list[SleepStageInterval],
) -> int:
    """Compute a sleep score from 0-100 based on session data.

    Weighted formula:
    - Duration (30%): 7-9 hours is ideal
    - Deep+REM percentage (40%): higher is better
    - Sleep onset latency (15%): faster onset is better
    - Awakenings (15%): fewer is better
    """
    if total_duration_minutes <= 0:
        return 0

    # Duration score (0-100): 7-9 hours = 100, scale down outside that
    ideal_min, ideal_max = 420, 540  # 7-9 hours in minutes
    if ideal_min <= total_duration_minutes <= ideal_max:
        duration_score = 100.0
    elif total_duration_minutes < ideal_min:
        duration_score = max(0, (total_duration_minutes / ideal_min) * 100)
    else:
        overage = total_duration_minutes - ideal_max
        duration_score = max(0, 100 - (overage / 120) * 50)  # penalty for oversleeping

    # Stage distribution
    stage_minutes: dict[SleepStage, float] = {s: 0.0 for s in SleepStage}
    for interval in stages:
        if interval.ended_at and interval.started_at:
            minutes = (interval.ended_at - interval.started_at).total_seconds() / 60
            stage_minutes[interval.stage] += minutes

    total_sleep = sum(stage_minutes.values()) or 1
    deep_rem_pct = (stage_minutes[SleepStage.deep] + stage_minutes[SleepStage.rem]) / total_sleep
    deep_rem_score = min(100, deep_rem_pct * 250)  # 40% deep+REM = 100

    # Onset latency: time before first non-awake stage
    onset_minutes = 0.0
    if stages and stages[0].stage == SleepStage.awake and stages[0].ended_at:
        onset_minutes = (stages[0].ended_at - stages[0].started_at).total_seconds() / 60
    onset_score = max(0, 100 - (onset_minutes / 30) * 100)  # 0 min = 100, 30+ min = 0

    # Awakenings count
    awakenings = sum(
        1 for i, s in enumerate(stages)
        if s.stage == SleepStage.awake and i > 0
    )
    awakening_score = max(0, 100 - awakenings * 20)  # Each awakening costs 20 points

    # Weighted total
    score = (
        duration_score * 0.30
        + deep_rem_score * 0.40
        + onset_score * 0.15
        + awakening_score * 0.15
    )
    return max(0, min(100, round(score)))
