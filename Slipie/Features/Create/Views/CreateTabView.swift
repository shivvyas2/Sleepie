import SwiftUI

struct CreateTabView: View {
    @EnvironmentObject var env: AppEnvironment

    var body: some View {
        NavigationStack {
            ZStack {
                SlipieColors.background.ignoresSafeArea()
                VStack(spacing: 24) {
                    Image(systemName: "waveform.badge.plus")
                        .font(.system(size: 52))
                        .foregroundStyle(SlipieColors.accentGradient)
                    Text("Create")
                        .font(SlipieTypography.title)
                        .foregroundStyle(SlipieColors.textPrimary)
                    Text("Custom soundscapes coming soon")
                        .font(SlipieTypography.body)
                        .foregroundStyle(SlipieColors.textSecondary)
                }
            }
            .navigationTitle("Create")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
