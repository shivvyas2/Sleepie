import SwiftUI
import SlipieCoreKit

@MainActor
final class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoading = false

    func signIn(using client: SlipieSupabaseClient) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            try await client.signIn(email: email, password: password)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}
