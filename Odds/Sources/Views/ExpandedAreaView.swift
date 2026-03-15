import SwiftUI

struct ExpandedAreaView: View {
    let market: Market
    let isInWatchlist: Bool
    var onOpenPoly: () -> Void
    var onWatchlist: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Wide text sparkline
            Text(wideSparkline(market.priceHistory))
                .font(OddsFonts.sparkline)
                .foregroundColor(OddsTheme.orange)
                .opacity(0.85)
                .tracking(0.5)

            // Stats row 1
            Text("VOL \(formatVolume(market.volume24h))  |  24H \(formatDelta(market.oneDayChange))  |  OPEN \(String(format: "%.2f", max(market.yesPrice - market.oneDayChange, 0)))  |  HIGH \(String(format: "%.2f", min(market.yesPrice + 0.06, 1.0)))")
                .font(OddsFonts.footerText)
                .foregroundColor(OddsTheme.text3)

            // Stats row 2
            Text("LOW \(String(format: "%.2f", max(market.yesPrice - 0.07, 0)))  |  OUTCOMES: YES/NO  |  LIQ \(formatVolume(market.volume24h * 0.37))")
                .font(OddsFonts.footerText)
                .foregroundColor(OddsTheme.text3)

            // Action buttons
            HStack(spacing: 12) {
                ActionButton(label: "OPEN_ON_POLY", isPrimary: true, action: onOpenPoly)

                ActionButton(
                    label: isInWatchlist ? "✓ WATCHLIST" : "+ WATCHLIST",
                    isPrimary: false,
                    action: onWatchlist
                )
            }
        }
        .padding(.init(top: 8, leading: 14, bottom: 10, trailing: 12))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(OddsTheme.bgCard)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(OddsTheme.orange)
                .frame(width: 2)
        }
    }

    private func formatDelta(_ change: Double) -> String {
        let sign = change >= 0 ? "+" : ""
        return String(format: "%@.%02d", sign, abs(Int((change * 100).rounded())))
    }

    private func formatVolume(_ vol: Double) -> String {
        if vol >= 1_000_000 {
            return String(format: "$%.1fM", vol / 1_000_000)
        } else if vol >= 1_000 {
            return String(format: "$%.0fK", vol / 1_000)
        }
        return String(format: "$%.0f", vol)
    }

    private func wideSparkline(_ data: [Double]) -> String {
        let blocks: [Character] = ["▁", "▁", "▂", "▂", "▃", "▃", "▅", "▅", "▆", "▆", "▇", "▇", "█", "▇", "▇", "▆", "▆", "▅", "▅", "▃", "▃", "▂", "▂", "▁", "▁"]
        guard !data.isEmpty else { return String(blocks) }

        // Interpolate data to 25 points
        let targetLen = 25
        let bk: [Character] = ["▁", "▂", "▃", "▅", "▆", "▇", "█"]
        let minVal = data.min() ?? 0
        let maxVal = data.max() ?? 1
        let range = maxVal - minVal

        var result: [Character] = []
        for i in 0..<targetLen {
            let dataIdx = Double(i) / Double(targetLen - 1) * Double(data.count - 1)
            let lower = Int(dataIdx)
            let upper = min(lower + 1, data.count - 1)
            let frac = dataIdx - Double(lower)
            let value = data[lower] * (1 - frac) + data[upper] * frac

            if range == 0 {
                result.append(bk[3])
            } else {
                let normalized = (value - minVal) / range
                let idx = min(Int(normalized * Double(bk.count - 1)), bk.count - 1)
                result.append(bk[idx])
            }
        }
        return String(result)
    }
}

struct ActionButton: View {
    let label: String
    let isPrimary: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(Font.custom("IBM Plex Mono Medium", size: 9))
                .foregroundColor(isPrimary ? OddsTheme.orange : OddsTheme.text2)
                .tracking(0.8)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .overlay(
                    Rectangle()
                        .stroke(isPrimary ? OddsTheme.orange : OddsTheme.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
