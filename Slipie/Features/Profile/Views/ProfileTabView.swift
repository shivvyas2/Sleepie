import SwiftUI

struct ProfileTabView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var showSignIn = false

    var body: some View {
        NavigationStack {
            ZStack {
                SlipieColors.background.ignoresSafeArea()
                List {
                    accountSection
                    watchSection
                    appSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showSignIn) {
                SignInView()
                    .environmentObject(env)
            }
        }
    }

    private var accountSection: some View {
        Section("Account") {
            if let user = env.supabaseClient.currentUser {
                Label(user.email ?? "Signed in", systemImage: SlipieSymbols.account)
                    .foregroundStyle(SlipieColors.textPrimary)
                Button(role: .destructive) {
                    Task { try? await env.supabaseClient.signOut() }
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            } else {
                Button { showSignIn = true } label: {
                    Label("Sign In", systemImage: SlipieSymbols.account)
                }
            }
        }
    }

    private var watchSection: some View {
        Section("Apple Watch") {
            Label("Pair Apple Watch", systemImage: SlipieSymbols.watch)
                .foregroundStyle(SlipieColors.textPrimary)
        }
    }

    private var appSection: some View {
        Section("App") {
            Label("Notifications", systemImage: SlipieSymbols.notifications)
                .foregroundStyle(SlipieColors.textPrimary)
            Label("Privacy", systemImage: SlipieSymbols.privacy)
                .foregroundStyle(SlipieColors.textPrimary)
        }
    }
}
