import SwiftUI

struct GoalItem: Identifiable {
    let id: Int
    let title: String
    let symbol: String
    let color: Color
}

let goals: [GoalItem] = [
    GoalItem(id: 0, title: "Sleep meditations", symbol: "moon.fill",
             color: Color(red: 0.5, green: 0.3, blue: 0.9)),
    GoalItem(id: 1, title: "Calming a busy mind", symbol: "brain.head.profile",
             color: Color(red: 0.2, green: 0.5, blue: 0.9)),
    GoalItem(id: 2, title: "Improve performance", symbol: "bolt.fill",
             color: Color(red: 1.0, green: 0.5, blue: 0.1)),
    GoalItem(id: 3, title: "Increase happiness", symbol: "sun.max.fill",
             color: Color(red: 0.2, green: 0.8, blue: 0.4)),
    GoalItem(id: 4, title: "Reduce stress or anxiety", symbol: "leaf.fill",
             color: Color(red: 1.0, green: 0.8, blue: 0.1)),
    GoalItem(id: 5, title: "Create a healthy habit", symbol: "heart.fill",
             color: Color(red: 0.9, green: 0.2, blue: 0.3)),
    GoalItem(id: 6, title: "Help my kids sleep", symbol: "figure.and.child.holdinghands",
             color: Color(red: 0.1, green: 0.7, blue: 0.8)),
]
