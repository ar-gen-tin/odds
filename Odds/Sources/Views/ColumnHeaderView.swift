import SwiftUI

struct ColumnHeaderView: View {
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        HStack(spacing: 0) {
            Text(L10n.s(.idx, settings.language))
                .frame(width: 28, alignment: .leading)

            Text(L10n.s(.market, settings.language))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(L10n.s(.prob, settings.language))
                .frame(width: 50, alignment: .trailing)

            Text(L10n.s(.delta, settings.language))
                .frame(width: 36, alignment: .trailing)

            if settings.showSparklines {
                Text(L10n.s(.trend, settings.language))
                    .frame(width: 56, alignment: .trailing)
            }
        }
        .font(OddsFonts.colHeader)
        .foregroundColor(OddsTheme.text3)
        .tracking(1.2)
        .padding(.horizontal, OddsTheme.horizontalPadding)
        .frame(height: OddsTheme.tableHeaderHeight)
        .border(width: 1, edges: [.bottom], color: OddsTheme.border)
    }
}
