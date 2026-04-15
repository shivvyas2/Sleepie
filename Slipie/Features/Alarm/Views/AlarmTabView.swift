import SwiftUI

struct AlarmTabView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                SlipieColors.background.ignoresSafeArea()
                VStack(spacing: 24) {
                    Image(systemName: "alarm.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(SlipieColors.accentGradient)
                    Text("Alarm")
                        .font(SlipieTypography.title)
                        .foregroundStyle(SlipieColors.textPrimary)
                    Text("Smart sleep alarms coming soon")
                        .font(SlipieTypography.body)
                        .foregroundStyle(SlipieColors.textSecondary)
                }
            }
            .navigationTitle("Alarm")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
