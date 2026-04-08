import SwiftUI

struct SleepTabView: View {
    @EnvironmentObject var env: AppEnvironment

    var body: some View {
        NavigationStack {
            if env.isSessionActive {
                ActiveSessionView()
                    .navigationTitle("Active Session")
                    .navigationBarTitleDisplayMode(.inline)
            } else {
                WindDownView()
                    .navigationTitle("Wind Down")
            }
        }
    }
}
