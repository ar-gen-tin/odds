import SwiftUI

@main
struct OddsApp: App {
    @StateObject private var marketStore = MarketStore()
    @StateObject private var settings = SettingsStore()
    // A2: WatchlistStore removed — MarketStore is single source of truth

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
            // WatchlistStore removed — using MarketStore directly
            .onAppear {
                marketStore.bind(to: settings)
            }
        } label: {
            menuBarLabel
        }
        .menuBarExtraStyle(.window)
    }

    private var menuBarLabel: some View {
        Group {
            if let url = Bundle.module.url(forResource: "menubar_icon", withExtension: "png", subdirectory: "MenuBarIcon"),
               let nsImage = NSImage(contentsOf: url) {
                let _ = {
                    nsImage.isTemplate = true
                    nsImage.size = NSSize(width: 18, height: 18)
                }()
                Image(nsImage: nsImage)
            } else {
                Image(systemName: "square.grid.3x3.fill")
                    .symbolRenderingMode(.hierarchical)
            }
        }
    }
}
