import SwiftUI

enum MarketTab: String, CaseIterable {
    case all, trending, politics, crypto, watch

    func label(_ lang: AppLanguage) -> String {
        switch self {
        case .all: return L10n.s(.all, lang)
        case .trending: return L10n.s(.trending, lang)
        case .politics: return L10n.s(.politics, lang)
        case .crypto: return L10n.s(.crypto, lang)
        case .watch: return L10n.s(.watch, lang)
        }
    }
}

struct TabBarView: View {
    @Binding var activeTab: MarketTab
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(MarketTab.allCases.enumerated()), id: \.element) { index, tab in
                if index > 0 {
                    Text("|")
                        .font(OddsFonts.tabInactive)
                        .foregroundColor(OddsTheme.text3.opacity(0.5))
                        .padding(.horizontal, 4)
                }

                TabItem(tab: tab, isActive: activeTab == tab, lang: settings.language) {
                    withAnimation(.easeOut(duration: 0.12)) {
                        activeTab = tab
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, OddsTheme.horizontalPadding)
        .frame(height: OddsTheme.tabBarHeight)
        .background(OddsTheme.bg)
        .border(width: 1, edges: [.bottom], color: OddsTheme.border)
    }
}

private struct TabItem: View {
    let tab: MarketTab
    let isActive: Bool
    let lang: AppLanguage
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Text(tab.label(lang))
                .font(isActive ? OddsFonts.tabActive : OddsFonts.tabInactive)
                .foregroundColor(foregroundColor)
                .tracking(1.2)
                .padding(.horizontal, 8)
                .frame(height: OddsTheme.tabBarHeight)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(OddsTheme.orange)
                        .frame(height: 2)
                        .opacity(isActive ? 1 : 0)
                }
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }

    private var foregroundColor: Color {
        if isActive { return OddsTheme.text1 }
        if isHovered { return OddsTheme.text2 }
        return OddsTheme.text3
    }
}
