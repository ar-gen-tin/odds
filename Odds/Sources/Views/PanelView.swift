import SwiftUI
import Combine

struct PanelView: View {
    @EnvironmentObject var store: MarketStore
    @EnvironmentObject var settings: SettingsStore
    @State private var showSettings = false
    @State private var showSearch = false
    @State private var searchQuery = ""
    @State private var apiResults: [SearchResult] = []
    @State private var isSearchingAPI = false
    @State private var searchTask: Task<Void, Never>?
    @State private var activeTab: MarketTab = .all
    @State private var expandedMarketId: String?

    // MARK: - Filtered Data

    private var displayedMarkets: [Market] {
        let markets: [Market] = {
            switch activeTab {
            case .all: return store.watchlist + store.trending
            case .trending: return store.trending
            case .politics: return (store.watchlist + store.trending).filter { $0.category.uppercased().contains("POLITIC") }
            case .crypto: return (store.watchlist + store.trending).filter { $0.category.uppercased().contains("CRYPTO") }
            case .watch: return store.watchlist
            }
        }()
        guard !searchQuery.isEmpty else { return markets }
        return markets.filter {
            $0.question.localizedCaseInsensitiveContains(searchQuery) ||
            $0.category.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    private var totalResults: Int { displayedMarkets.count + apiResults.count }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            StatusBarView(
                onSettingsTap: {
                    showSettings.toggle()
                    if showSettings { showSearch = false; searchQuery = "" }
                },
                onSearchTap: {
                    showSearch.toggle()
                    if !showSearch { searchQuery = ""; apiResults = [] }
                    showSettings = false
                },
                isSettingsActive: showSettings
            )

            if showSettings {
                SettingsView(isPresented: $showSettings)
            } else if showSearch {
                SearchBarView(
                    query: $searchQuery,
                    isActive: $showSearch,
                    apiResults: $apiResults,
                    isSearchingAPI: $isSearchingAPI
                )
                ColumnHeaderView()
                if !searchQuery.isEmpty && totalResults == 0 && !isSearchingAPI {
                    noResultsView
                } else {
                    searchResultsView
                }
            } else {
                TabBarView(activeTab: $activeTab)
                ColumnHeaderView()
                marketListView
            }

            FooterTickerView()
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
        .onExitCommand {
            if showSearch {
                searchQuery = ""; apiResults = []; showSearch = false
            } else if showSettings {
                showSettings = false
            }
        }
        .background {
            // ⌘Q to quit
            Button("") { NSApplication.shared.terminate(nil) }
                .keyboardShortcut("q", modifiers: .command)
                .frame(width: 0, height: 0)
                .opacity(0)
        }
    }

    // MARK: - Market List

    private var marketListView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                if activeTab == .all {
                    if !store.watchlist.isEmpty {
                        SectionDividerView(title: "WATCHLIST")
                        marketRows(store.watchlist, startIndex: 0)
                    }
                    if !store.trending.isEmpty {
                        SectionDividerView(title: "TRENDING")
                        marketRows(store.trending, startIndex: store.watchlist.count)
                    }
                } else {
                    marketRows(displayedMarkets, startIndex: 0)
                }

                if displayedMarkets.isEmpty {
                    emptyTabView
                }
            }
        }
    }

    @ViewBuilder
    private func marketRows(_ markets: [Market], startIndex: Int) -> some View {
        ForEach(Array(markets.enumerated()), id: \.element.id) { idx, market in
            VStack(spacing: 0) {
                MarketRowView(
                    market: market,
                    index: startIndex + idx,
                    isWatchlist: store.isInWatchlist(market.id),
                    isAlternate: idx % 2 == 1,
                    isExpanded: expandedMarketId == market.id,
                    onTap: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            expandedMarketId = expandedMarketId == market.id ? nil : market.id
                        }
                    },
                    onRemove: { store.removeFromWatchlist(id: market.id) }
                )

                if expandedMarketId == market.id {
                    ExpandedAreaView(
                        market: market,
                        isInWatchlist: store.isInWatchlist(market.id),
                        onOpenPoly: {
                            if let url = market.polymarketURL {
                                NSWorkspace.shared.open(url)
                            }
                        },
                        onWatchlist: {
                            if store.isInWatchlist(market.id) {
                                store.removeFromWatchlist(id: market.id)
                            } else {
                                // Re-add not supported from expanded area
                            }
                        }
                    )
                }
            }
        }
    }

    // MARK: - Search Results

    private var searchResultsView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(Array(displayedMarkets.enumerated()), id: \.element.id) { idx, market in
                    MarketRowView(market: market, index: idx, isAlternate: idx % 2 == 1)
                }

                if !apiResults.isEmpty {
                    SectionDividerView(title: "POLYMARKET")
                    ForEach(apiResults) { result in
                        SearchResultRowView(
                            result: result,
                            isInWatchlist: store.isInWatchlist(result.id),
                            onAdd: { store.addToWatchlist(result) }
                        )
                    }
                }

                if isSearchingAPI && apiResults.isEmpty {
                    Text("SEARCHING...")
                        .font(OddsFonts.tag)
                        .foregroundColor(OddsTheme.text3)
                        .tracking(1.2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                }
            }
        }
    }

    // MARK: - Empty States

    private var noResultsView: some View {
        VStack {
            Spacer()
            Text("NO_RESULTS")
                .font(OddsFonts.settingsHeader)
                .foregroundColor(OddsTheme.text3)
                .tracking(1.2)
            Spacer()
        }
    }

    private var emptyTabView: some View {
        Text("END_OF_LIST")
            .font(OddsFonts.tag)
            .foregroundColor(OddsTheme.text3)
            .tracking(1.2)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
    }

    // MARK: - API Search

    @MainActor
    private func performAPISearch(query: String) async {
        do {
            let results = try await PolymarketAPI.search(query: query)
            if searchQuery == query { apiResults = results }
        } catch {
            print("[odds] Search error: \(error)")
        }
        if searchQuery == query { isSearchingAPI = false }
    }
}
