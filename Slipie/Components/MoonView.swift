import SwiftUI

struct MoonView: View {
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [Color(hex: "#FF6B35"), Color(hex: "#FF3D00")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .shadow(color: Color(hex: "#FF6B35").opacity(0.6), radius: 16, x: 0, y: 0)
    }
}
