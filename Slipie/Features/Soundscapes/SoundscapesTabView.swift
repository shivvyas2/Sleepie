import SwiftUI
import SlipieCoreKit

struct SoundscapesTabView: View {
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack {
                SlipieColors.background.ignoresSafeArea()
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Soundscape.all) { soundscape in
                            NavigationLink(destination: SoundscapeDetailView(soundscape: soundscape)) {
                                SoundscapeCard(soundscape: soundscape)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Soundscapes")
        }
    }
}

struct SoundscapeCard: View {
    let soundscape: Soundscape

    var body: some View {
        GlowingCardView {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: SlipieSymbols.soundscapes)
                    .font(.title)
                    .foregroundStyle(SlipieColors.accentGradient)
                Text(soundscape.name)
                    .font(SlipieTypography.headline())
                    .foregroundStyle(SlipieColors.textPrimary)
                Text(soundscape.description)
                    .font(SlipieTypography.caption())
                    .foregroundStyle(SlipieColors.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
