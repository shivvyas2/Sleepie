import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var selectedGoals: Set<Int> = []

    func toggleGoal(_ id: Int) {
        if selectedGoals.contains(id) {
            selectedGoals.remove(id)
        } else {
            selectedGoals.insert(id)
        }
    }
}
