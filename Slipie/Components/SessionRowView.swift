import SwiftUI
import SlipieCoreKit

struct SessionRowView: View {
    let session: SleepSessionRow

    var body: some View {
        GlowingCardView {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.startedAt, style: .date)
                        .font(SlipieTypography.headline)
                        .foregroundStyle(SlipieColors.textPrimary)
                    if let score = session.sleepScore {
                        Text("Score: \(score)")
                            .font(SlipieTypography.caption)
                            .foregroundStyle(SlipieColors.textSecondary)
                    }
                }
                Spacer()
                Image(systemName: SlipieSymbols.trend)
                    .foregroundStyle(SlipieColors.accentEnd)
            }
        }
    }
}
