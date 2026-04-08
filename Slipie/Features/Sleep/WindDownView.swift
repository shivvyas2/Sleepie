import SwiftUI
import SlipieCoreKit

struct WindDownView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var timerMinutes = 30
    @State private var showTimerPicker = false

    var body: some View {
        ZStack {
            backgroundLayer
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    soundscapeSelector
                    timerSection
                    startButton
                }
                .padding(20)
            }
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            SlipieColors.background.ignoresSafeArea()
            RadialGradient(
                colors: [SlipieColors.accentStart.opacity(0.3), SlipieColors.background],
                center: .top,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: SlipieSymbols.moon)
                .font(.system(size: 52))
                .foregroundStyle(SlipieColors.accentGradient)
            Text("Ready to sleep?")
                .font(SlipieTypography.title())
                .foregroundStyle(SlipieColors.textPrimary)
            Text("Choose your soundscape and settle in")
                .font(SlipieTypography.body())
                .foregroundStyle(SlipieColors.textSecondary)
        }
        .padding(.top, 16)
    }

    private var soundscapeSelector: some View {
        GlowingCardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Soundscape")
                    .font(SlipieTypography.caption())
                    .foregroundStyle(SlipieColors.textSecondary)
                    .textCase(.uppercase)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Soundscape.all) { soundscape in
                            SoundscapeChip(
                                soundscape: soundscape,
                                isSelected: soundscape.id == env.selectedSoundscape.id
                            ) {
                                env.selectedSoundscape = soundscape
                            }
                        }
                    }
                }
            }
        }
    }

    private var timerSection: some View {
        GlowingCardView {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sleep Timer")
                        .font(SlipieTypography.caption())
                        .foregroundStyle(SlipieColors.textSecondary)
                        .textCase(.uppercase)
                    Text("\(timerMinutes) min")
                        .font(SlipieTypography.headline())
                        .foregroundStyle(SlipieColors.textPrimary)
                }
                Spacer()
                Image(systemName: SlipieSymbols.timer)
                    .foregroundStyle(SlipieColors.accentEnd)
                    .font(.title2)
            }
        }
        .onTapGesture { showTimerPicker = true }
        .sheet(isPresented: $showTimerPicker) {
            TimerPickerSheet(minutes: $timerMinutes)
        }
    }

    private var startButton: some View {
        PillButton(title: "Start Sleep", icon: SlipieSymbols.play, style: .filled) {
            env.startSession()
        }
        .frame(maxWidth: .infinity)
    }
}

struct SoundscapeChip: View {
    let soundscape: Soundscape
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(soundscape.name)
                .font(SlipieTypography.caption())
                .foregroundStyle(isSelected ? SlipieColors.textPrimary : SlipieColors.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        Capsule().fill(SlipieColors.accentGradient)
                    } else {
                        Capsule().fill(SlipieColors.surface)
                    }
                }
        }
    }
}

struct TimerPickerSheet: View {
    @Binding var minutes: Int
    @Environment(\.dismiss) private var dismiss
    private let options = [15, 20, 30, 45, 60, 90, 120]

    var body: some View {
        NavigationStack {
            List(options, id: \.self) { option in
                Button {
                    minutes = option
                    dismiss()
                } label: {
                    HStack {
                        Text("\(option) minutes")
                            .foregroundStyle(SlipieColors.textPrimary)
                        Spacer()
                        if option == minutes {
                            Image(systemName: "checkmark")
                                .foregroundStyle(SlipieColors.accentEnd)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(SlipieColors.background)
            .navigationTitle("Sleep Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
