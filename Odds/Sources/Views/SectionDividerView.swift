import SwiftUI

struct SectionDividerView: View {
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Text("CATEGORY: \(title)")
                .font(OddsFonts.sectionLabel)
                .foregroundColor(OddsTheme.orange)
                .tracking(1.5)

            // Horizontal rule extending to fill
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
