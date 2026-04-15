import SwiftUI

struct LibraryCardView: View {
    let card: SoundscapeCardData

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [card.cardColor, card.cardColor.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 160)

            VStack(alignment: .leading) {
                HStack {
                    durationBadge
                    Spacer()
                    statusBadge
                }

                Spacer()

                VStack(alignment: .leading, spacing: 2) {
                    Text(card.title)
                        .font(SlipieTypography.headline)
                        .foregroundStyle(SlipieColors.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text(card.author)
                        .font(SlipieTypography.caption)
                        .foregroundStyle(SlipieColors.textSecondary)
                }
            }
            .padding(12)
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var durationBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .font(.system(size: 9))
            Text(card.duration)
                .font(SlipieTypography.caption2)
        }
        .foregroundStyle(SlipieColors.textPrimary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.4))
        .clipShape(Capsule())
    }

    private var statusBadge: some View {
        Group {
            if card.isNew {
                Text("New")
                    .font(SlipieTypography.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#FF6B35"))
                    .clipShape(Capsule())
            } else {
                Text("Free")
                    .font(SlipieTypography.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(SlipieColors.accentEnd)
                    .clipShape(Capsule())
            }
        }
    }
}
