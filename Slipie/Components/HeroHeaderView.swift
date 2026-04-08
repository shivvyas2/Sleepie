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

struct MoonView: View {
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [Color(hex: "#FF6B35"), Color(hex: "#FF3D00")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .shadow(color: Color(hex: "#FF6B35").opacity(0.6), radius: 16, x: 0, y: 0)
    }
}

struct PagodaSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        let tiers = 4
        let baseWidth = w
        let baseHeight = h * 0.18
        let tierShrink: CGFloat = 0.75

        var currentY = h
        var currentWidth = baseWidth

        for i in 0..<tiers {
            let tierH = baseHeight * pow(0.88, CGFloat(i))
            let tierW = currentWidth
            let x = (w - tierW) / 2

            path.addRect(CGRect(x: x, y: currentY - tierH, width: tierW, height: tierH))

            let roofW = tierW * 1.15
            let roofH = tierH * 0.4
            let roofX = (w - roofW) / 2
            let roofY = currentY - tierH - roofH

            path.move(to: CGPoint(x: roofX, y: currentY - tierH))
            path.addLine(to: CGPoint(x: roofX + roofW, y: currentY - tierH))
            path.addLine(to: CGPoint(x: w / 2, y: roofY))
            path.closeSubpath()

            currentY = currentY - tierH - roofH
            currentWidth = tierW * tierShrink
        }

        let spireH = h * 0.1
        let spireW: CGFloat = 4
        path.addRect(CGRect(x: (w - spireW) / 2, y: currentY - spireH, width: spireW, height: spireH))

        return path
    }
}
