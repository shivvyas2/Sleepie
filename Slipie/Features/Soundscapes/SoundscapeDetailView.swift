import SwiftUI
import SlipieCoreKit

struct SoundscapeDetailView: View {
    let soundscape: Soundscape
    @EnvironmentObject var env: AppEnvironment
    @State private var isPreviewing = false

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
                        .font(SlipieTypography.largeTitle())
                        .foregroundStyle(SlipieColors.textPrimary)
                    Text(soundscape.description)
                        .font(SlipieTypography.body())
                        .foregroundStyle(SlipieColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                HStack(spacing: 16) {
                    PillButton(
                        title: isPreviewing ? "Stop" : "Preview",
                        icon: isPreviewing ? SlipieSymbols.stop : SlipieSymbols.play,
                        style: .outline
                    ) { togglePreview() }

                    PillButton(title: "Use This", icon: SlipieSymbols.moon, style: .filled) {
                        env.selectedSoundscape = soundscape
                    }
                }
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            if isPreviewing {
                env.audioEngine.stop()
                isPreviewing = false
            }
        }
    }

    private func togglePreview() {
        if isPreviewing {
            env.audioEngine.stop()
        } else {
            try? env.audioEngine.start(soundscape: soundscape)
        }
        isPreviewing.toggle()
    }
}
