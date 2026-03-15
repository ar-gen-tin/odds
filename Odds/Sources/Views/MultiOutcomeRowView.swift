import SwiftUI

struct MultiOutcomeRowView: View {
    let market: MultiOutcomeMarket
    @EnvironmentObject var settings: SettingsStore
    @State private var isHovered = false

    var body: some View {
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
                            .font(OddsFonts.marketName)
                            .foregroundColor(OddsTheme.text2)
                            .frame(width: 70, alignment: .trailing)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.white.opacity(0.02))
                                    .frame(height: 14)

                                Rectangle()
                                    .fill(barColor(for: index))
                                    .frame(width: max(geo.size.width * outcome.price, 4), height: 14)
                            }
                        }
                        .frame(height: 14)

                        Text(settings.formatPrice(outcome.price))
                            .font(OddsFonts.change)
                            .foregroundColor(OddsTheme.text2)
                            .frame(width: 36, alignment: .trailing)
                    }
                }
            }
        }
        .padding(.horizontal, OddsTheme.horizontalPadding)
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
