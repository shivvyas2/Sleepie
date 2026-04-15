import SwiftUI
import Combine
import SlipieCoreKit

@MainActor
final class AppEnvironment: ObservableObject {
    let audioService: AudioService
    let sessionManager: SessionManager
    let supabaseClient: SlipieSupabaseClient

    private var cancellables = Set<AnyCancellable>()

    init() {
        let config = SlipieSupabaseConfig(
            url: Secrets.supabaseURL,
            anonKey: Secrets.supabaseAnonKey
        )
        let client = SlipieSupabaseClient(config: config)
        let audio = AudioService()
        let session = SessionManager(supabaseClient: client, audioService: audio)

        self.supabaseClient = client
        self.audioService = audio
        self.sessionManager = session

        session.objectWillChange
            .sink { [weak self] in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: - Convenience forwarding (used by views until Phase 3 wires ViewModels)

    var isSessionActive: Bool { sessionManager.isSessionActive }

    var selectedSoundscape: Soundscape {
        get { sessionManager.selectedSoundscape }
        set { sessionManager.selectedSoundscape = newValue }
    }

    func startSession() { sessionManager.startSession() }
    func endSession() { sessionManager.endSession() }
}
