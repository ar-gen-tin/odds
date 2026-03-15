import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var settings: SettingsStore
    @State private var bootStep = 0
    @State private var showActions = false

    var onComplete: () -> Void

    private let bootSequence: [(String, String)] = [
        ("SYS_INIT", "OK"),
        ("API_CONNECT", "OK"),
        ("FEED_SUBSCRIBE", "PENDING"),
        ("MARKETS_LOADED", "0")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Status bar
            HStack(spacing: 6) {
                Text("SYS")
                    .font(OddsFonts.statusBar)
                    .foregroundColor(OddsTheme.text3)
                    .tracking(0.6)
                Text("odds")
                    .font(Font.custom("IBM Plex Mono Medium", size: 10))
                    .foregroundColor(OddsTheme.text1)
                Text("∷")
                    .font(OddsFonts.statusBar)
                    .foregroundColor(OddsTheme.text3)
                Text("SETUP")
                    .font(OddsFonts.statusBar)
                    .foregroundColor(OddsTheme.orange)
                    .tracking(0.6)
                Spacer()
            }
            .padding(.horizontal, OddsTheme.horizontalPadding)
            .frame(height: OddsTheme.statusBarHeight)
            .background(OddsTheme.bgCard)
            .border(width: 1, edges: [.bottom], color: OddsTheme.border)

            // Main content area
            VStack(spacing: 12) {
                Spacer()

                // ASCII art logo
                VStack(spacing: 0) {
                    Text("▓▓▓▓▓▓▓")
                        .font(OddsFonts.statusBar)
                        .foregroundColor(OddsTheme.orange)
                    Text("▓▓▓▓▓▓▓")
                        .font(OddsFonts.statusBar)
                        .foregroundColor(OddsTheme.orange)
                    Text("▓▓▓▓▓▓▓")
                        .font(OddsFonts.statusBar)
                        .foregroundColor(OddsTheme.orange)
                }

                // App title
                Text("odds")
                    .font(OddsFonts.heroTitle)
                    .foregroundColor(OddsTheme.text1)

                Text("PREDICTION_MARKET_TRACKER")
                    .font(OddsFonts.heroSubtitle)
                    .foregroundColor(OddsTheme.text3)
                    .tracking(1.2)

                Spacer().frame(height: 20)

                // Boot sequence
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(0..<min(bootStep, bootSequence.count), id: \.self) { idx in
                        HStack {
                            Text("> \(bootSequence[idx].0)")
                                .font(OddsFonts.statusBar)
                                .foregroundColor(OddsTheme.text2)

                            Text(dotLeader(for: bootSequence[idx].0))
                                .font(OddsFonts.statusBar)
                                .foregroundColor(OddsTheme.text3)

                            Text(bootSequence[idx].1)
                                .font(Font.custom("IBM Plex Mono Medium", size: 10))
                                .foregroundColor(statusColor(for: bootSequence[idx].1))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)

                Spacer()

                // Action buttons
                if showActions {
                    HStack(spacing: 12) {
                        ActionButton(label: "ADD_MARKETS", isPrimary: true) {
                            onComplete()
                        }
                        ActionButton(label: "IMPORT_LIST", isPrimary: false) {
                            onComplete()
                        }
                    }
                    .transition(.opacity)
                }

                Spacer().frame(height: 20)
            }
            .frame(maxWidth: .infinity)

            // Footer
            HStack {
                Text("odds v0.1.0  |  onlymarket.com")
                    .font(OddsFonts.footerText)
                    .foregroundColor(OddsTheme.text3)
                    .tracking(0.6)
            }
            .frame(maxWidth: .infinity)
            .frame(height: OddsTheme.footerHeight)
            .background(OddsTheme.bgCard)
            .border(width: 1, edges: [.top], color: OddsTheme.border)
        }
        .frame(width: OddsTheme.panelWidth, height: OddsTheme.panelHeight)
        .background(OddsTheme.bg)
        .preferredColorScheme(.dark)
        .onAppear {
            animateBootSequence()
        }
    }

    private func dotLeader(for label: String) -> String {
        let maxLen = 16
        let dots = max(maxLen - label.count, 2)
        return String(repeating: ".", count: dots)
    }

    private func statusColor(for status: String) -> Color {
        switch status {
        case "OK": return OddsTheme.lime
        case "PENDING": return OddsTheme.orange
        default: return OddsTheme.text2
        }
    }

    private func animateBootSequence() {
        for i in 1...bootSequence.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                withAnimation(.easeIn(duration: 0.2)) {
                    bootStep = i
                }
                if i == bootSequence.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeIn(duration: 0.3)) {
                            showActions = true
                        }
                    }
                }
            }
        }
    }
}
