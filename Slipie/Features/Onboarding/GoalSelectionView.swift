import SwiftUI

struct GoalItem: Identifiable {
    let id: Int
    let title: String
    let symbol: String
    let color: Color
}

private let goals: [GoalItem] = [
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

struct GoalSelectionView: View {
    @Binding var selectedGoals: Set<Int>

    var body: some View {
        VStack(spacing: 12) {
            ForEach(goals) { goal in
                GoalRow(
                    goal: goal,
                    isSelected: selectedGoals.contains(goal.id)
                ) {
                    if selectedGoals.contains(goal.id) {
                        selectedGoals.remove(goal.id)
                    } else {
                        selectedGoals.insert(goal.id)
                    }
                }
            }
        }
    }
}

struct GoalRow: View {
    let goal: GoalItem
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(goal.color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    Image(systemName: goal.symbol)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(goal.color)
                }

                Text(goal.title)
                    .font(SlipieTypography.body())
                    .foregroundStyle(SlipieColors.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(SlipieColors.accentEnd)
                        .font(.system(size: 20))
                } else {
                    Circle()
                        .stroke(SlipieColors.textSecondary.opacity(0.4), lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(SlipieColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? SlipieColors.accentEnd.opacity(0.5) : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
