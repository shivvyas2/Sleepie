import SwiftUI

struct SlipieBackgroundView: View {
    var body: some View {
        ZStack {
            SlipieColors.background
            RadialGradient(
                colors: [SlipieColors.accentStart.opacity(0.3), SlipieColors.background],
                center: .top,
                startRadius: 0,
                endRadius: 400
            )
        }
        .ignoresSafeArea()
    }
}
