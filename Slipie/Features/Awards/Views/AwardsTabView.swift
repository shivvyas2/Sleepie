import SwiftUI

struct AwardsTabView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                SlipieColors.background.ignoresSafeArea()
                VStack(spacing: 24) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(SlipieColors.accentGradient)
                    Text("Awards")
                        .font(SlipieTypography.title)
                        .foregroundStyle(SlipieColors.textPrimary)
                    Text("Earn badges for healthy sleep habits")
                        .font(SlipieTypography.body)
                        .foregroundStyle(SlipieColors.textSecondary)
                }
            }
            .navigationTitle("Awards")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
