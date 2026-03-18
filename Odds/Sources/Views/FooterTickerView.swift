import SwiftUI

struct FooterTickerView: View {
    @EnvironmentObject var store: MarketStore
    @EnvironmentObject var settings: SettingsStore
    @State private var cachedTicker: String = ""
    @State private var textWidth: CGFloat = 400
    // C8: Pause when not visible
    @State private var isVisible = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                TimelineView(.animation(minimumInterval: 1.0 / 12.0, paused: !isVisible)) { timeline in
                    let speed: Double = 25
                    let halfWidth = max(textWidth / 2, 1)
                    let now = timeline.date.timeIntervalSinceReferenceDate
                    let offset = CGFloat(now.truncatingRemainder(dividingBy: halfWidth / speed) * speed)

                    Text(cachedTicker)
                        .font(OddsFonts.footerText)
                        .foregroundColor(OddsTheme.text2)
                        .fixedSize()
                        .frame(height: geo.size.height)
                        .offset(x: -offset)
                        .background(
                            GeometryReader { g in
                                Color.clear.preference(key: TextWidthKey.self, value: g.size.width)
                            }
                        )
                }

                // Edge fade masks
                HStack(spacing: 0) {
                    LinearGradient(
                        colors: [OddsTheme.bgCard, OddsTheme.bgCard.opacity(0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 20)

                    Spacer()

                    LinearGradient(
                        colors: [OddsTheme.bgCard.opacity(0), OddsTheme.bgCard],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 20)
                }
            }
        }
        .onPreferenceChange(TextWidthKey.self) { textWidth = $0 }
        .frame(height: OddsTheme.footerHeight)
        .clipped()
        .background(OddsTheme.bgCard)
        .border(width: 1, edges: [.top], color: OddsTheme.border)
        .onAppear { isVisible = true; updateTicker() }
        .onDisappear { isVisible = false }
        .onChange(of: store.lastUpdated) { updateTicker() }
    }

    private func updateTicker() {
        let watchIDs = Set(store.watchlist.map(\.id))
        let deduped = store.watchlist + store.trending.filter { !watchIDs.contains($0.id) }
        let items = deduped.prefix(8)
        guard !items.isEmpty else {
            cachedTicker = L10n.s(.noData, settings.language); return
        }
        let text = items.map { market in
            let name = Fmt.tickerName(market.question)
            let price = String(format: "%.2f", market.yesPrice)
            let arrow = market.oneDayChange >= 0 ? "▲" : "▼"
            let delta = Fmt.delta(market.oneDayChange)
            return "► \(name) \(price) \(arrow)\(delta)"
        }.joined(separator: "  ")
        cachedTicker = text + "     " + text + "     "
    }
}

private struct TextWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 400
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
