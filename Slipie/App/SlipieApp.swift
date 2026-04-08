import SwiftUI

enum AppFlowState {
    case splash
    case onboarding
    case main
}

@main
struct SlipieApp: App {
    @StateObject private var env = AppEnvironment()
    @State private var flowState: AppFlowState = .splash

    var body: some Scene {
        WindowGroup {
            Group {
                switch flowState {
                case .splash:
                    SplashView {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            flowState = .onboarding
                        }
                    }
                case .onboarding:
                    OnboardingView {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            flowState = .main
                        }
                    }
                case .main:
                    RootView()
                        .environmentObject(env)
                }
            }
            .background(SlipieColors.background.ignoresSafeArea())
            .preferredColorScheme(.dark)
        }
    }
}
