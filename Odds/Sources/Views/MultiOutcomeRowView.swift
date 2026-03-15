import SwiftUI

struct MultiOutcomeRowView: View {
    let market: MultiOutcomeMarket
    @EnvironmentObject var settings: SettingsStore
    @State private var isHovered = false

    var body: some View {
        // P2 Fix: Tighter spacing for density
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(market.question)
                    .font(OddsFonts.marketName)
                    .foregroundColor(OddsTheme.text1)
                    .help(market.question)

                Spacer()

                Text(market.category)
                    .font(OddsFonts.tag)
                    .foregroundColor(OddsTheme.text3)
                    .tracking(1)
            }

            VStack(spacing: 4) {
                ForEach(Array(market.outcomes.enumerated()), id: \.element.id) { index, outcome in
                    HStack(spacing: 8) {
                        Text(outcome.name)
                            .font(.system(size: 11))
                            .foregroundColor(OddsTheme.text2)
                            .frame(width: 70, alignment: .trailing)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.white.opacity(0.02))
                                    // P2 Fix: Shorter bars
                                    .frame(height: 14)

                                RoundedRectangle(cornerRadius: 3)
                                    .fill(barColor(for: index))
                                    .frame(width: max(geo.size.width * outcome.price, 4), height: 14)
                            }
                        }
                        .frame(height: 14)

                        // P1 Fix: Price label outside bar (avoids overflow on low probabilities)
                        Text(settings.formatPrice(outcome.price))
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(OddsTheme.text2)
                            .frame(width: 36, alignment: .trailing)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isHovered ? OddsTheme.bgElevated : OddsTheme.bgCard)
        .onHover { isHovered = $0 }
    }

    private func barColor(for index: Int) -> Color {
        switch index {
        case 0: return OddsTheme.orange
        case 1: return Color.white.opacity(0.15)
        default: return Color.white.opacity(0.08)
        }
    }
}
