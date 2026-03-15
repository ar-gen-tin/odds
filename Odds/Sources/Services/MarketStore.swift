import SwiftUI
import Combine

final class MarketStore: ObservableObject {
    @Published var watchlist: [Market] = MockData.watchlistMarkets
    @Published var trending: [Market] = MockData.trendingMarkets
    @Published var lastUpdated: Date = Date()
    @Published var isLive: Bool = true

    /// Persisted watchlist IDs (single source of truth)
    @Published private(set) var watchlistIDs: Set<String> = [] {
        didSet { UserDefaults.standard.set(Array(watchlistIDs), forKey: "watchlist_ids") }
    }

    private var timer: AnyCancellable?
    private var settingsCancellable: AnyCancellable?

    var marketCount: Int { watchlist.count + trending.count }

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: "watchlist_ids") ?? []
        self.watchlistIDs = Set(saved)
    }

    func bind(to settings: SettingsStore) {
        settingsCancellable = settings.$refreshInterval
            .removeDuplicates()
            .sink { [weak self] interval in
                self?.restartTimer(interval: interval)
            }
    }

    private func restartTimer(interval: Double) {
        timer?.cancel()
        timer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refresh()
            }
    }

    func refresh() {
        // TODO: Replace with Gamma API call
        lastUpdated = Date()
    }

    // MARK: - Watchlist (single source of truth)

    func isInWatchlist(_ id: String) -> Bool {
        watchlistIDs.contains(id)
    }

    func addToWatchlist(_ result: SearchResult) {
        guard !watchlist.contains(where: { $0.id == result.id }) else { return }
        watchlistIDs.insert(result.id)

        let firstMarket = result.markets.first
        let market = Market(
            id: result.id,
            question: result.title,
            category: result.category.isEmpty ? "POLYMARKET" : result.category.uppercased(),
            slug: result.slug,
            yesPrice: firstMarket?.yesPrice ?? 0,
            oneDayChange: firstMarket?.oneDayPriceChange ?? 0,
            volume24h: result.volume,
            priceHistory: [firstMarket?.yesPrice ?? 0]
        )

        withAnimation(.easeIn(duration: 0.2)) {
            watchlist.append(market)
        }
    }

    func removeFromWatchlist(id: String) {
        watchlistIDs.remove(id)
        withAnimation(.easeOut(duration: 0.2)) {
            watchlist.removeAll { $0.id == id }
        }
    }

    deinit {
        timer?.cancel()
        settingsCancellable?.cancel()
    }
}
