import SwiftUI

struct PageDotsView: View {
    let count: Int
    let selected: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == selected ? SlipieColors.accentEnd : SlipieColors.textSecondary.opacity(0.4))
                    .frame(width: index == selected ? 20 : 8, height: 8)
            }
        }
    }
}
