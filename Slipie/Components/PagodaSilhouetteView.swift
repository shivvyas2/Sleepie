import SwiftUI

struct PagodaSilhouetteView: View {
    var body: some View {
        PagodaSilhouette()
            .fill(SlipieColors.surface.opacity(0.65))
            .frame(width: 120, height: 180)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 20)
    }
}
