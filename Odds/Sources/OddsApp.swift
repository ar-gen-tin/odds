import SwiftUI

@main
struct OddsApp: App {
    @StateObject private var marketStore = MarketStore()
    @StateObject private var settings = SettingsStore()

    init() {
        OddsFonts.registerFonts()
    }

    var body: some Scene {
        MenuBarExtra {
            Group {
                if settings.hasCompletedOnboarding {
                    PanelView()
                } else {
                    OnboardingView {
                        settings.hasCompletedOnboarding = true
                    }
                }
            }
            .environmentObject(marketStore)
            .environmentObject(settings)
            .onAppear {
                marketStore.bind(to: settings)
            }
        } label: {
            Image(systemName: "dice")
                .symbolRenderingMode(.hierarchical)
        }
        .menuBarExtraStyle(.window)
    }
}
