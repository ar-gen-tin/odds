import SwiftUI

struct SectionDividerView: View {
    let title: String
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        HStack(spacing: 8) {
            Text("\(L10n.s(.category, settings.language)): \(title)")
                .font(OddsFonts.sectionLabel)
                .foregroundColor(OddsTheme.orange)
                .tracking(1.5)

            Rectangle()
                .fill(OddsTheme.border)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, OddsTheme.horizontalPadding)
        .frame(height: OddsTheme.categoryHeight)
        .border(width: 1, edges: [.bottom], color: OddsTheme.border)
    }
}
