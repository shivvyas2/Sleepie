import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var selectedGoals: Set<Int> = []
}
