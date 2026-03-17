import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var store: MarketStore
    @Binding var isPresented: Bool
    @State private var isBackHovered = false

    private var lang: AppLanguage { settings.language }

    var body: some View {
        VStack(spacing: 0) {
            Button {
                isPresented = false
            } label: {
                HStack(spacing: 6) {
                    Text("←")
                        .font(OddsFonts.statusBar)
                        .foregroundColor(isBackHovered ? OddsTheme.orange : OddsTheme.text2)
                    Text(L10n.s(.backToFeed, lang))
                        .font(OddsFonts.statusBar)
                        .foregroundColor(isBackHovered ? OddsTheme.text1 : OddsTheme.text2)
                        .tracking(0.6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, OddsTheme.horizontalPadding)
                .frame(height: OddsTheme.statusBarHeight)
                .background(isBackHovered ? OddsTheme.bgElevated : Color.clear)
                .border(width: 1, edges: [.bottom], color: OddsTheme.border)
            }
            .buttonStyle(.plain)
            .onHover { isBackHovered = $0 }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    terminalSection(title: L10n.s(.display, lang)) {
                        terminalRow(label: L10n.s(.priceFormat, lang)) {
                            bracketPicker(
                                items: PriceFormat.allCases,
                                selected: settings.priceFormat,
                                label: { $0.example }
                            ) { settings.priceFormat = $0 }
                        }

                        terminalRow(label: L10n.s(.sparklines, lang)) {
                            bracketToggle(
                                onLabel: "ON", offLabel: "OFF",
                                isOn: $settings.showSparklines
                            )
                        }

                        terminalRow(label: L10n.s(.refreshRate, lang)) {
                            bracketPicker(
                                items: [10.0, 30.0, 60.0],
                                selected: settings.refreshInterval,
                                label: { "\(Int($0))s" }
                            ) { settings.refreshInterval = $0 }
                        }
                    }

                    terminalSection(title: L10n.s(.language, lang)) {
                        terminalRow(label: L10n.s(.locale, lang)) {
                            bracketPicker(
                                items: AppLanguage.allCases,
                                selected: settings.language,
                                label: { $0.label }
                            ) { settings.language = $0 }
                        }
                    }

                    terminalSection(title: L10n.s(.data, lang)) {
                        terminalInfoRow(label: L10n.s(.source, lang), value: "POLYMARKET")
                        if store.error != nil {
                            terminalInfoRow(label: L10n.s(.status, lang), value: "OFFLINE", valueColor: OddsTheme.downRed)
                        } else if store.isLive {
                            terminalInfoRow(label: L10n.s(.status, lang), value: L10n.s(.connected, lang), valueColor: OddsTheme.lime)
                        } else {
                            terminalInfoRow(label: L10n.s(.status, lang), value: "...", valueColor: OddsTheme.text3)
                        }
                        terminalInfoRow(label: L10n.s(.lastSync, lang), value: formatLastSync())
                    }

                    terminalSection(title: L10n.s(.system, lang)) {
                        terminalInfoRow(label: L10n.s(.version, lang), value: OddsTheme.appVersion)
                    }

                    // A8: launchAtLogin removed (not implemented)

                    terminalSection(title: L10n.s(.shortcuts, lang)) {
                        terminalInfoRow(label: L10n.s(.quit, lang), value: "⌘Q")
                        terminalInfoRow(label: L10n.s(.search, lang), value: "⌕")
                        terminalInfoRow(label: L10n.s(.close, lang), value: "ESC")
                        terminalInfoRow(label: L10n.s(.expand, lang), value: "click")
                    }

                    HStack(spacing: 12) {
                        ActionButton(label: L10n.s(.resetSetup, lang), isPrimary: false) {
                            settings.hasCompletedOnboarding = false
                        }
                        ActionButton(label: L10n.s(.quitOdds, lang), isPrimary: true) {
                            NSApplication.shared.terminate(nil)
                        }
                    }
                    .padding(.horizontal, OddsTheme.horizontalPadding)
                    .padding(.vertical, 16)
                }
            }
        }
        .background(OddsTheme.bg)
    }

    // MARK: - Components

    @ViewBuilder
    private func terminalSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(OddsFonts.settingsHeader)
                .foregroundColor(OddsTheme.orange)
                .tracking(1.5)
                .padding(.bottom, 8)
            content()
        }
        .padding(.horizontal, OddsTheme.horizontalPadding)
        .padding(.vertical, 12)
        .border(width: 1, edges: [.bottom], color: OddsTheme.border)
    }

    @ViewBuilder
    private func terminalRow(label: String, @ViewBuilder trailing: () -> some View) -> some View {
        HStack {
            Text("├─")
                .font(OddsFonts.settingsLabel)
                .foregroundColor(OddsTheme.text3)
            Text(label)
                .font(OddsFonts.settingsLabel)
                .foregroundColor(OddsTheme.text2)
                .tracking(0.6)
            Spacer()
            trailing()
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func terminalInfoRow(label: String, value: String, valueColor: Color = OddsTheme.text1) -> some View {
        HStack {
            Text("├─")
                .font(OddsFonts.settingsLabel)
                .foregroundColor(OddsTheme.text3)
            Text(label)
                .font(OddsFonts.settingsLabel)
                .foregroundColor(OddsTheme.text2)
                .tracking(0.6)
            Spacer()
            Text(value)
                .font(OddsFonts.settingsValue)
                .foregroundColor(valueColor)
        }
        .padding(.vertical, 4)
    }

    private func bracketPicker<T: Hashable>(
        items: [T], selected: T,
        label: @escaping (T) -> String,
        onSelect: @escaping (T) -> Void
    ) -> some View {
        HStack(spacing: 4) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                Button { onSelect(item) } label: {
                    Text("[\(label(item))]")
                        .font(OddsFonts.settingsValue)
                        .foregroundColor(selected == item ? OddsTheme.text1 : OddsTheme.text3)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func bracketToggle(onLabel: String, offLabel: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 4) {
            Button { isOn.wrappedValue = true } label: {
                Text("[\(onLabel)]")
                    .font(OddsFonts.settingsValue)
                    .foregroundColor(isOn.wrappedValue ? OddsTheme.text1 : OddsTheme.text3)
            }.buttonStyle(.plain)
            Button { isOn.wrappedValue = false } label: {
                Text("[\(offLabel)]")
                    .font(OddsFonts.settingsValue)
                    .foregroundColor(!isOn.wrappedValue ? OddsTheme.text1 : OddsTheme.text3)
            }.buttonStyle(.plain)
        }
    }

    private func formatLastSync() -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        f.timeZone = TimeZone(identifier: "UTC")
        return f.string(from: store.lastUpdated) + " UTC"
    }
}
