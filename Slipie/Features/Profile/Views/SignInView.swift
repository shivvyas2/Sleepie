import SwiftUI

struct SignInView: View {
    @EnvironmentObject var env: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SignInViewModel()

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
                        .font(SlipieTypography.title)
                        .foregroundStyle(SlipieColors.textPrimary)

                    VStack(spacing: 12) {
                        TextField("Email", text: $viewModel.email)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        SecureField("Password", text: $viewModel.password)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal, 24)

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(SlipieColors.danger)
                            .font(SlipieTypography.caption)
                    }

                    PillButton(title: viewModel.isLoading ? "Signing in..." : "Sign In", icon: SlipieSymbols.account, style: .filled) {
                        guard !viewModel.isLoading else { return }
                        Task {
                            if await viewModel.signIn(using: env.supabaseClient) {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isLoading)

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
}
