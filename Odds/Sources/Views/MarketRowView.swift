import SwiftUI

struct MarketRowView: View {
    let market: Market
    let index: Int
    let isWatchlist: Bool
    let isAlternate: Bool
    var isExpanded: Bool = false
    var showAddButton: Bool = false
    var onTap: (() -> Void)?
    var onRemove: (() -> Void)?

    @EnvironmentObject var settings: SettingsStore
    @State private var isHovered = false
    @State private var didPushCursor = false

    init(
        market: Market,
        index: Int,
        isWatchlist: Bool = false,
        isAlternate: Bool = false,
        isExpanded: Bool = false,
        showAddButton: Bool = false,
        onTap: (() -> Void)? = nil,
        onRemove: (() -> Void)? = nil
    ) {
        self.market = market
        self.index = index
        self.isWatchlist = isWatchlist
        self.isAlternate = isAlternate
        self.isExpanded = isExpanded
        self.showAddButton = showAddButton
        self.onTap = onTap
        self.onRemove = onRemove
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // IDX column (28px)
                Text(String(format: "%02d", index))
                    .font(OddsFonts.tag)
                    .foregroundColor(isExpanded ? OddsTheme.orange : OddsTheme.text3)
                    .frame(width: OddsTheme.colIdxWidth, alignment: .leading)

                // MARKET column (flex) — name + dot leader
                rowNameWithLeader
                    .frame(maxWidth: .infinity, alignment: .leading)

                // PROB column (50px)
                Text(settings.formatPrice(market.yesPrice))
                    .font(OddsFonts.price)
                    .foregroundColor(OddsTheme.text1)
                    .frame(width: OddsTheme.colProbWidth, alignment: .trailing)

                // Δ column (36px)
                Text(Fmt.delta(market.oneDayChange))
                    .font(OddsFonts.change)
                    .foregroundColor(trendColor)
                    .frame(width: OddsTheme.colDeltaWidth, alignment: .trailing)

                // TREND / ADD column (56px)
                if showAddButton {
                    addButtonView
                } else if settings.showSparklines {
                    Text(MarketRowView.textSparkline(market.priceHistory))
                        .font(OddsFonts.sparklineSmall)
                        .foregroundColor(OddsTheme.orange)
                        .opacity(0.7)
                        .tracking(-0.5)
                        .frame(width: OddsTheme.colTrendWidth, alignment: .trailing)
                } else {
                    Spacer().frame(width: OddsTheme.colTrendWidth)
                }
            }
            .padding(.horizontal, OddsTheme.horizontalPadding)
            .frame(height: OddsTheme.rowHeight)
            .background(rowBackground)
            .border(width: 1, edges: [.bottom], color: isExpanded ? OddsTheme.orange.opacity(0.3) : OddsTheme.border)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(market.question), \(settings.formatPrice(market.yesPrice)), \(market.changeText)")
            .onHover { hovering in
                withAnimation(.easeOut(duration: 0.12)) {
                    isHovered = hovering
                }
                if hovering && onTap != nil {
                    NSCursor.pointingHand.push()
                    didPushCursor = true
                } else if didPushCursor {
                    NSCursor.pop()
                    didPushCursor = false
                }
            }
            .onTapGesture {
                onTap?()
            }
            .contextMenu {
                Button {
                    if let url = market.polymarketURL {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Label(L10n.s(.openPolymarket, settings.language), systemImage: "arrow.up.right")
                }

                Button {
                    if let url = market.polymarketURL {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(url.absoluteString, forType: .string)
                    }
                } label: {
                    Label(L10n.s(.copyLink, settings.language), systemImage: "doc.on.doc")
                }

                if isWatchlist {
                    Divider()
                    Button(role: .destructive) {
                        onRemove?()
                    } label: {
                        Label(L10n.s(.removeFromWatchlist, settings.language), systemImage: "xmark")
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
                .stroke(OddsTheme.text3.opacity(isHovered ? 0.6 : 0.35), lineWidth: 0.5)
            }

            // Layer 2: name text with opaque background to mask dots behind it
            Text(market.question)
                .font(OddsFonts.marketName)
                .foregroundColor(isHovered ? OddsTheme.text1 : OddsTheme.text1.opacity(0.85))
                .lineLimit(1)
                .help(market.question)
                .padding(.trailing, 4)
                .background(isAlternate || isHovered || isExpanded ? OddsTheme.bgElevated : OddsTheme.bg)
        }
    }

    private var rowBackground: Color {
        if isExpanded { return OddsTheme.bgElevated }
        if isHovered { return OddsTheme.bgElevated }
        if isAlternate { return OddsTheme.bgElevated }
        return Color.clear
    }

    // MARK: - Add Button (search results)

    @State private var isAddHovered = false

    private var addButtonView: some View {
        Button {
            if !isWatchlist {
                onTap?()
            }
        } label: {
            if isWatchlist {
                Text("✓")
                    .font(OddsFonts.buttonLabel)
                    .foregroundColor(OddsTheme.lime.opacity(0.6))
                    .frame(width: OddsTheme.colTrendWidth, height: 22)
                    .background(OddsTheme.lime.opacity(0.04))
                    .overlay(Rectangle().stroke(OddsTheme.lime.opacity(0.15), lineWidth: 1))
            } else {
                Text("+ ADD")
                    .font(OddsFonts.buttonLabel)
                    .foregroundColor(isAddHovered ? OddsTheme.lime : OddsTheme.lime.opacity(0.8))
                    .tracking(0.6)
                    .frame(width: OddsTheme.colTrendWidth, height: 22)
                    .background(OddsTheme.lime.opacity(isAddHovered ? 0.12 : 0.06))
                    .overlay(Rectangle().stroke(OddsTheme.lime.opacity(isAddHovered ? 0.5 : 0.25), lineWidth: 1))
            }
        }
        .buttonStyle(.plain)
        .onHover { isAddHovered = $0 }
    }

    // A7: Use downRed instead of orange for down trend
    private var trendColor: Color {
        switch market.trend {
        case .up: return OddsTheme.lime
        case .down: return OddsTheme.downRed
        case .flat: return OddsTheme.text3
        }
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
