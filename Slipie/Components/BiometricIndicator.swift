import SwiftUI

struct BiometricIndicator: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(SlipieColors.accentGlow)
                .font(.title2)
            Text(value)
                .font(SlipieTypography.headline())
                .foregroundStyle(SlipieColors.textPrimary)
            Text(label)
                .font(SlipieTypography.caption())
                .foregroundStyle(SlipieColors.textSecondary)
        }
    }
}
