import SwiftUI
import SlipieCoreKit

struct SoundscapeSelectorView: View {
    @Binding var selectedSoundscape: Soundscape

    var body: some View {
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
                                isSelected: soundscape.id == selectedSoundscape.id
                            ) {
                                selectedSoundscape = soundscape
                            }
                        }
                    }
                }
            }
        }
    }
}
