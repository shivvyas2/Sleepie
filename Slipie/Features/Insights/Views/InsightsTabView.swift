import SwiftUI
import SlipieCoreKit

struct InsightsTabView: View {
    @EnvironmentObject var env: AppEnvironment
    @StateObject private var viewModel = InsightsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                SlipieColors.background.ignoresSafeArea()
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(SlipieColors.accentEnd)
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                SleepScoreCard(score: viewModel.sessions.first?.sleepScore)
                                sessionsList
                            }
                            .padding(16)
                        }
                    }
                }
            }
            .navigationTitle("Insights")
            .task { await viewModel.loadSessions(using: env.supabaseClient) }
        }
    }

    @ViewBuilder
    private var sessionsList: some View {
        if viewModel.sessions.isEmpty {
            GlowingCardView {
                VStack(spacing: 12) {
                    Image(systemName: "moon.zzz.fill")
                        .font(.largeTitle)
                        .foregroundStyle(SlipieColors.accentGlow)
                    Text("No sleep data yet")
                        .font(SlipieTypography.headline)
                        .foregroundStyle(SlipieColors.textPrimary)
                    Text("Start your first sleep session to see insights here")
                        .font(SlipieTypography.caption)
                        .foregroundStyle(SlipieColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
            }
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Sessions")
                    .font(SlipieTypography.caption)
                    .foregroundStyle(SlipieColors.textSecondary)
                    .textCase(.uppercase)
                    .padding(.leading, 4)
                ForEach(viewModel.sessions, id: \.id) { session in
                    SessionRowView(session: session)
                }
            }
        }
    }

}
