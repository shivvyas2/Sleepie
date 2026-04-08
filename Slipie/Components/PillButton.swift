import SwiftUI

struct PillButton: View {
    let title: String
    let icon: String
    let style: Style
    let action: () -> Void

    enum Style { case filled, outline }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
                    .font(SlipieTypography.headline())
            }
            .foregroundStyle(style == .filled ? SlipieColors.textPrimary : SlipieColors.accentEnd)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background {
                if style == .filled {
                    Capsule().fill(SlipieColors.accentGradient)
                } else {
                    Capsule().fill(Color.clear)
                }
            }
            .overlay {
                if style == .outline {
                    Capsule().stroke(SlipieColors.accentEnd, lineWidth: 1.5)
                }
            }
        }
    }
}
