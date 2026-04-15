import SwiftUI
import SlipieCoreKit

struct HomeTabView: View {
    @EnvironmentObject var env: AppEnvironment
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundLayer.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    featuredCard
                    recentSection
                    windDownSection
                }
                .padding(.bottom, env.isSessionActive ? 80 : 24)
            }

            if env.isSessionActive {
                MiniPlayerView()
                    .environmentObject(env)
            }
        }
        .sheet(isPresented: $viewModel.showTimerPicker) {
            TimerPickerSheet(minutes: $viewModel.timerMinutes)
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            SlipieColors.background
            RadialGradient(
                colors: [SlipieColors.accentStart.opacity(0.3), SlipieColors.background],
                center: .top,
                startRadius: 0,
                endRadius: 400
            )
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.greeting)
                .font(SlipieTypography.title)
                .foregroundStyle(SlipieColors.textPrimary)
            Text("Ready for a restful night?")
                .font(SlipieTypography.body)
                .foregroundStyle(SlipieColors.textSecondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }

    private var featuredCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [SlipieColors.accentStart, SlipieColors.accentGlow.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 180)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.white.opacity(0.15))
                        .padding(20)
                }

            VStack(alignment: .leading, spacing: 12) {
                Text("Sleep Session")
                    .font(SlipieTypography.title2)
                    .foregroundStyle(SlipieColors.textPrimary)
                Text("Wind down and drift off")
                    .font(SlipieTypography.body)
                    .foregroundStyle(SlipieColors.textPrimary.opacity(0.8))

                Button {
                    if env.isSessionActive {
                        viewModel.endSession(using: env.sessionManager)
                    } else {
                        viewModel.startSession(using: env.sessionManager)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: env.isSessionActive ? SlipieSymbols.stop : SlipieSymbols.play)
                            .font(.system(size: 12, weight: .bold))
                        Text(env.isSessionActive ? "End Session" : "Start Session")
                            .font(SlipieTypography.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(SlipieColors.accentStart)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .clipShape(Capsule())
                }
            }
            .padding(20)
        }
        .padding(.horizontal, 20)
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent")
                .font(SlipieTypography.headline)
                .foregroundStyle(SlipieColors.textPrimary)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Soundscape.all.prefix(4)) { soundscape in
                        RecentSoundscapeCard(soundscape: soundscape)
                            .onTapGesture {
                                viewModel.selectSoundscape(soundscape, using: env.sessionManager)
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var windDownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wind Down")
                .font(SlipieTypography.headline)
                .foregroundStyle(SlipieColors.textPrimary)
                .padding(.horizontal, 20)

            soundscapeSelector
            timerCard
        }
    }

    private var soundscapeSelector: some View {
        GlowingCardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Soundscape")
                    .font(SlipieTypography.caption)
                    .foregroundStyle(SlipieColors.textSecondary)
                    .textCase(.uppercase)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Soundscape.all) { soundscape in
                            SoundscapeChip(
                                soundscape: soundscape,
                                isSelected: soundscape.id == env.selectedSoundscape.id
                            ) {
                                viewModel.selectSoundscape(soundscape, using: env.sessionManager)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var timerCard: some View {
        GlowingCardView {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sleep Timer")
                        .font(SlipieTypography.caption)
                        .foregroundStyle(SlipieColors.textSecondary)
                        .textCase(.uppercase)
                    Text("\(viewModel.timerMinutes) min")
                        .font(SlipieTypography.headline)
                        .foregroundStyle(SlipieColors.textPrimary)
                }
                Spacer()
                Image(systemName: SlipieSymbols.timer)
                    .foregroundStyle(SlipieColors.accentEnd)
                    .font(.title2)
            }
        }
        .padding(.horizontal, 20)
        .onTapGesture { viewModel.showTimerPicker = true }
    }
}
