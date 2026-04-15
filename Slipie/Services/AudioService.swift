import SwiftUI
import SlipieCoreKit

@MainActor
final class AudioService: ObservableObject {
    private let engine = SleepAudioEngine()
    private let parameterMapper = ParameterMapper()

    @Published private(set) var isPlaying = false
    private var isPreviewActive = false

    func startSoundscape(_ soundscape: Soundscape) throws {
        try engine.start(soundscape: soundscape)
        isPlaying = true
        isPreviewActive = false
    }

    func stop() {
        engine.stop()
        isPlaying = false
        isPreviewActive = false
    }

    func applyBiometrics(_ packet: BiometricPacket, stage: SleepStage, soundscape: Soundscape) {
        let params = parameterMapper.map(biometrics: packet, stage: stage, soundscape: soundscape)
        engine.apply(parameters: params)
    }

    func preview(soundscape: Soundscape) throws {
        if isPlaying && !isPreviewActive { return }
        try engine.start(soundscape: soundscape)
        isPlaying = true
        isPreviewActive = true
    }

    func stopPreview() {
        guard isPreviewActive else { return }
        engine.stop()
        isPlaying = false
        isPreviewActive = false
    }
}
