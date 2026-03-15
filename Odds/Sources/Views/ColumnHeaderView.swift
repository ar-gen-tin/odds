import SwiftUI

struct ColumnHeaderView: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("IDX")
                .frame(width: 28, alignment: .leading)

            Text("MARKET")
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("PROB")
                .frame(width: 50, alignment: .trailing)

            Text("Δ")
                .frame(width: 36, alignment: .trailing)

            Text("TREND")
                .frame(width: 56, alignment: .trailing)
        }
        .font(OddsFonts.colHeader)
        .foregroundColor(OddsTheme.text3)
        .tracking(1.2)
        .padding(.horizontal, OddsTheme.horizontalPadding)
        .frame(height: OddsTheme.tableHeaderHeight)
        .border(width: 1, edges: [.bottom], color: OddsTheme.border)
    }
}
