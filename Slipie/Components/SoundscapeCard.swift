import SwiftUI
import SlipieCoreKit

struct SoundscapeCard: View {
    let soundscape: Soundscape

    var body: some View {
        GlowingCardView {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: SlipieSymbols.soundscapes)
                    .font(.title)
                    .foregroundStyle(SlipieColors.accentGradient)
                Text(soundscape.name)
                    .font(SlipieTypography.headline)
                    .foregroundStyle(SlipieColors.textPrimary)
                Text(soundscape.description)
                    .font(SlipieTypography.caption)
                    .foregroundStyle(SlipieColors.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
