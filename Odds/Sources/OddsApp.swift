import SwiftUI

@main
struct OddsApp: App {
    @StateObject private var marketStore = MarketStore()
    @StateObject private var settings = SettingsStore()
    @StateObject private var alertManager = AlertManager()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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
            .environmentObject(alertManager)
            .onAppear {
                marketStore.bind(to: settings, alertManager: alertManager)
            }
        } label: {
            Image(nsImage: MenuBarIcon.statusImage(
                isLive: marketStore.isLive,
                trend: marketStore.overallTrend
            ))
        }
        .menuBarExtraStyle(.window)
    }
}

/// Hide from Dock — learned from upto's AppDelegate pattern
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
