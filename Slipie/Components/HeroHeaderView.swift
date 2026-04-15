import SwiftUI

struct HeroHeaderView: View {
    var height: CGFloat = 240

    var body: some View {
        GeometryReader { geo in
            ZStack {
                SlipieColors.background

                RadialGradient(
                    colors: [
                        SlipieColors.accentStart.opacity(0.6),
                        SlipieColors.accentGlow.opacity(0.3),
                        SlipieColors.background
                    ],
                    center: .top,
                    startRadius: 0,
                    endRadius: geo.size.height * 1.2
                )

                StarFieldView(width: geo.size.width, height: geo.size.height, count: 25)

                PagodaSilhouette()
                    .fill(SlipieColors.surface.opacity(0.7))
                    .frame(width: 80, height: 120)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.trailing, 32)

                MoonView(size: 50)
                    .offset(y: geo.size.height * 0.25 - geo.size.height / 2 + 40)
            }
        }
        .frame(height: height)
        .clipped()
    }
}
