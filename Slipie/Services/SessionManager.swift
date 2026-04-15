import SwiftUI
import SlipieCoreKit

@MainActor
final class SessionManager: ObservableObject {
    private let supabaseClient: SlipieSupabaseClient
    private let audioService: AudioService
    private let classifier = SleepStageClassifier()

    @Published var currentSession: SleepSession?
    @Published var isSessionActive = false
    @Published var selectedSoundscape: Soundscape = Soundscape.all[0]
    @Published var currentHR: Double = 0
    @Published var currentStage: SleepStage = .awake

    init(supabaseClient: SlipieSupabaseClient, audioService: AudioService) {
        self.supabaseClient = supabaseClient
        self.audioService = audioService
        setupWatchConnectivity()
    }

    func startSession() {
        let userId = supabaseClient.currentUser?.id ?? UUID()
        let session = SleepSession(userId: userId, startedAt: Date(), soundscapeId: selectedSoundscape.id)
        currentSession = session
        isSessionActive = true
        try? audioService.startSoundscape(selectedSoundscape)
    }

    func endSession() {
        audioService.stop()
        isSessionActive = false
        currentSession?.endedAt = Date()
        let sessionCopy = currentSession
        Task {
            guard let session = sessionCopy else { return }
            try? await supabaseClient.saveSleepSession(session)
        }
        currentSession = nil
        currentHR = 0
        currentStage = .awake
    }

    private func setupWatchConnectivity() {
        PhoneConnectivityReceiver.shared.onPacketReceived = { [weak self] packet in
            Task { @MainActor [weak self] in
                guard let self, self.isSessionActive else { return }
                self.currentSession?.biometricEvents.append(packet)
                self.currentHR = packet.heartRate
                let onset = self.currentSession?.startedAt ?? Date()
                let minutesSinceOnset = Date().timeIntervalSince(onset) / 60
                let stage = self.classifier.classify(packet, timeSinceOnsetMinutes: minutesSinceOnset)
                self.currentStage = stage
                self.audioService.applyBiometrics(packet, stage: stage, soundscape: self.selectedSoundscape)
            }
        }
    }
}
