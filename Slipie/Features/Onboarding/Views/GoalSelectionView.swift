import SwiftUI

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
                    .font(SlipieTypography.body)
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
