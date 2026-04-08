import SwiftUI

enum SlipieColors {
    static let background = Color(hex: "#050A18")
    static let surface = Color(hex: "#0D1A3A")
    static let surfaceRaised = Color(hex: "#112247")
    static let accentStart = Color(hex: "#1E3A8A")
    static let accentEnd = Color(hex: "#3B82F6")
    static let accentGlow = Color(hex: "#6366F1")
    static let textPrimary = Color(hex: "#F0F4FF")
    static let textSecondary = Color(hex: "#8899BB")
    static let danger = Color(hex: "#EF4444")
    static let success = Color(hex: "#22C55E")

    static let accentGradient = LinearGradient(
        stops: [
            .init(color: accentStart, location: 0),
            .init(color: accentEnd, location: 1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
