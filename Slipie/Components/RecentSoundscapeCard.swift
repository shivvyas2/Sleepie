import SwiftUI
import SlipieCoreKit

struct RecentSoundscapeCard: View {
    let soundscape: Soundscape

    private let cardColorOptions: [Color] = [
        Color(hex: "#1a1060"),
        Color(hex: "#0d1f3c"),
        Color(hex: "#1a0d2e"),
        Color(hex: "#0a1628"),
    ]

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(cardGradient)
                .frame(width: 120, height: 100)

            Text(soundscape.name)
                .font(SlipieTypography.caption)
                .fontWeight(.semibold)
                .foregroundStyle(SlipieColors.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(10)
        }
        .frame(width: 120, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var cardGradient: LinearGradient {
        let index = abs(soundscape.name.hashValue) % cardColorOptions.count
        return LinearGradient(
            colors: [cardColorOptions[index], SlipieColors.surface],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
