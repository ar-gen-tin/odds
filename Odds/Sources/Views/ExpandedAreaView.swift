import SwiftUI

struct ExpandedAreaView: View {
    let market: Market
    let isInWatchlist: Bool
    var onOpenPoly: () -> Void
    var onWatchlist: () -> Void
    @EnvironmentObject var settings: SettingsStore
    @State private var showConfirm = false

    private var lang: AppLanguage { settings.language }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Sparkline
            Text(wideSparkline(market.priceHistory))
                .font(OddsFonts.sparklineExpanded)
                .foregroundColor(OddsTheme.orange)
                .opacity(0.85)
                .tracking(-0.5)

            // Stats line
            HStack(spacing: 0) {
                statLabel("VOL")
                statValue(Fmt.volume(market.volume24h))
                statSep()
                statLabel("24H")
                statValue(Fmt.delta(market.oneDayChange), color: market.oneDayChange >= 0 ? OddsTheme.lime : OddsTheme.downRed)
                statSep()
                statLabel("PRICE")
                statValue(String(format: "%.2f", market.yesPrice))
            }

            // Action buttons + confirm flash
            HStack(spacing: 12) {
                ActionButton(
                    label: L10n.s(.openOnPoly, lang),
                    isPrimary: true,
                    action: onOpenPoly
                )

                if showConfirm {
                    Text("✓ ADDED")
                        .font(OddsFonts.buttonLabel)
                        .foregroundColor(OddsTheme.lime)
                        .tracking(0.8)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(OddsTheme.lime.opacity(0.1))
                        .overlay(Rectangle().stroke(OddsTheme.lime.opacity(0.3), lineWidth: 1))
                        .transition(.opacity)
                } else {
                    ActionButton(
                        label: isInWatchlist
                            ? L10n.s(.removeWatchlist, lang)
                            : L10n.s(.addWatchlist, lang),
                        isPrimary: false
                    ) {
                        if !isInWatchlist {
                            onWatchlist()
                            withAnimation(.easeIn(duration: 0.15)) { showConfirm = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                withAnimation(.easeOut(duration: 0.2)) { showConfirm = false }
                            }
                        } else {
                            onWatchlist()
                        }
                    }
                }
            }
        }
        .padding(.horizontal, OddsTheme.horizontalPadding)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(OddsTheme.bgCard)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(OddsTheme.orange)
                .frame(width: 2)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - Stat Helpers

    private func statLabel(_ text: String) -> some View {
        Text(text + " ")
            .font(OddsFonts.footerText)
            .foregroundColor(OddsTheme.text3)
    }

    private func statValue(_ text: String, color: Color = OddsTheme.text2) -> some View {
        Text(text)
            .font(OddsFonts.footerText)
            .foregroundColor(color)
    }

    private func statSep() -> some View {
        Text("  |  ")
            .font(OddsFonts.footerText)
            .foregroundColor(OddsTheme.text3.opacity(0.5))
    }

    // MARK: - Sparkline

    private func wideSparkline(_ data: [Double]) -> String {
        guard data.count >= 2 else {
            return data.isEmpty ? "" : String(repeating: "▃", count: 25)
        }

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
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(OddsFonts.buttonLabel)
                .foregroundColor(buttonForeground)
                .tracking(0.8)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(buttonBackground)
                .overlay(
                    Rectangle()
                        .stroke(buttonBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }

    private var buttonForeground: Color {
        if isPrimary {
            return isHovered ? OddsTheme.bg : OddsTheme.orange
        }
        return isHovered ? OddsTheme.text1 : OddsTheme.text2
    }

    private var buttonBackground: Color {
        if isPrimary && isHovered {
            return OddsTheme.orange
        }
        if !isPrimary && isHovered {
            return OddsTheme.bgElevated
        }
        return .clear
    }

    private var buttonBorder: Color {
        if isPrimary {
            return OddsTheme.orange
        }
        return isHovered ? OddsTheme.text3 : OddsTheme.border
    }
}
