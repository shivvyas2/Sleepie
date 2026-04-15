import SwiftUI
import SlipieCoreKit

struct ActiveSessionView: View {
    @EnvironmentObject var env: AppEnvironment
    @StateObject private var viewModel = ActiveSessionViewModel()

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
        .onAppear { viewModel.startElapsedTimer() }
        .onDisappear { viewModel.stopTimer() }
    }

    private var elapsedTimeView: some View {
        VStack(spacing: 4) {
            Text(viewModel.formatElapsed(viewModel.elapsed))
                .font(.system(size: 48, weight: .thin, design: .rounded))
                .foregroundStyle(SlipieColors.textPrimary)
            Text("Session active")
                .font(SlipieTypography.caption)
                .foregroundStyle(SlipieColors.textSecondary)
        }
        .padding(.top, 24)
    }

    private var biometricCard: some View {
        GlowingCardView {
            HStack(spacing: 40) {
                BiometricIndicator(icon: SlipieSymbols.heartRate, label: "Heart Rate", value: "\(Int(viewModel.currentHR)) bpm")
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
                        .font(SlipieTypography.caption)
                        .foregroundStyle(SlipieColors.textSecondary)
                        .textCase(.uppercase)
                    Text(viewModel.currentStage.rawValue.capitalized)
                        .font(SlipieTypography.title2)
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

}
