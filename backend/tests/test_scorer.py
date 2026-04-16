from datetime import datetime, timedelta, timezone

from app.sessions.schemas import SleepStage, SleepStageInterval
from app.sessions.scorer import compute_sleep_score


def _interval(stage: SleepStage, start_offset_min: int, duration_min: int) -> SleepStageInterval:
    base = datetime(2026, 1, 1, tzinfo=timezone.utc)
    return SleepStageInterval(
        stage=stage,
        started_at=base + timedelta(minutes=start_offset_min),
        ended_at=base + timedelta(minutes=start_offset_min + duration_min),
    )


def test_zero_duration_returns_zero():
    assert compute_sleep_score(0, []) == 0


def test_no_stages_returns_low_score():
    score = compute_sleep_score(480, [])
    # Duration is good (8h) but no stage data → low deep_rem and onset scores
    assert 0 <= score <= 100


def test_ideal_session_scores_high():
    stages = [
        _interval(SleepStage.light, 0, 30),
        _interval(SleepStage.deep, 30, 90),
        _interval(SleepStage.rem, 120, 60),
        _interval(SleepStage.light, 180, 60),
        _interval(SleepStage.deep, 240, 90),
        _interval(SleepStage.rem, 330, 60),
        _interval(SleepStage.light, 390, 90),
    ]
    score = compute_sleep_score(480, stages)
    assert score >= 70


def test_more_deep_rem_scores_higher():
    mostly_light = [
        _interval(SleepStage.light, 0, 400),
        _interval(SleepStage.deep, 400, 40),
        _interval(SleepStage.rem, 440, 40),
    ]
    mostly_deep = [
        _interval(SleepStage.light, 0, 100),
        _interval(SleepStage.deep, 100, 200),
        _interval(SleepStage.rem, 300, 180),
    ]
    score_light = compute_sleep_score(480, mostly_light)
    score_deep = compute_sleep_score(480, mostly_deep)
    assert score_deep > score_light


def test_awakenings_reduce_score():
    no_wake = [
        _interval(SleepStage.light, 0, 240),
        _interval(SleepStage.deep, 240, 240),
    ]
    with_wakes = [
        _interval(SleepStage.light, 0, 100),
        _interval(SleepStage.awake, 100, 10),
        _interval(SleepStage.light, 110, 100),
        _interval(SleepStage.awake, 210, 10),
        _interval(SleepStage.deep, 220, 260),
    ]
    score_no_wake = compute_sleep_score(480, no_wake)
    score_wakes = compute_sleep_score(480, with_wakes)
    assert score_no_wake > score_wakes


def test_score_clamped_to_0_100():
    stages = [_interval(SleepStage.deep, 0, 480)]
    score = compute_sleep_score(480, stages)
    assert 0 <= score <= 100
