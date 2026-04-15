import SwiftUI
import SlipieCoreKit

struct SoundscapeDetailView: View {
    let soundscape: Soundscape
    @EnvironmentObject var env: AppEnvironment
    @StateObject private var viewModel = SoundscapeDetailViewModel()

    var body: some View {
        ZStack {
            SlipieColors.background.ignoresSafeArea()
            VStack(spacing: 32) {
                Image(systemName: SlipieSymbols.soundscapes)
                    .font(.system(size: 72))
                    .foregroundStyle(SlipieColors.accentGradient)
                    .padding(.top, 40)

                VStack(spacing: 8) {
                    Text(soundscape.name)
                        .font(SlipieTypography.largeTitle)
                        .foregroundStyle(SlipieColors.textPrimary)
                    Text(soundscape.description)
                        .font(SlipieTypography.body)
                        .foregroundStyle(SlipieColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                HStack(spacing: 16) {
                    PillButton(
                        title: viewModel.isPreviewing ? "Stop" : "Preview",
                        icon: viewModel.isPreviewing ? SlipieSymbols.stop : SlipieSymbols.play,
                        style: .outline
                    ) { viewModel.togglePreview(soundscape: soundscape, audioService: env.audioService) }

                    PillButton(title: "Use This", icon: SlipieSymbols.moon, style: .filled) {
                        env.selectedSoundscape = soundscape
                    }
                }
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.stopPreviewIfNeeded(audioService: env.audioService)
        }
    }
}
