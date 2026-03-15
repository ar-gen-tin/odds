import SwiftUI

struct MarketRowView: View {
    let market: Market
    let index: Int
    let isWatchlist: Bool
    let isAlternate: Bool
    var isExpanded: Bool = false
    var onTap: (() -> Void)?
    var onRemove: (() -> Void)?

    @EnvironmentObject var settings: SettingsStore
    @State private var isHovered = false

    init(
        market: Market,
        index: Int,
        isWatchlist: Bool = false,
        isAlternate: Bool = false,
        isExpanded: Bool = false,
        onTap: (() -> Void)? = nil,
        onRemove: (() -> Void)? = nil
    ) {
        self.market = market
        self.index = index
        self.isWatchlist = isWatchlist
        self.isAlternate = isAlternate
        self.isExpanded = isExpanded
        self.onTap = onTap
        self.onRemove = onRemove
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // IDX column (28px)
                Text(String(format: "%02d", index))
                    .font(OddsFonts.tag)
                    .foregroundColor(OddsTheme.text3)
                    .frame(width: 28, alignment: .leading)

                // MARKET column (flex) — name + dot leader
                rowNameWithLeader
                    .frame(maxWidth: .infinity, alignment: .leading)

                // PROB column (50px)
                Text(formatProb(market.yesPrice))
                    .font(OddsFonts.price)
                    .foregroundColor(OddsTheme.text1)
                    .frame(width: 50, alignment: .trailing)

                // Δ column (36px)
                Text(formatDelta(market.oneDayChange))
                    .font(OddsFonts.change)
                    .foregroundColor(trendColor)
                    .frame(width: 36, alignment: .trailing)

                // TREND column (56px) — text-based sparkline
                Text(MarketRowView.textSparkline(market.priceHistory))
                    .font(OddsFonts.sparklineSmall)
                    .foregroundColor(OddsTheme.orange)
                    .opacity(0.7)
                    .tracking(-0.5)
                    .frame(width: 56, alignment: .trailing)
            }
            .padding(.horizontal, OddsTheme.horizontalPadding)
            .frame(height: OddsTheme.rowHeight)
            .background(rowBackground)
            .border(width: 1, edges: [.bottom], color: OddsTheme.border)
            .onHover { isHovered = $0 }
            .onTapGesture {
                onTap?()
            }
            .contextMenu {
                Button {
                    if let url = market.polymarketURL {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Label("Open on Polymarket", systemImage: "arrow.up.right")
                }

                Button {
                    if let url = market.polymarketURL {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(url.absoluteString, forType: .string)
                    }
                } label: {
                    Label("Copy Link", systemImage: "doc.on.doc")
                }

                if isWatchlist {
                    Divider()
                    Button(role: .destructive) {
                        onRemove?()
                    } label: {
                        Label("Remove from Watchlist", systemImage: "xmark")
                    }
                }
            }
        }
    }

    // MARK: - Name + Dot Leader

    private var rowNameWithLeader: some View {
        ZStack(alignment: .leading) {
            // Layer 1: dot-leader across entire width
            GeometryReader { geo in
                Path { path in
                    let y = geo.size.height / 2
                    var x: CGFloat = 0
                    while x < geo.size.width {
                        path.move(to: CGPoint(x: x, y: y))
                        path.addLine(to: CGPoint(x: x + 1.5, y: y))
                        x += 5
                    }
                }
                .stroke(OddsTheme.text3, lineWidth: 0.5)
            }

            // Layer 2: name text with opaque background to mask dots behind it
            Text(market.question)
                .font(OddsFonts.marketName)
                .foregroundColor(OddsTheme.text1)
                .lineLimit(1)
                .help(market.question)
                .padding(.trailing, 4)
                .background(isAlternate || isHovered ? OddsTheme.bgElevated : OddsTheme.bg)
        }
    }

    private var rowBackground: Color {
        if isHovered { return OddsTheme.bgElevated }
        if isAlternate { return OddsTheme.bgElevated }
        return Color.clear
    }

    private var trendColor: Color {
        switch market.trend {
        case .up: return OddsTheme.lime
        case .down: return OddsTheme.orange
        case .flat: return OddsTheme.text3
        }
    }

    private func formatProb(_ price: Double) -> String {
        String(format: ".%02d", Int((price * 100).rounded()))
    }

    private func formatDelta(_ change: Double) -> String {
        if abs(change) < 0.0001 { return ".00" }
        let sign = change > 0 ? "+" : "-"
        return String(format: "%@.%02d", sign, abs(Int((change * 100).rounded())))
    }

    /// Convert price history to Unicode block characters (▁▂▃▅▆▇█)
    static func textSparkline(_ data: [Double]) -> String {
        guard !data.isEmpty else { return "" }
        let blocks: [Character] = ["▁", "▂", "▃", "▅", "▆", "▇", "█"]
        let minVal = data.min() ?? 0
        let maxVal = data.max() ?? 1
        let range = maxVal - minVal

        // Limit to ~8 characters max to fit in 56px
        let sampled: [Double]
        if data.count > 8 {
            sampled = stride(from: 0, to: data.count, by: max(1, data.count / 8)).map { data[$0] }
        } else {
            sampled = data
        }

        return String(sampled.map { value in
            if range == 0 { return blocks[3] }
            let normalized = (value - minVal) / range
            let idx = min(Int(normalized * Double(blocks.count - 1)), blocks.count - 1)
            return blocks[idx]
        })
    }
}
