import SwiftUI
import Combine

struct PanelView: View {
    @EnvironmentObject var store: MarketStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var watchlist: WatchlistStore
    @State private var showSettings = false
    @State private var showSearch = false
    @State private var searchQuery = ""
    @State private var apiResults: [SearchResult] = []
    @State private var isSearchingAPI = false
    @State private var searchTask: Task<Void, Never>?

    private var lang: AppLanguage { settings.language }

    private var filteredWatchlist: [Market] {
        guard !searchQuery.isEmpty else { return store.watchlist }
        return store.watchlist.filter { matchesSearch($0.question, $0.category) }
    }

    private var filteredTrending: [Market] {
        guard !searchQuery.isEmpty else { return store.trending }
        return store.trending.filter { matchesSearch($0.question, $0.category) }
    }

    private var showMultiOutcome: Bool {
        guard let multi = store.multiOutcome else { return false }
        if searchQuery.isEmpty { return true }
        return matchesSearch(multi.question, multi.category) ||
               multi.outcomes.contains { $0.name.localizedCaseInsensitiveContains(searchQuery) }
    }

    private var localResults: Int {
        filteredWatchlist.count + filteredTrending.count + (showMultiOutcome ? 1 : 0)
    }

    private var totalResults: Int {
        localResults + apiResults.count
    }

    private func matchesSearch(_ texts: String...) -> Bool {
        texts.contains { $0.localizedCaseInsensitiveContains(searchQuery) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                showSearch: $showSearch,
                showSettings: $showSettings,
                searchQuery: $searchQuery
            )

            if showSettings {
                SettingsView(isPresented: $showSettings)
            } else {
                if showSearch {
                    SearchBarView(
                        query: $searchQuery,
                        isActive: $showSearch,
                        apiResults: $apiResults,
                        isSearchingAPI: $isSearchingAPI
                    )
                }

                ColumnHeaderView()

                if !searchQuery.isEmpty && totalResults == 0 && !isSearchingAPI {
                    noResultsView
                } else {
                    marketListView
                }
            }

            FooterView(
                isSearching: showSearch && !searchQuery.isEmpty,
                resultCount: totalResults
            )
        }
        .frame(width: OddsTheme.panelWidth, height: OddsTheme.panelHeight)
        .background(OddsTheme.bg)
        .preferredColorScheme(.dark)
        .onChange(of: searchQuery) {
            let q = searchQuery
            searchTask?.cancel()
            if q.count >= 2 {
                isSearchingAPI = true
                searchTask = Task {
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    guard !Task.isCancelled else { return }
                    await performAPISearch(query: q)
                }
            } else {
                apiResults = []
                isSearchingAPI = false
            }
        }
    }

    private var marketListView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                // Watchlist
                if !filteredWatchlist.isEmpty {
                    SectionDividerView(title: L10n.string(.watchlist, lang: lang))
                    ForEach(Array(filteredWatchlist.enumerated()), id: \.element.id) { idx, market in
                        MarketRowView(
                            market: market,
                            index: idx,
                            isWatchlist: true,
                            isAlternate: idx % 2 == 1,
                            onRemove: { store.removeFromWatchlist(id: market.id) }
                        )
                    }
                }

                // Multi-outcome
                if showMultiOutcome, let multi = store.multiOutcome {
                    MultiOutcomeRowView(market: multi)
                }

                // Trending
                if !filteredTrending.isEmpty {
                    SectionDividerView(title: L10n.string(.trending, lang: lang))
                    ForEach(Array(filteredTrending.enumerated()), id: \.element.id) { idx, market in
                        MarketRowView(
                            market: market,
                            index: idx,
                            isAlternate: idx % 2 == 1
                        )
                    }
                }

                // API search results
                if !apiResults.isEmpty {
                    SectionDividerView(title: "POLYMARKET")
                    ForEach(apiResults) { result in
                        SearchResultRowView(
                            result: result,
                            isInWatchlist: watchlist.contains(result.id),
                            onAdd: {
                                watchlist.add(result.id)
                                store.addToWatchlistFromSearch(result)
                            }
                        )
                    }
                }

                // Loading indicator
                if isSearchingAPI && apiResults.isEmpty {
                    SectionDividerView(title: "POLYMARKET")
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.6)
                        Text("Searching...")
                            .font(.system(size: 12))
                            .foregroundColor(OddsTheme.text3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            }
        }
    }

    private var noResultsView: some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 24))
                    .foregroundColor(OddsTheme.text3.opacity(0.3))
                Text(L10n.string(.noResults, lang: lang))
                    .font(.system(size: 13))
                    .foregroundColor(OddsTheme.text3)
                Text(L10n.string(.tryDifferent, lang: lang))
                    .font(.system(size: 12))
                    .foregroundColor(OddsTheme.text3.opacity(0.6))
            }
            Spacer()
        }
    }

    @MainActor
    private func performAPISearch(query: String) async {
        do {
            let results = try await PolymarketAPI.search(query: query)
            if searchQuery == query {
                apiResults = results
            }
        } catch {
            print("[odds] Search error: \(error)")
        }
        if searchQuery == query {
            isSearchingAPI = false
        }
    }
}
