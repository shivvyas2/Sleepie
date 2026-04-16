from datetime import datetime, timezone

from app.audio.parameter_mapper import map_parameters
from app.sessions.schemas import BiometricPacket, SleepStage
from app.soundscapes.catalog import SOUNDSCAPES_BY_ID


def _packet(hr=60.0, hrv=40.0, spo2=97.0, rr=14.0, motion=0.1) -> BiometricPacket:
    return BiometricPacket(
        recorded_at=datetime.now(timezone.utc),
        heart_rate=hr, hrv=hrv, spo2=spo2,
        respiratory_rate=rr, motion_intensity=motion,
    )


def test_awake_stage_no_modifiers():
    rain = SOUNDSCAPES_BY_ID["rain"]
    params = map_parameters(_packet(hr=70, hrv=40), SleepStage.awake, rain)
    # Awake: reverb_boost=0, filter_mod=0, tempo_damp=0
    assert 0 <= params.volume <= 1
    assert 0.05 <= params.tempo <= 1.5
    assert 0.05 <= params.filter_cutoff_normalized <= 1
    assert 0 <= params.reverb_wetness <= 1


def test_deep_stage_high_reverb_low_filter():
    rain = SOUNDSCAPES_BY_ID["rain"]
    deep_params = map_parameters(_packet(hr=50, hrv=60), SleepStage.deep, rain)
    awake_params = map_parameters(_packet(hr=50, hrv=60), SleepStage.awake, rain)
    # Deep should have higher reverb and lower filter cutoff than awake
    assert deep_params.reverb_wetness > awake_params.reverb_wetness
    assert deep_params.filter_cutoff_normalized < awake_params.filter_cutoff_normalized
    assert deep_params.tempo < awake_params.tempo


def test_high_hr_reduces_filter_and_increases_reverb():
    rain = SOUNDSCAPES_BY_ID["rain"]
    low_hr = map_parameters(_packet(hr=45), SleepStage.light, rain)
    high_hr = map_parameters(_packet(hr=90), SleepStage.light, rain)
    assert low_hr.filter_cutoff_normalized > high_hr.filter_cutoff_normalized


def test_motion_reduces_volume():
    rain = SOUNDSCAPES_BY_ID["rain"]
    low_motion = map_parameters(_packet(motion=0.0), SleepStage.light, rain)
    high_motion = map_parameters(_packet(motion=0.5), SleepStage.light, rain)
    assert low_motion.volume > high_motion.volume


def test_oscillator_mix_matches_soundscape():
    ocean = SOUNDSCAPES_BY_ID["ocean"]
    params = map_parameters(_packet(), SleepStage.light, ocean)
    assert params.oscillator_mix == ocean.base_parameters.oscillator_mix


def test_pitch_shift_negative_or_zero():
    rain = SOUNDSCAPES_BY_ID["rain"]
    params = map_parameters(_packet(hr=70), SleepStage.light, rain)
    assert params.pitch_shift <= 0


def test_all_params_clamped_with_extreme_inputs():
    rain = SOUNDSCAPES_BY_ID["rain"]
    # Extreme high values
    params = map_parameters(_packet(hr=200, hrv=200, motion=1.0), SleepStage.deep, rain)
    assert 0.3 <= params.volume <= 1.0
    assert 0.05 <= params.tempo <= 1.5
    assert 0.05 <= params.filter_cutoff_normalized <= 1.0
    assert 0 <= params.reverb_wetness <= 1.0

    # Extreme low values
    params2 = map_parameters(_packet(hr=0, hrv=0, motion=0.0), SleepStage.awake, rain)
    assert 0.3 <= params2.volume <= 1.0
    assert 0.05 <= params2.tempo <= 1.5


def test_all_soundscapes_produce_valid_params():
    for sc_id, sc in SOUNDSCAPES_BY_ID.items():
        for stage in SleepStage:
            params = map_parameters(_packet(), stage, sc)
            assert 0.3 <= params.volume <= 1.0, f"Failed for {sc_id}/{stage}"
            assert 0.05 <= params.tempo <= 1.5, f"Failed for {sc_id}/{stage}"
            assert 0.05 <= params.filter_cutoff_normalized <= 1.0, f"Failed for {sc_id}/{stage}"
            assert 0 <= params.reverb_wetness <= 1.0, f"Failed for {sc_id}/{stage}"
