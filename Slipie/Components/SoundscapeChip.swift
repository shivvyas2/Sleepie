import SwiftUI
import SlipieCoreKit

struct SoundscapeChip: View {
    let soundscape: Soundscape
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(soundscape.name)
                .font(SlipieTypography.caption)
                .foregroundStyle(isSelected ? SlipieColors.textPrimary : SlipieColors.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        Capsule().fill(SlipieColors.accentGradient)
                    } else {
                        Capsule().fill(SlipieColors.surface)
                    }
                }
        }
    }
}
