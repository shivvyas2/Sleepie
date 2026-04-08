import SwiftUI

struct RootView: View {
    @EnvironmentObject var env: AppEnvironment

    var body: some View {
        TabView {
            HomeTabView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            LibraryTabView()
                .tabItem { Label("Library", systemImage: "books.vertical.fill") }

            CreateTabView()
                .tabItem { Label("Create", systemImage: "waveform.badge.plus") }

            AlarmTabView()
                .tabItem { Label("Alarm", systemImage: "alarm.fill") }

            AwardsTabView()
                .tabItem { Label("Awards", systemImage: "trophy.fill") }
        }
        .tint(SlipieColors.accentEnd)
    }
}

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
                        .font(SlipieTypography.title())
                        .foregroundStyle(SlipieColors.textPrimary)
                    Text("Custom soundscapes coming soon")
                        .font(SlipieTypography.body())
                        .foregroundStyle(SlipieColors.textSecondary)
                }
            }
            .navigationTitle("Create")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

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
                        .font(SlipieTypography.title())
                        .foregroundStyle(SlipieColors.textPrimary)
                    Text("Smart sleep alarms coming soon")
                        .font(SlipieTypography.body())
                        .foregroundStyle(SlipieColors.textSecondary)
                }
            }
            .navigationTitle("Alarm")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

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
                        .font(SlipieTypography.title())
                        .foregroundStyle(SlipieColors.textPrimary)
                    Text("Earn badges for healthy sleep habits")
                        .font(SlipieTypography.body())
                        .foregroundStyle(SlipieColors.textSecondary)
                }
            }
            .navigationTitle("Awards")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
