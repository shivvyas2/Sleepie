import SwiftUI
import SlipieCoreKit

struct InsightsTabView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var sessions: [SleepSessionRow] = []
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ZStack {
                SlipieColors.background.ignoresSafeArea()
                Group {
                    if isLoading {
                        ProgressView()
                            .tint(SlipieColors.accentEnd)
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                SleepScoreCard(score: sessions.first?.sleepScore)
                                sessionsList
                            }
                            .padding(16)
                        }
                    }
                }
            }
            .navigationTitle("Insights")
            .task { await loadSessions() }
        }
    }

    @ViewBuilder
    private var sessionsList: some View {
        if sessions.isEmpty {
            GlowingCardView {
                VStack(spacing: 12) {
                    Image(systemName: "moon.zzz.fill")
                        .font(.largeTitle)
                        .foregroundStyle(SlipieColors.accentGlow)
                    Text("No sleep data yet")
                        .font(SlipieTypography.headline())
                        .foregroundStyle(SlipieColors.textPrimary)
                    Text("Start your first sleep session to see insights here")
                        .font(SlipieTypography.caption())
                        .foregroundStyle(SlipieColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
            }
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Sessions")
                    .font(SlipieTypography.caption())
                    .foregroundStyle(SlipieColors.textSecondary)
                    .textCase(.uppercase)
                    .padding(.leading, 4)
                ForEach(sessions, id: \.id) { session in
                    SessionRowView(session: session)
                }
            }
        }
    }

    private func loadSessions() async {
        isLoading = true
        sessions = (try? await env.supabaseClient.fetchSleepSessions()) ?? []
        isLoading = false
    }
}

struct SleepScoreCard: View {
    let score: Int?

    var body: some View {
        GlowingCardView {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sleep Score")
                        .font(SlipieTypography.caption())
                        .foregroundStyle(SlipieColors.textSecondary)
                        .textCase(.uppercase)
                    Text(score.map { "\($0)" } ?? "--")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(scoreColor)
                }
                Spacer()
                Image(systemName: SlipieSymbols.score)
                    .font(.system(size: 40))
                    .foregroundStyle(SlipieColors.accentGradient)
            }
        }
    }

    private var scoreColor: Color {
        guard let score else { return SlipieColors.textSecondary }
        switch score {
        case 80...100: return SlipieColors.success
        case 50...79: return SlipieColors.accentEnd
        default: return SlipieColors.danger
        }
    }
}

struct SessionRowView: View {
    let session: SleepSessionRow

    var body: some View {
        GlowingCardView {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.startedAt, style: .date)
                        .font(SlipieTypography.headline())
                        .foregroundStyle(SlipieColors.textPrimary)
                    if let score = session.sleepScore {
                        Text("Score: \(score)")
                            .font(SlipieTypography.caption())
                            .foregroundStyle(SlipieColors.textSecondary)
                    }
                }
                Spacer()
                Image(systemName: SlipieSymbols.trend)
                    .foregroundStyle(SlipieColors.accentEnd)
            }
        }
    }
}
