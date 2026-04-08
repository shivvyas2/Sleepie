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

struct SignInView: View {
    @EnvironmentObject var env: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ZStack {
                SlipieColors.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: SlipieSymbols.moon)
                        .font(.system(size: 52))
                        .foregroundStyle(SlipieColors.accentGradient)

                    Text("Welcome to Slipie")
                        .font(SlipieTypography.title())
                        .foregroundStyle(SlipieColors.textPrimary)

                    VStack(spacing: 12) {
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal, 24)

                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(SlipieColors.danger)
                            .font(SlipieTypography.caption())
                    }

                    PillButton(title: isLoading ? "Signing in..." : "Sign In", icon: SlipieSymbols.account, style: .filled) {
                        guard !isLoading else { return }
                        Task { await signIn() }
                    }
                    .disabled(isLoading)

                    Spacer()
                }
            }
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func signIn() async {
        isLoading = true
        errorMessage = nil
        do {
            try await env.supabaseClient.signIn(email: email, password: password)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
