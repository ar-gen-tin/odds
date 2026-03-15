import SwiftUI

struct SearchResultRowView: View {
    let result: SearchResult
    let isInWatchlist: Bool
    let onAdd: () -> Void

    @EnvironmentObject var settings: SettingsStore
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 0) {
                Text(result.title)
                    .font(OddsFonts.marketName)
                    .foregroundColor(OddsTheme.text1)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .help(result.title)

                HStack(spacing: 6) {
                    if !result.category.isEmpty {
                        Text(result.category.uppercased())
                            .font(OddsFonts.tag)
                            .foregroundColor(OddsTheme.text3)
                            .tracking(1)
                    }
                    if result.volume > 0 {
                        Text("·")
                            .foregroundColor(OddsTheme.text3)
                        Text(formatVolume(result.volume))
                            .font(OddsFonts.tag)
                            .foregroundColor(OddsTheme.text3)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Price from first market
            if let first = result.markets.first, first.yesPrice > 0 {
                Text(settings.formatPrice(first.yesPrice))
                    .font(OddsFonts.price)
                    .foregroundColor(OddsTheme.text1)
                    .frame(width: 50, alignment: .trailing)
            }

            // Add/Added button
            Button {
                if !isInWatchlist {
                    onAdd()
                }
            } label: {
                if isInWatchlist {
                    Text("✓")
                        .font(OddsFonts.buttonSmall)
                        .foregroundColor(OddsTheme.text3)
                        .frame(width: 52, height: 26)
                        .overlay(
                            Rectangle()
                                .stroke(OddsTheme.border, lineWidth: 1)
                        )
                } else {
                    Text("+ Add")
                        .font(OddsFonts.buttonSmall)
                        .foregroundColor(OddsTheme.lime)
                        .frame(width: 52, height: 26)
                        .background(
                            Rectangle()
                                .fill(OddsTheme.lime.opacity(0.08))
                        )
                        .overlay(
                            Rectangle()
                                .stroke(OddsTheme.lime.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, OddsTheme.horizontalPadding)
        .frame(height: OddsTheme.rowHeight)
        .background(isHovered ? OddsTheme.bgElevated : Color.clear)
        .onHover { isHovered = $0 }
        .onTapGesture {
            if let url = result.polymarketURL {
                NSWorkspace.shared.open(url)
            }
        }
    }

    private func formatVolume(_ vol: Double) -> String {
        if vol >= 1_000_000 {
            return String(format: "$%.1fM", vol / 1_000_000)
        } else if vol >= 1_000 {
            return String(format: "$%.0fK", vol / 1_000)
        }
        return String(format: "$%.0f", vol)
    }
}
