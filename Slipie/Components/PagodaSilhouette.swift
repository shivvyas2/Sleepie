import SwiftUI

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
