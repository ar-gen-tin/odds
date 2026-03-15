import SwiftUI

struct StatusBarView: View {
    @EnvironmentObject var store: MarketStore
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        HStack(spacing: 6) {
            Text("SYS")
                .font(OddsFonts.statusBar)
                .foregroundColor(OddsTheme.text3)
                .tracking(0.6)

            Text("odds")
                .font(Font.custom("IBM Plex Mono Medium", size: 10))
                .foregroundColor(OddsTheme.text1)

            Circle()
                .fill(OddsTheme.lime)
                .frame(width: 5, height: 5)

            Text("LIVE")
                .font(Font.custom("IBM Plex Mono Medium", size: 10))
                .foregroundColor(OddsTheme.lime)
                .tracking(0.6)

            Text("|")
                .font(OddsFonts.statusBar)
                .foregroundColor(OddsTheme.text3)

            Spacer()

            Text("MKTS")
                .font(OddsFonts.statusBar)
                .foregroundColor(OddsTheme.text3)

            Text("\(store.marketCount)")
                .font(OddsFonts.statusBar)
                .foregroundColor(OddsTheme.text2)

            Text("↻")
                .font(OddsFonts.statusBar)
                .foregroundColor(OddsTheme.text3)

            Text("\(Int(settings.refreshInterval))s")
                .font(OddsFonts.statusBar)
                .foregroundColor(OddsTheme.text2)
        }
        .padding(.horizontal, OddsTheme.horizontalPadding)
        .frame(height: OddsTheme.statusBarHeight)
        .background(OddsTheme.bgCard)
        .border(width: 1, edges: [.bottom], color: OddsTheme.border)
    }
}
