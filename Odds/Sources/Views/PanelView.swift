import SwiftUI
import Combine

struct PanelView: View {
    @EnvironmentObject var store: MarketStore
    @EnvironmentObject var settings: SettingsStore
    @State private var showSettings = false
    @State private var showSearch = false
    @State private var searchQuery = ""
    @State private var apiResults: [Market] = []
    @State private var isSearchingAPI = false
    @State private var searchError: String?
    @FocusState private var isSearchFieldFocused: Bool
    @State private var searchTask: Task<Void, Never>?
    @State private var activeTab: MarketTab = .all
    @State private var expandedMarketId: String?

    // MARK: - Filtered Data

    /// Trending items excluding those already in watchlist
    private var dedupedTrending: [Market] {
        let watchIDs = Set(store.watchlist.map(\.id))
        return store.trending.filter { !watchIDs.contains($0.id) }
    }

    private var displayedMarkets: [Market] {
        let markets: [Market] = {
            switch activeTab {
            case .all: return store.watchlist + dedupedTrending
            case .trending: return store.trending
            case .politics: return (store.watchlist + dedupedTrending).filter { $0.category.uppercased().contains("POLITIC") }
            case .crypto: return (store.watchlist + dedupedTrending).filter { $0.category.uppercased().contains("CRYPTO") }
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
            // C1: Cmd+F search shortcut
            Button("") {
                showSearch = true
                showSettings = false
            }
            .keyboardShortcut("f", modifiers: .command)
            .frame(width: 0, height: 0)
            .opacity(0)

            Button("") { NSApplication.shared.terminate(nil) }
                .keyboardShortcut("q", modifiers: .command)
                .frame(width: 0, height: 0)
                .opacity(0)
        }
        .onDisappear { searchTask?.cancel() }
        .onChange(of: activeTab) { expandedMarketId = nil }
    }

    // MARK: - Market List

    private var marketListView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                if activeTab == .all {
                    if !store.watchlist.isEmpty {
                        SectionDividerView(title: L10n.s(.watchlist, settings.language))
                        marketRows(store.watchlist, startIndex: 0)
                    }
                    if !dedupedTrending.isEmpty {
                        SectionDividerView(title: L10n.s(.trending, settings.language))
                        marketRows(dedupedTrending, startIndex: store.watchlist.count)
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
                    onRemove: {
                        if expandedMarketId == market.id { expandedMarketId = nil }
                        store.removeFromWatchlist(id: market.id)
                    }
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
                        // B10: Add/remove from expanded area
                        onWatchlist: {
                            if store.isInWatchlist(market.id) {
                                store.removeFromWatchlist(id: market.id)
                            } else {
                                store.addToWatchlist(market)
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
                    ForEach(Array(apiResults.enumerated()), id: \.element.id) { idx, market in
                        MarketRowView(
                            market: market,
                            index: idx,
                            isWatchlist: store.isInWatchlist(market.id),
                            isAlternate: idx % 2 == 1,
                            showAddButton: true,
                            onTap: {
                                if !store.isInWatchlist(market.id) {
                                    store.addToWatchlist(market)
                                }
                            },
                            onRemove: { store.removeFromWatchlist(id: market.id) }
                        )
                    }
                }

                if let error = searchError {
                    Text("ERR: \(error)")
                        .font(OddsFonts.tag)
                        .foregroundColor(OddsTheme.downRed)
                        .tracking(1.2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                } else if isSearchingAPI && apiResults.isEmpty {
                    Text(L10n.s(.searching, settings.language))
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
            Text(L10n.s(.noResults, settings.language))
                .font(OddsFonts.settingsHeader)
                .foregroundColor(OddsTheme.text3)
                .tracking(1.2)
            Spacer()
        }
    }

    private var emptyTabView: some View {
        VStack(spacing: 8) {
            Text(emptyTitle)
                .font(OddsFonts.settingsHeader)
                .foregroundColor(OddsTheme.text3)
                .tracking(1.2)
            if activeTab == .watch {
                Text(emptyHint)
                    .font(OddsFonts.footerText)
                    .foregroundColor(OddsTheme.text3.opacity(0.6))
                    .tracking(0.6)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var emptyTitle: String {
        switch activeTab {
        case .watch: return "EMPTY_WATCHLIST"
        case .politics: return "NO_POLITICS"
        case .crypto: return "NO_CRYPTO"
        default: return L10n.s(.endOfList, settings.language)
        }
    }

    private var emptyHint: String {
        switch settings.language {
        case .en: return "> use search to find and add markets"
        case .zh: return "> 使用搜索查找并添加市场"
        case .ja: return "> 検索で市場を見つけて追加"
        }
    }

    // MARK: - API Search

    @MainActor
    private func performAPISearch(query: String) async {
        searchError = nil
        do {
            let results = try await PolymarketAPI.search(query: query)
            if searchQuery == query {
                apiResults = results
                searchError = nil
            }
        } catch is CancellationError {
            // B6: Reset loading on cancel
            if searchQuery == query { isSearchingAPI = false }
        } catch {
            if searchQuery == query {
                searchError = error.localizedDescription
            }
        }
        if searchQuery == query { isSearchingAPI = false }
    }
}
