import SwiftUI

struct MarketRowView: View {
    let market: Market
    let isWatchlist: Bool
    var onRemove: (() -> Void)?

    @EnvironmentObject var settings: SettingsStore
    @State private var isHovered = false

    init(market: Market, isWatchlist: Bool = false, onRemove: (() -> Void)? = nil) {
        self.market = market
        self.isWatchlist = isWatchlist
        self.onRemove = onRemove
    }

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 0) {
                Text(market.question)
                    .font(OddsFonts.marketName)
                    .foregroundColor(OddsTheme.text1)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .help(market.question)

                Text(market.category)
                    .font(OddsFonts.tag)
                    .foregroundColor(OddsTheme.text3)
                    .tracking(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if settings.showSparklines {
                SparklineView(data: market.priceHistory, trend: market.trend)
                    .frame(width: 56, height: 20)
            } else {
                Spacer().frame(width: 56)
            }

            Text(settings.formatPrice(market.yesPrice))
                .font(OddsFonts.price)
                .foregroundColor(OddsTheme.text1)
                .frame(width: 56, alignment: .trailing)

            Text(market.changeText)
                .font(OddsFonts.change)
                .foregroundColor(trendColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(trendBgColor)
                )
                .frame(width: 52, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 46)
        .background(isHovered ? OddsTheme.bgElevated : Color.clear)
        .onHover { isHovered = $0 }
        .onTapGesture {
            if let url = market.polymarketURL {
                NSWorkspace.shared.open(url)
            }
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

    private var trendColor: Color {
        switch market.trend {
        case .up: return OddsTheme.lime
        case .down: return OddsTheme.downRed
        case .flat: return OddsTheme.text3
        }
    }

    private var trendBgColor: Color {
        switch market.trend {
        case .up: return OddsTheme.limeDim
        case .down: return OddsTheme.redDim
        case .flat: return Color.white.opacity(0.03)
        }
    }
}
