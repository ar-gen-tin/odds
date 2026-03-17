import SwiftUI
import Combine

struct SearchBarView: View {
    @Binding var query: String
    @Binding var isActive: Bool
    @Binding var apiResults: [Market]
    @Binding var isSearchingAPI: Bool
    @EnvironmentObject var settings: SettingsStore
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 6) {
            Text(">")
                .font(OddsFonts.statusBar)
                .foregroundColor(OddsTheme.orange)

            Text(L10n.s(.searchLabel, settings.language))
                .font(OddsFonts.statusBar)
                .foregroundColor(OddsTheme.text3)
                .tracking(0.6)

            TextField("", text: $query)
                .textFieldStyle(.plain)
                .font(OddsFonts.statusBar)
                .foregroundColor(OddsTheme.text1)
                .focused($isFocused)

            if isSearchingAPI {
                TypingIndicator()
            }

            Spacer()

            Text("[ESC]")
                .font(OddsFonts.footerText)
                .foregroundColor(OddsTheme.text3)
        }
        .padding(.horizontal, OddsTheme.horizontalPadding)
        .frame(height: OddsTheme.statusBarHeight)
        .background(OddsTheme.bgCard)
        .border(width: 1, edges: [.bottom], color: OddsTheme.orange.opacity(0.3))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isFocused = true
            }
        }
        .onExitCommand {
            query = ""
            apiResults = []
            isActive = false
        }
    }
}

/// Animated "..." loading indicator
private struct TypingIndicator: View {
    @State private var dotCount = 0
    @State private var timer: Timer?

    var body: some View {
        Text(String(repeating: ".", count: dotCount + 1))
            .font(OddsFonts.statusBar)
            .foregroundColor(OddsTheme.text3)
            .frame(width: 20, alignment: .leading)
            .onAppear {
                timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                    dotCount = (dotCount + 1) % 3
                }
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
    }
}
