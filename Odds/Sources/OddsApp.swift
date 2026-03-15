import SwiftUI

@main
struct OddsApp: App {
    @StateObject private var marketStore = MarketStore()
    @StateObject private var settings = SettingsStore()
    @StateObject private var watchlist = WatchlistStore()

    init() {
        OddsFonts.registerFonts()
    }

    var body: some Scene {
        MenuBarExtra {
            PanelView()
                .environmentObject(marketStore)
                .environmentObject(settings)
                .environmentObject(watchlist)
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
