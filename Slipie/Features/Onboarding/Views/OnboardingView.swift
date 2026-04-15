import SwiftUI

struct OnboardingView: View {
    var onFinished: () -> Void = {}
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        ZStack {
            SlipieColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                PageDotsView(count: 3, selected: 1)
                    .padding(.top, 60)
                    .padding(.bottom, 32)

                titleSection

                ScrollView(showsIndicators: false) {
                    GoalSelectionView(selectedGoals: $viewModel.selectedGoals)
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                        .padding(.bottom, 32)
                }

                continueButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }

    private var titleSection: some View {
        VStack(spacing: 4) {
            Text("Let's personalize your")
                .font(SlipieTypography.title)
                .foregroundStyle(SlipieColors.textPrimary)
            Text("experience")
                .font(SlipieTypography.title)
                .foregroundStyle(SlipieColors.accentEnd)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
    }

    private var continueButton: some View {
        Button {
            onFinished()
        } label: {
            Text("Continue")
                .font(SlipieTypography.headline)
                .foregroundStyle(SlipieColors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(SlipieColors.accentGradient)
                .clipShape(Capsule())
        }
    }
}
