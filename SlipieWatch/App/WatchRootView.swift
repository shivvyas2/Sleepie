import SwiftUI
import SlipieCoreKit

struct WatchRootView: View {
    @StateObject private var sessionManager = WatchSessionManager()
    @State private var sendTimer: Timer?

    var body: some View {
        ZStack {
            Color(red: 5/255, green: 10/255, blue: 24/255).ignoresSafeArea()
            if sessionManager.isActive {
                activeView
            } else {
                idleView
            }
        }
        .task { await sessionManager.requestAuthorization() }
    }

    private var idleView: some View {
        VStack(spacing: 16) {
            Image(systemName: "moon.stars.fill")
                .font(.title2)
                .foregroundStyle(Color(red: 0.118, green: 0.227, blue: 0.541))
            Button("Start Sleep") {
                Task { try? await sessionManager.start() }
                startSendingBiometrics()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0.118, green: 0.227, blue: 0.541))
        }
    }

    private var activeView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(Color(red: 0.388, green: 0.400, blue: 0.945))
                Text("\(Int(sessionManager.heartRate)) bpm")
                    .foregroundStyle(.white)
            }
            HStack {
                Image(systemName: "lungs.fill")
                    .foregroundStyle(.white.opacity(0.7))
                Text("\(Int(sessionManager.spo2))%")
                    .foregroundStyle(.white)
            }
            Button("End") {
                Task { await sessionManager.stop() }
                sendTimer?.invalidate()
                sendTimer = nil
            }
            .buttonStyle(.bordered)
        }
    }

    private func startSendingBiometrics() {
        sendTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            let packet = BiometricPacket(
                recordedAt: Date(),
                heartRate: sessionManager.heartRate,
                hrv: sessionManager.hrv,
                spo2: sessionManager.spo2,
                respiratoryRate: 14,
                motionIntensity: 0
            )
            WatchConnectivityBridge.shared.send(packet: packet)
        }
    }
}
