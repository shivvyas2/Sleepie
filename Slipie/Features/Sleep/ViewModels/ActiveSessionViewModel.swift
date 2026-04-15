import SwiftUI
import SlipieCoreKit

@MainActor
final class ActiveSessionViewModel: ObservableObject {
    @Published var elapsed: TimeInterval = 0

    private var timer: Timer?

    func startElapsedTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.elapsed += 1
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func formatElapsed(_ interval: TimeInterval) -> String {
        let h = Int(interval) / 3600
        let m = (Int(interval) % 3600) / 60
        let s = Int(interval) % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - Session Control

    func endSession(using session: SessionManager) {
        session.endSession()
    }
}
