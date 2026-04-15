import SwiftUI

struct SleepScoreCard: View {
    let score: Int?

    var body: some View {
        GlowingCardView {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sleep Score")
                        .font(SlipieTypography.caption)
                        .foregroundStyle(SlipieColors.textSecondary)
                        .textCase(.uppercase)
                    Text(score.map { "\($0)" } ?? "--")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(scoreColor)
                }
                Spacer()
                Image(systemName: SlipieSymbols.score)
                    .font(.system(size: 40))
                    .foregroundStyle(SlipieColors.accentGradient)
            }
        }
    }

    private var scoreColor: Color {
        guard let score else { return SlipieColors.textSecondary }
        switch score {
        case 80...100: return SlipieColors.success
        case 50...79: return SlipieColors.accentEnd
        default: return SlipieColors.danger
        }
    }
}
