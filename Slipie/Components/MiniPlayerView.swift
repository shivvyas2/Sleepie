import SwiftUI

struct MiniPlayerView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var progress: CGFloat = 0.3

    var body: some View {
        VStack(spacing: 0) {
            progressBar

            HStack(spacing: 12) {
                trackInfo
                Spacer()
                playPauseButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .frame(height: 64)
        .background(
            SlipieColors.surfaceRaised
                .overlay(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(0.4)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(SlipieColors.surface)
                    .frame(height: 2)

                Rectangle()
                    .fill(SlipieColors.accentGradient)
                    .frame(width: geo.size.width * progress, height: 2)
            }
        }
        .frame(height: 2)
    }

    private var trackInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(env.selectedSoundscape.name)
                .font(SlipieTypography.headline())
                .foregroundStyle(SlipieColors.textPrimary)
                .lineLimit(1)
            Text("Sleep Session Active")
                .font(SlipieTypography.caption())
                .foregroundStyle(SlipieColors.textSecondary)
        }
    }

    private var playPauseButton: some View {
        Button {
            if env.isSessionActive {
                env.endSession()
            } else {
                env.startSession()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(SlipieColors.accentGradient)
                    .frame(width: 40, height: 40)
                Image(systemName: env.isSessionActive ? SlipieSymbols.pause : SlipieSymbols.play)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(SlipieColors.textPrimary)
            }
        }
    }
}
