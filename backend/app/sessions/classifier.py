from app.sessions.schemas import BiometricPacket, SleepStage


def classify(packet: BiometricPacket, time_since_onset_minutes: float) -> SleepStage:
    """Port of SleepStageClassifier.swift — must produce identical output."""

    if packet.motion_intensity > 0.4:
        return SleepStage.awake

    if time_since_onset_minutes < 10:
        return SleepStage.light

    if (
        packet.heart_rate < 55
        and packet.hrv > 50
        and time_since_onset_minutes > 30
    ):
        cycle_position = time_since_onset_minutes % 90
        return SleepStage.rem if cycle_position > 60 else SleepStage.deep

    if packet.heart_rate < 65:
        return SleepStage.light

    return SleepStage.awake
