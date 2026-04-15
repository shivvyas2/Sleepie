import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var timerMinutes = 30
    @Published var showTimerPicker = false

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }
}
