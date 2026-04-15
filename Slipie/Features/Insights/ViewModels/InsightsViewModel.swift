import SwiftUI
import SlipieCoreKit

@MainActor
final class InsightsViewModel: ObservableObject {
    @Published var sessions: [SleepSessionRow] = []
    @Published var isLoading = false

    func loadSessions(using client: SlipieSupabaseClient) async {
        isLoading = true
        sessions = (try? await client.fetchSleepSessions()) ?? []
        isLoading = false
    }
}
