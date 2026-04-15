import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void = {}

    var body: some View {
        GeometryReader { geo in
            ZStack {
                SlipieColors.background.ignoresSafeArea()

                RadialGradient(
                    colors: [
                        SlipieColors.accentGlow.opacity(0.5),
                        SlipieColors.accentStart.opacity(0.3),
                        SlipieColors.background
                    ],
                    center: UnitPoint(x: 0.5, y: 0.0),
                    startRadius: 0,
                    endRadius: geo.size.height * 0.65
                )
                .ignoresSafeArea()

                StarFieldView(
                    width: geo.size.width,
                    height: geo.size.height * 0.65,
                    count: 40
                )
                .frame(maxHeight: .infinity, alignment: .top)

                VStack(spacing: 0) {
                    ZStack {
                        PagodaSilhouetteView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                        MoonView(size: 60)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .padding(.top, geo.size.height * 0.08)
                    }
                    .frame(height: geo.size.height * 0.55)

                    bottomSection
                        .frame(height: geo.size.height * 0.45)
                }
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            onFinished()
        }
    }

    private var bottomSection: some View {
        VStack(spacing: 16) {
            Text("Slipie")
                .font(.system(size: 42, weight: .bold, design: .serif))
                .italic()
                .foregroundStyle(SlipieColors.textPrimary)

            Text("Try bedtime stories, sleep sounds & meditations to help you fall asleep fast.")
                .font(SlipieTypography.body)
                .foregroundStyle(SlipieColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            PageDotsView(count: 3, selected: 0)
                .padding(.top, 8)

            Spacer()
        }
        .padding(.top, 32)
    }
}
