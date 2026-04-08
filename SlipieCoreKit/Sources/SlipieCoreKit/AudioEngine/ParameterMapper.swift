import Foundation

public final class ParameterMapper: Sendable {
    public init() {}

    public func map(biometrics: BiometricPacket, stage: SleepStage, soundscape: Soundscape) -> AudioParameters {
        let hrNorm = normalize(biometrics.heartRate, min: 40, max: 100)
        let hrvNorm = normalize(biometrics.hrv, min: 10, max: 100)

        let stageReverbBoost: Double
        let stageFilterMod: Double
        let stageTempoDamp: Double
        switch stage {
        case .awake:
            stageReverbBoost = 0.0; stageFilterMod = 0.0; stageTempoDamp = 0.0
        case .light:
            stageReverbBoost = 0.15; stageFilterMod = -0.1; stageTempoDamp = 0.1
        case .deep:
            stageReverbBoost = 0.45; stageFilterMod = -0.4; stageTempoDamp = 0.35
        case .rem:
            stageReverbBoost = 0.25; stageFilterMod = -0.15; stageTempoDamp = 0.2
        }

        let reverbWetness = clamp(Double(soundscape.baseParameters.reverbPreset) / 10.0 + stageReverbBoost + (hrNorm * 0.2), min: 0, max: 1)
        let filterCutoff = clamp(0.7 - (hrNorm * 0.3) + stageFilterMod + (hrvNorm * 0.1), min: 0.05, max: 1)
        let tempo = clamp(0.8 - (hrNorm * 0.4) - stageTempoDamp + (hrvNorm * 0.15), min: 0.05, max: 1.5)
        let volume = clamp(0.75 - (biometrics.motionIntensity * 0.2), min: 0.3, max: 1.0)

        return AudioParameters(
            volume: volume,
            tempo: tempo,
            filterCutoffNormalized: filterCutoff,
            reverbWetness: reverbWetness,
            oscillatorMix: soundscape.baseParameters.oscillatorMix,
            pitchShift: -(hrNorm * 4)
        )
    }

    private func normalize(_ value: Double, min: Double, max: Double) -> Double {
        clamp((value - min) / (max - min), min: 0, max: 1)
    }

    private func clamp(_ value: Double, min: Double, max: Double) -> Double {
        Swift.min(Swift.max(value, min), max)
    }
}
