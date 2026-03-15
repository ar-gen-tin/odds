import SwiftUI

enum MarketTab: String, CaseIterable {
    case all = "ALL"
    case trending = "TRENDING"
    case politics = "POLITICS"
    case crypto = "CRYPTO"
    case watch = "WATCH"
}

struct TabBarView: View {
    @Binding var activeTab: MarketTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(MarketTab.allCases.enumerated()), id: \.element) { index, tab in
                if index > 0 {
                    Text("|")
                        .font(OddsFonts.tabInactive)
                        .foregroundColor(OddsTheme.text3)
                        .padding(.horizontal, 4)
                }

                Button {
                    activeTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(activeTab == tab ? OddsFonts.tabActive : OddsFonts.tabInactive)
                        .foregroundColor(activeTab == tab ? OddsTheme.text1 : OddsTheme.text3)
                        .tracking(1.2)
                        .padding(.horizontal, 8)
                        .frame(height: OddsTheme.tabBarHeight)
                        .overlay(alignment: .bottom) {
                            if activeTab == tab {
                                Rectangle()
                                    .fill(OddsTheme.orange)
                                    .frame(height: 2)
                            }
                        }
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(.horizontal, OddsTheme.horizontalPadding)
        .frame(height: OddsTheme.tabBarHeight)
        .background(OddsTheme.bg)
        .border(width: 1, edges: [.bottom], color: OddsTheme.border)
    }
}
