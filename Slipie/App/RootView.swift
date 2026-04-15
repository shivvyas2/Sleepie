import SwiftUI

struct RootView: View {
    @EnvironmentObject var env: AppEnvironment

    var body: some View {
        TabView {
            HomeTabView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            SoundscapesTabView()
                .tabItem { Label("Sounds", systemImage: "waveform") }

            SleepTabView()
                .tabItem { Label("Sleep", systemImage: "moon.stars.fill") }

            InsightsTabView()
                .tabItem { Label("Insights", systemImage: "chart.xyaxis.line") }

            ProfileTabView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
        .tint(SlipieColors.accentEnd)
    }
}
