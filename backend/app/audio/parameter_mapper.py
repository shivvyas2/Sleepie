from app.audio.schemas import AudioParameters
from app.sessions.schemas import BiometricPacket, SleepStage
from app.soundscapes.schemas import Soundscape


def _clamp(value: float, min_val: float, max_val: float) -> float:
    return max(min_val, min(value, max_val))


def _normalize(value: float, min_val: float, max_val: float) -> float:
    return _clamp((value - min_val) / (max_val - min_val), 0.0, 1.0)


# Stage modifiers: (reverb_boost, filter_mod, tempo_damp)
_STAGE_MODS: dict[SleepStage, tuple[float, float, float]] = {
    SleepStage.awake: (0.0, 0.0, 0.0),
    SleepStage.light: (0.15, -0.1, 0.1),
    SleepStage.deep: (0.45, -0.4, 0.35),
    SleepStage.rem: (0.25, -0.15, 0.2),
}


def map_parameters(
    biometrics: BiometricPacket,
    stage: SleepStage,
    soundscape: Soundscape,
) -> AudioParameters:
    """Port of ParameterMapper.swift — must produce identical output."""

    hr_norm = _normalize(biometrics.heart_rate, 40, 100)
    hrv_norm = _normalize(biometrics.hrv, 10, 100)

    reverb_boost, filter_mod, tempo_damp = _STAGE_MODS[stage]

    reverb_wetness = _clamp(
        soundscape.base_parameters.reverb_preset / 10.0
        + reverb_boost
        + (hr_norm * 0.2),
        0, 1,
    )
    filter_cutoff = _clamp(
        0.7 - (hr_norm * 0.3) + filter_mod + (hrv_norm * 0.1),
        0.05, 1,
    )
    tempo = _clamp(
        0.8 - (hr_norm * 0.4) - tempo_damp + (hrv_norm * 0.15),
        0.05, 1.5,
    )
    volume = _clamp(0.75 - (biometrics.motion_intensity * 0.2), 0.3, 1.0)

    return AudioParameters(
        volume=volume,
        tempo=tempo,
        filter_cutoff_normalized=filter_cutoff,
        reverb_wetness=reverb_wetness,
        oscillator_mix=soundscape.base_parameters.oscillator_mix,
        pitch_shift=-(hr_norm * 4),
    )
