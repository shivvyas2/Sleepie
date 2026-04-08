import SwiftUI

struct StarParticle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
}

struct StarFieldView: View {
    let width: CGFloat
    let height: CGFloat
    let count: Int

    private let stars: [StarParticle]

    init(width: CGFloat, height: CGFloat, count: Int = 30) {
        self.width = width
        self.height = height
        self.count = count
        var generated: [StarParticle] = []
        var rng = SystemRandomNumberGenerator()
        for _ in 0..<count {
            let x = CGFloat.random(in: 0...width, using: &rng)
            let y = CGFloat.random(in: 0...height, using: &rng)
            let size = CGFloat.random(in: 1.5...3.5, using: &rng)
            let opacity = Double.random(in: 0.4...1.0, using: &rng)
            generated.append(StarParticle(x: x, y: y, size: size, opacity: opacity))
        }
        stars = generated
    }

    var body: some View {
        ZStack {
            ForEach(stars) { star in
                Circle()
                    .fill(Color.white.opacity(star.opacity))
                    .frame(width: star.size, height: star.size)
                    .position(x: star.x, y: star.y)
            }
        }
        .frame(width: width, height: height)
    }
}
