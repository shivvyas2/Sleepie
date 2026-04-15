import SwiftUI

struct FilterChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(SlipieTypography.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? SlipieColors.background : SlipieColors.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        Capsule().fill(Color.white)
                    } else {
                        Capsule().fill(Color.clear)
                            .overlay(Capsule().stroke(SlipieColors.textSecondary.opacity(0.3), lineWidth: 1))
                    }
                }
                .frame(height: 32)
        }
        .buttonStyle(.plain)
    }
}
