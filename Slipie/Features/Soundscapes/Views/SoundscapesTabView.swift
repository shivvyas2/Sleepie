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
