import SwiftUI

struct StatusBarView: View {
    @EnvironmentObject var store: MarketStore
    @EnvironmentObject var settings: SettingsStore
    var onSettingsTap: (() -> Void)?
    var onSearchTap: (() -> Void)?
    var isSettingsActive: Bool = false

    @State private var livePulse = false
    @State private var isSearchHovered = false
    @State private var isSettingsHovered = false

    private var lang: AppLanguage { settings.language }

    var body: some View {
        HStack(spacing: 6) {
            Text(L10n.s(.sys, lang))
                .font(OddsFonts.statusBar)
                .foregroundColor(OddsTheme.text3)
                .tracking(0.6)

            // Brand + status
            HStack(spacing: 6) {
                Text("odds")
                    .font(OddsFonts.labelMedium)
                    .foregroundColor(OddsTheme.text1)

                if isSettingsActive {
                    Text("∷")
                        .font(OddsFonts.statusBar)
                        .foregroundColor(OddsTheme.text3)
                    Text(L10n.s(.settings, lang))
                        .font(OddsFonts.statusBar)
                        .foregroundColor(OddsTheme.orange)
                        .tracking(0.6)
                } else if store.error != nil {
                    Circle()
                        .fill(OddsTheme.downRed)
                        .frame(width: 5, height: 5)
                        .accessibilityHidden(true)
                    Text("OFFLINE")
                        .font(OddsFonts.labelMedium)
                        .foregroundColor(OddsTheme.downRed)
                        .tracking(0.6)
                } else if store.isLive {
                    Circle()
                        .fill(OddsTheme.lime)
                        .frame(width: 5, height: 5)
                        .opacity(livePulse ? 1.0 : 0.35)
                        .accessibilityHidden(true)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                livePulse = true
                            }
                        }
                    Text(L10n.s(.live, lang))
                        .font(OddsFonts.labelMedium)
                        .foregroundColor(OddsTheme.lime)
                        .tracking(0.6)
                } else {
                    Text("...")
                        .font(OddsFonts.statusBar)
                        .foregroundColor(OddsTheme.text3)
                }
            }

            Text("|")
                .font(OddsFonts.statusBar)
                .foregroundColor(OddsTheme.text3)

            Spacer()

            Text(L10n.s(.mkts, lang))
                .font(OddsFonts.statusBar)
                .foregroundColor(OddsTheme.text3)

            Text("\(store.marketCount)")
                .font(OddsFonts.statusBar)
                .foregroundColor(OddsTheme.text2)

            // Search button
            Button {
                onSearchTap?()
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSearchHovered ? OddsTheme.text1 : OddsTheme.text3)
                    .frame(width: 22, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { isSearchHovered = $0 }

            // Settings button
            Button {
                onSettingsTap?()
            } label: {
                Image(systemName: isSettingsActive ? "gearshape.fill" : "gearshape")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSettingsActive ? OddsTheme.orange : (isSettingsHovered ? OddsTheme.text1 : OddsTheme.text3))
                    .frame(width: 22, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { isSettingsHovered = $0 }
        }
        .padding(.horizontal, OddsTheme.horizontalPadding)
        .frame(height: OddsTheme.statusBarHeight)
        .background(OddsTheme.bgCard)
        .border(width: 1, edges: [.bottom], color: OddsTheme.border)
    }
}
