import SwiftUI
import SlipieCoreKit

@MainActor
final class AppEnvironment: ObservableObject {
    let audioEngine = SleepAudioEngine()
    let parameterMapper = ParameterMapper()
    let healthKitManager = HealthKitManager()
    let supabaseClient: SlipieSupabaseClient

    @Published var currentSession: SleepSession?
    @Published var isSessionActive = false
    @Published var selectedSoundscape: Soundscape = Soundscape.all[0]

    private let classifier = SleepStageClassifier()

    init() {
        let config = SlipieSupabaseConfig(
            url: Secrets.supabaseURL,
            anonKey: Secrets.supabaseAnonKey
        )
        self.supabaseClient = SlipieSupabaseClient(config: config)
        setupWatchConnectivity()
    }

    private func setupWatchConnectivity() {
        PhoneConnectivityReceiver.shared.onPacketReceived = { [weak self] packet in
            Task { @MainActor [weak self] in
                guard let self, self.isSessionActive else { return }
                self.currentSession?.biometricEvents.append(packet)
                let onset = self.currentSession?.startedAt ?? Date()
                let minutesSinceOnset = Date().timeIntervalSince(onset) / 60
                let stage = self.classifier.classify(packet, timeSinceOnsetMinutes: minutesSinceOnset)
                let params = self.parameterMapper.map(
                    biometrics: packet,
                    stage: stage,
                    soundscape: self.selectedSoundscape
                )
                self.audioEngine.apply(parameters: params)
            }
        }
    }

    func startSession() {
        let userId = supabaseClient.currentUser?.id ?? UUID()
        let session = SleepSession(userId: userId, startedAt: Date(), soundscapeId: selectedSoundscape.id)
        currentSession = session
        isSessionActive = true
        try? audioEngine.start(soundscape: selectedSoundscape)
    }

    func endSession() {
        audioEngine.stop()
        isSessionActive = false
        currentSession?.endedAt = Date()
        let sessionCopy = currentSession
        Task {
            guard let session = sessionCopy else { return }
            try? await supabaseClient.saveSleepSession(session)
        }
        currentSession = nil
    }

    func applyBiometrics(_ packet: BiometricPacket, stage: SleepStage) {
        let params = parameterMapper.map(biometrics: packet, stage: stage, soundscape: selectedSoundscape)
        audioEngine.apply(parameters: params)
    }
}
