import SwiftUI
import SlipieCoreKit

@MainActor
final class WindDownViewModel: ObservableObject {
    @Published var timerMinutes = 30
    @Published var showTimerPicker = false

    // MARK: - Session Control

    func startSession(using session: SessionManager) {
        session.startSession()
    }

    func selectSoundscape(_ soundscape: Soundscape, using session: SessionManager) {
        session.selectedSoundscape = soundscape
    }
}
