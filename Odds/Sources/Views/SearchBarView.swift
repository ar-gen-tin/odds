import SwiftUI
import Combine

struct SearchBarView: View {
    @Binding var query: String
    @Binding var isActive: Bool
    @Binding var apiResults: [SearchResult]
    @Binding var isSearchingAPI: Bool

    var body: some View {
        HStack(spacing: 6) {
            Text(">")
                .font(OddsFonts.statusBar)
                .foregroundColor(OddsTheme.orange)

            Text("SEARCH:")
                .font(OddsFonts.statusBar)
                .foregroundColor(OddsTheme.text3)
                .tracking(0.6)

            TextField("", text: $query)
                .textFieldStyle(.plain)
                .font(OddsFonts.statusBar)
                .foregroundColor(OddsTheme.text1)

            if isSearchingAPI {
                Text("...")
                    .font(OddsFonts.statusBar)
                    .foregroundColor(OddsTheme.text3)
            }

            Spacer()

            Text("[ESC]")
                .font(OddsFonts.footerText)
                .foregroundColor(OddsTheme.text3)
        }
        .padding(.horizontal, OddsTheme.horizontalPadding)
        .frame(height: OddsTheme.statusBarHeight)
        .background(OddsTheme.bgCard)
        .border(width: 1, edges: [.bottom], color: OddsTheme.border)
    }
}
