from datetime import datetime, timezone

from app.sessions.classifier import classify
from app.sessions.schemas import BiometricPacket, SleepStage


def _packet(hr=60.0, hrv=30.0, spo2=97.0, rr=14.0, motion=0.1) -> BiometricPacket:
    return BiometricPacket(
        recorded_at=datetime.now(timezone.utc),
        heart_rate=hr, hrv=hrv, spo2=spo2,
        respiratory_rate=rr, motion_intensity=motion,
    )


def test_high_motion_returns_awake():
    assert classify(_packet(motion=0.5), 20) == SleepStage.awake
    assert classify(_packet(motion=0.9), 60) == SleepStage.awake


def test_early_onset_returns_light():
    assert classify(_packet(hr=50, hrv=60), 5) == SleepStage.light
    assert classify(_packet(hr=80), 0) == SleepStage.light


def test_deep_sleep_conditions():
    # HR < 55, HRV > 50, time > 30 min, cycle position < 60 → deep
    assert classify(_packet(hr=50, hrv=60), 35) == SleepStage.deep
    assert classify(_packet(hr=54, hrv=51), 45) == SleepStage.deep


def test_rem_sleep_via_ultradian_cycle():
    # HR < 55, HRV > 50, time > 30 min, cycle position > 60 → rem
    # At 65 min: cycle_position = 65 % 90 = 65 > 60 → rem
    assert classify(_packet(hr=50, hrv=60), 65) == SleepStage.rem
    # At 155 min: cycle_position = 155 % 90 = 65 > 60 → rem
    assert classify(_packet(hr=50, hrv=60), 155) == SleepStage.rem


def test_low_hr_returns_light():
    # HR < 65 but not meeting deep/rem conditions
    assert classify(_packet(hr=60, hrv=30), 20) == SleepStage.light


def test_default_returns_awake():
    # HR >= 65, low motion, past onset
    assert classify(_packet(hr=70, hrv=30), 20) == SleepStage.awake


def test_boundary_motion_at_0_4_is_not_awake():
    # motion_intensity > 0.4 is awake, so exactly 0.4 should NOT be awake
    result = classify(_packet(hr=60, hrv=30, motion=0.4), 20)
    assert result == SleepStage.light  # HR < 65 → light


def test_boundary_time_at_10_is_not_light():
    # time < 10 is light, so exactly 10 should NOT be forced light
    result = classify(_packet(hr=70, hrv=30), 10)
    assert result == SleepStage.awake  # HR >= 65, default
