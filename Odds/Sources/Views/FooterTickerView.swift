import SwiftUI

struct FooterTickerView: View {
    @EnvironmentObject var store: MarketStore
    @State private var cachedTicker: String = ""
    @State private var textWidth: CGFloat = 400

    var body: some View {
        GeometryReader { _ in
            TimelineView(.animation(minimumInterval: 1.0 / 12.0)) { timeline in
                let speed: Double = 25
                let halfWidth = max(textWidth / 2, 1)
                let now = timeline.date.timeIntervalSinceReferenceDate
                let offset = CGFloat(now.truncatingRemainder(dividingBy: halfWidth / speed) * speed)

                Text(cachedTicker)
                    .font(OddsFonts.footerText)
                    .foregroundColor(OddsTheme.text2)
                    .fixedSize()
                    .offset(x: -offset)
                    .background(
                        GeometryReader { g in
                            Color.clear.preference(key: TextWidthKey.self, value: g.size.width)
                        }
                    )
            }
        }
        .onPreferenceChange(TextWidthKey.self) { textWidth = $0 }
        .frame(height: OddsTheme.footerHeight)
        .clipped()
        .background(OddsTheme.bgCard)
        .border(width: 1, edges: [.top], color: OddsTheme.border)
        .onAppear { updateTicker() }
        .onChange(of: store.lastUpdated) { updateTicker() }
    }

    private func updateTicker() {
        let items = (store.watchlist + store.trending).prefix(6)
        let text = items.map { market in
            let name = String(market.question.prefix(12))
            let price = String(format: "%.2f", market.yesPrice)
            let arrow = market.oneDayChange >= 0 ? "▲" : "▼"
            let sign = market.oneDayChange >= 0 ? "+" : "-"
            let delta = String(format: "%@.%02d", sign, abs(Int((market.oneDayChange * 100).rounded())))
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
