import SwiftUI
import Combine

@MainActor
final class MarketStore: ObservableObject {
    @Published var watchlist: [Market] = []
    @Published var trending: [Market] = []
    @Published var lastUpdated: Date = Date()
    @Published var isLive: Bool = false
    @Published var error: String?

    private var watchlistIDs: Set<String> = [] {
        didSet { UserDefaults.standard.set(Array(watchlistIDs), forKey: "watchlist_ids") }
    }

    private var timer: AnyCancellable?
    private var settingsCancellable: AnyCancellable?
    private var isBound = false

    var marketCount: Int { watchlist.count + trending.count }

    // MARK: - Init (load persisted data)

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: "watchlist_ids") ?? []
        self.watchlistIDs = Set(saved)
        loadPersistedWatchlist()
        // Load mock data as fallback until first API call
        if watchlist.isEmpty {
            watchlist = MockData.watchlistMarkets
        }
        // Sync watchlistIDs with watchlist array
        for market in watchlist {
            watchlistIDs.insert(market.id)
        }
        trending = MockData.trendingMarkets
    }

    // MARK: - Bind to settings (防重入)

    func bind(to settings: SettingsStore) {
        guard !isBound else { return }
        isBound = true
        settingsCancellable = settings.$refreshInterval
            .removeDuplicates()
            .sink { [weak self] interval in
                self?.restartTimer(interval: interval)
            }
        // Initial fetch
        Task { await fetchData() }
    }

    private func restartTimer(interval: Double) {
        timer?.cancel()
        timer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { [weak self] in await self?.fetchData() }
            }
    }

    // MARK: - Fetch real data

    func fetchData() async {
        do {
            let markets = try await PolymarketAPI.fetchTrending(limit: 15)
            if !markets.isEmpty {
                trending = markets
                refreshWatchlistPrices(from: markets)
                isLive = true
                error = nil
            }
            lastUpdated = Date()
        } catch {
            self.error = error.localizedDescription
            isLive = false
        }
    }

    /// Sync watchlist prices with latest trending data
    private func refreshWatchlistPrices(from fresh: [Market]) {
        let freshById = Dictionary(fresh.map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })
        var updated = false
        for i in watchlist.indices {
            if let match = freshById[watchlist[i].id] {
                watchlist[i].yesPrice = match.yesPrice
                watchlist[i].oneDayChange = match.oneDayChange
                watchlist[i].volume24h = match.volume24h
                watchlist[i].priceHistory = match.priceHistory
                watchlist[i].lastUpdated = match.lastUpdated
                updated = true
            }
        }
        if updated { persistWatchlist() }
    }

    func refresh() {
        Task { await fetchData() }
    }

    // MARK: - Watchlist

    func isInWatchlist(_ id: String) -> Bool {
        watchlistIDs.contains(id)
    }

    static let watchlistLimit = 50

    @discardableResult
    func addToWatchlist(_ market: Market) -> Bool {
        guard !watchlist.contains(where: { $0.id == market.id }) else { return false }
        guard watchlist.count < Self.watchlistLimit else { return false }
        guard market.yesPrice > 0.01 && market.yesPrice < 0.99 else { return false }
        // Rule 7: Guard NaN/Inf prices
        var safe = market
        safe.yesPrice = Fmt.safePrice(market.yesPrice)
        safe.oneDayChange = market.oneDayChange.isFinite ? market.oneDayChange : 0
        watchlistIDs.insert(safe.id)
        withAnimation(.easeIn(duration: 0.2)) {
            watchlist.append(safe)
        }
        persistWatchlist()
        return true
    }

    func removeFromWatchlist(id: String) {
        watchlistIDs.remove(id)
        withAnimation(.easeOut(duration: 0.2)) {
            watchlist.removeAll { $0.id == id }
        }
        persistWatchlist()
    }

    // MARK: - Persistence (Codable)

    private func persistWatchlist() {
        if let data = try? JSONEncoder().encode(watchlist) {
            UserDefaults.standard.set(data, forKey: "watchlist_data")
        }
    }

    private func loadPersistedWatchlist() {
        guard let data = UserDefaults.standard.data(forKey: "watchlist_data"),
              let markets = try? JSONDecoder().decode([Market].self, from: data) else { return }
        watchlist = markets
    }

    deinit {
        timer?.cancel()
        settingsCancellable?.cancel()
    }
}
