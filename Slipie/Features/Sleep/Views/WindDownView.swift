import SwiftUI
import SlipieCoreKit

struct WindDownView: View {
    @EnvironmentObject var env: AppEnvironment
    @StateObject private var viewModel = WindDownViewModel()

    var body: some View {
        ZStack {
            backgroundLayer
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    soundscapeSelector
                    timerSection
                    startButton
                }
                .padding(20)
            }
        }
    }

    private var backgroundLayer: SlipieBackgroundView {
        SlipieBackgroundView()
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: SlipieSymbols.moon)
                .font(.system(size: 52))
                .foregroundStyle(SlipieColors.accentGradient)
            Text("Ready to sleep?")
                .font(SlipieTypography.title)
                .foregroundStyle(SlipieColors.textPrimary)
            Text("Choose your soundscape and settle in")
                .font(SlipieTypography.body)
                .foregroundStyle(SlipieColors.textSecondary)
        }
        .padding(.top, 16)
    }

    private var soundscapeSelector: some View {
        SoundscapeSelectorView(selectedSoundscape: Binding(
            get: { env.selectedSoundscape },
            set: { viewModel.selectSoundscape($0, using: env.sessionManager) }
        ))
    }

    private var timerSection: some View {
        SleepTimerCard(
            minutes: $viewModel.timerMinutes,
            showPicker: $viewModel.showTimerPicker
        )
        .sheet(isPresented: $viewModel.showTimerPicker) {
            TimerPickerSheet(minutes: $viewModel.timerMinutes)
        }
    }

    private var startButton: some View {
        PillButton(title: "Start Sleep", icon: SlipieSymbols.play, style: .filled) {
            viewModel.startSession(using: env.sessionManager)
        }
        .frame(maxWidth: .infinity)
    }
}
