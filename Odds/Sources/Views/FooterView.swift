import SwiftUI

struct FooterView: View {
    var isSearching: Bool = false
    var resultCount: Int = 0
    @EnvironmentObject var settings: SettingsStore

    private var lang: AppLanguage { settings.language }

    var body: some View {
        HStack {
            // Left: brand or result count
            if isSearching {
                Text(L10n.string(.results(resultCount), lang: lang))
                    .font(OddsFonts.footerText)
                    .foregroundColor(OddsTheme.text2)
                    .tracking(1)
            } else {
                Text("POLYMARKET")
                    .font(OddsFonts.footerText)
                    .foregroundColor(OddsTheme.text3)
                    .tracking(1.5)
            }

            Spacer()

            HStack(spacing: 8) {
                // Quit button
                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Text(L10n.string(.quit, lang: lang))
                        .font(OddsFonts.footerText)
                        .foregroundColor(OddsTheme.text3)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(OddsTheme.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                Text("\(Int(settings.refreshInterval))s")
                    .font(OddsFonts.footerText)
                    .foregroundColor(OddsTheme.text3)

                LiveDot()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(OddsTheme.bgCard)
        .border(width: 1, edges: [.top], color: OddsTheme.border)
    }
}

struct LiveDot: View {
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .fill(OddsTheme.lime)
            .frame(width: 5, height: 5)
            .shadow(color: OddsTheme.lime, radius: 3)
            .opacity(isAnimating ? 0.3 : 1.0)
            .animation(
                .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear { isAnimating = true }
    }
}
