import SwiftUI

struct FooterTickerView: View {
    @EnvironmentObject var store: MarketStore
    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let tickerText = buildTickerContent()
            HStack(spacing: 0) {
                tickerRow(tickerText)
                    .offset(x: offset)
                tickerRow(tickerText)
                    .offset(x: offset)
            }
            .onAppear {
                startScrolling(containerWidth: geo.size.width)
            }
        }
        .frame(height: OddsTheme.footerHeight)
        .clipped()
        .background(OddsTheme.bgCard)
        .border(width: 1, edges: [.top], color: OddsTheme.border)
    }

    @ViewBuilder
    private func tickerRow(_ items: [(String, Double, Double)]) -> some View {
        HStack(spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                tickerItem(name: item.0, price: item.1, change: item.2)
            }
        }
        .padding(.horizontal, OddsTheme.horizontalPadding)
    }

    @ViewBuilder
    private func tickerItem(name: String, price: Double, change: Double) -> some View {
        HStack(spacing: 4) {
            Text("►")
                .font(OddsFonts.footerSmall)
                .foregroundColor(OddsTheme.orange)
                .opacity(0.6)

            Text(name)
                .font(OddsFonts.footerText)
                .foregroundColor(OddsTheme.text3)

            Text(String(format: "%.2f", price))
                .font(OddsFonts.footerText)
                .foregroundColor(OddsTheme.text2)

            Text(formatTickerDelta(change))
                .font(OddsFonts.footerSmall)
                .foregroundColor(change >= 0 ? OddsTheme.lime : OddsTheme.orange)
        }
    }

    private func formatTickerDelta(_ change: Double) -> String {
        let arrow = change >= 0 ? "▲" : "▼"
        let sign = change >= 0 ? "+" : ""
        return "\(arrow)\(sign).\(String(format: "%02d", abs(Int((change * 100).rounded()))))"
    }

    private func buildTickerContent() -> [(String, Double, Double)] {
        let allMarkets = store.watchlist + store.trending
        return allMarkets.prefix(6).map { market in
            let shortName = market.question
                .replacingOccurrences(of: " Wins ", with: " ")
                .replacingOccurrences(of: " > ", with: " ")
                .components(separatedBy: " ")
                .prefix(2)
                .joined(separator: " ")
            return (shortName, market.yesPrice, market.oneDayChange)
        }
    }

    private func startScrolling(containerWidth: CGFloat) {
        let contentWidth: CGFloat = 600 // approximate
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            offset = -contentWidth
        }
    }
}
