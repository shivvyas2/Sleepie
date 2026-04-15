import SwiftUI

struct AvatarItem: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}

let libraryAvatars: [AvatarItem] = [
    AvatarItem(name: "Jenny", color: Color(red: 0.5, green: 0.3, blue: 0.9)),
    AvatarItem(name: "Jane", color: Color(red: 0.2, green: 0.6, blue: 0.9)),
    AvatarItem(name: "Regina", color: Color(red: 0.9, green: 0.4, blue: 0.3)),
    AvatarItem(name: "Bessie", color: Color(red: 0.3, green: 0.8, blue: 0.5)),
    AvatarItem(name: "Lily", color: Color(red: 1.0, green: 0.6, blue: 0.2)),
]
