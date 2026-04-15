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
