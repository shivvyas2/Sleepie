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

    private var backgroundLayer: some View {
        ZStack {
            SlipieColors.background.ignoresSafeArea()
            RadialGradient(
                colors: [SlipieColors.accentStart.opacity(0.3), SlipieColors.background],
                center: .top,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()
        }
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
        GlowingCardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Soundscape")
                    .font(SlipieTypography.caption)
                    .foregroundStyle(SlipieColors.textSecondary)
                    .textCase(.uppercase)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Soundscape.all) { soundscape in
                            SoundscapeChip(
                                soundscape: soundscape,
                                isSelected: soundscape.id == env.selectedSoundscape.id
                            ) {
                                viewModel.selectSoundscape(soundscape, using: env.sessionManager)
                            }
                        }
                    }
                }
            }
        }
    }

    private var timerSection: some View {
        GlowingCardView {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sleep Timer")
                        .font(SlipieTypography.caption)
                        .foregroundStyle(SlipieColors.textSecondary)
                        .textCase(.uppercase)
                    Text("\(viewModel.timerMinutes) min")
                        .font(SlipieTypography.headline)
                        .foregroundStyle(SlipieColors.textPrimary)
                }
                Spacer()
                Image(systemName: SlipieSymbols.timer)
                    .foregroundStyle(SlipieColors.accentEnd)
                    .font(.title2)
            }
        }
        .onTapGesture { viewModel.showTimerPicker = true }
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
