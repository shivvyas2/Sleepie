import SwiftUI
import SlipieCoreKit

struct ActiveSessionView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var currentStage: SleepStage = .awake
    @State private var currentHR: Double = 65
    @State private var elapsed: TimeInterval = 0
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            SlipieColors.background.ignoresSafeArea()
            RadialGradient(
                colors: [SlipieColors.accentGlow.opacity(0.2), SlipieColors.background],
                center: .center,
                startRadius: 50,
                endRadius: 350
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                elapsedTimeView
                biometricCard
                stageCard
                Spacer()
                endButton
            }
            .padding(24)
        }
        .onAppear { startElapsedTimer() }
        .onDisappear { timer?.invalidate() }
    }

    private var elapsedTimeView: some View {
        VStack(spacing: 4) {
            Text(formatElapsed(elapsed))
                .font(.system(size: 48, weight: .thin, design: .rounded))
                .foregroundStyle(SlipieColors.textPrimary)
            Text("Session active")
                .font(SlipieTypography.caption())
                .foregroundStyle(SlipieColors.textSecondary)
        }
        .padding(.top, 24)
    }

    private var biometricCard: some View {
        GlowingCardView {
            HStack(spacing: 40) {
                BiometricIndicator(icon: SlipieSymbols.heartRate, label: "Heart Rate", value: "\(Int(currentHR)) bpm")
                BiometricIndicator(icon: SlipieSymbols.oxygen, label: "SpO2", value: "98%")
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var stageCard: some View {
        GlowingCardView {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sleep Stage")
                        .font(SlipieTypography.caption())
                        .foregroundStyle(SlipieColors.textSecondary)
                        .textCase(.uppercase)
                    Text(currentStage.rawValue.capitalized)
                        .font(SlipieTypography.title2())
                        .foregroundStyle(SlipieColors.textPrimary)
                }
                Spacer()
                Image(systemName: SlipieSymbols.sleep)
                    .font(.title)
                    .foregroundStyle(SlipieColors.accentGradient)
            }
        }
    }

    private var endButton: some View {
        PillButton(title: "End Session", icon: SlipieSymbols.stop, style: .outline) {
            env.endSession()
        }
        .padding(.bottom, 32)
    }

    private func startElapsedTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] _ in
            Task { @MainActor in
                elapsed += 1
            }
        }
    }

    private func formatElapsed(_ interval: TimeInterval) -> String {
        let h = Int(interval) / 3600
        let m = (Int(interval) % 3600) / 60
        let s = Int(interval) % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }
}
