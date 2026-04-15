import SwiftUI

struct SleepTimerCard: View {
    @Binding var minutes: Int
    @Binding var showPicker: Bool

    var body: some View {
        GlowingCardView {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sleep Timer")
                        .font(SlipieTypography.caption)
                        .foregroundStyle(SlipieColors.textSecondary)
                        .textCase(.uppercase)
                    Text("\(minutes) min")
                        .font(SlipieTypography.headline)
                        .foregroundStyle(SlipieColors.textPrimary)
                }
                Spacer()
                Image(systemName: SlipieSymbols.timer)
                    .foregroundStyle(SlipieColors.accentEnd)
                    .font(.title2)
            }
        }
        .onTapGesture { showPicker = true }
    }
}
