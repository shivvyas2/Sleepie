import SwiftUI

struct SoundscapeCardData: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let duration: String
    let isNew: Bool
    let cardColor: Color
}

let libraryCards: [SoundscapeCardData] = [
    SoundscapeCardData(title: "Deep Sleep", author: "Jenny", duration: "15 min",
                       isNew: false, cardColor: Color(hex: "#1a1060")),
    SoundscapeCardData(title: "Magical City", author: "Regina", duration: "17 min",
                       isNew: true, cardColor: Color(hex: "#0d1f3c")),
    SoundscapeCardData(title: "You Are Not Alone", author: "Kathryn", duration: "10 min",
                       isNew: false, cardColor: Color(hex: "#1a0d2e")),
    SoundscapeCardData(title: "Planet Of Crystals", author: "Irma", duration: "25 min",
                       isNew: false, cardColor: Color(hex: "#0a1628")),
]
