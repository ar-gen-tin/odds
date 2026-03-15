import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var store: MarketStore
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Back navigation
            Button {
                isPresented = false
            } label: {
                HStack(spacing: 6) {
                    Text("←")
                        .font(OddsFonts.statusBar)
                        .foregroundColor(OddsTheme.text2)
                    Text("BACK_TO_FEED")
                        .font(OddsFonts.statusBar)
                        .foregroundColor(OddsTheme.text2)
                        .tracking(0.6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, OddsTheme.horizontalPadding)
                .frame(height: OddsTheme.statusBarHeight)
                .border(width: 1, edges: [.bottom], color: OddsTheme.border)
            }
            .buttonStyle(.plain)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // DISPLAY
                    terminalSection(title: "DISPLAY") {
                        terminalRow(label: "PRICE_FORMAT") {
                            bracketPicker(
                                items: PriceFormat.allCases,
                                selected: settings.priceFormat,
                                label: { $0.example }
                            ) { settings.priceFormat = $0 }
                        }

                        terminalRow(label: "SPARKLINES") {
                            bracketToggle(
                                onLabel: "ON", offLabel: "OFF",
                                isOn: $settings.showSparklines
                            )
                        }

                        terminalRow(label: "REFRESH_RATE") {
                            bracketPicker(
                                items: [10.0, 30.0, 60.0],
                                selected: settings.refreshInterval,
                                label: { "\(Int($0))s" }
                            ) { settings.refreshInterval = $0 }
                        }
                    }

                    // LANGUAGE
                    terminalSection(title: "LANGUAGE") {
                        terminalRow(label: "LOCALE") {
                            bracketPicker(
                                items: AppLanguage.allCases,
                                selected: settings.language,
                                label: { $0.label }
                            ) { settings.language = $0 }
                        }
                    }

                    // DATA
                    terminalSection(title: "DATA") {
                        terminalInfoRow(label: "SOURCE", value: "POLYMARKET")
                        terminalInfoRow(label: "STATUS", value: "CONNECTED", valueColor: OddsTheme.lime)
                        terminalInfoRow(label: "LAST_SYNC", value: formatLastSync())
                    }

                    // SYSTEM
                    terminalSection(title: "SYSTEM") {
                        terminalInfoRow(label: "VERSION", value: "0.1.0")

                        terminalRow(label: "LAUNCH_LOGIN") {
                            bracketToggle(
                                onLabel: "ON", offLabel: "OFF",
                                isOn: $settings.launchAtLogin
                            )
                        }
                    }

                    // Quit button
                    Button {
                        NSApplication.shared.terminate(nil)
                    } label: {
                        Text("QUIT_ODDS")
                            .font(OddsFonts.settingsValue)
                            .foregroundColor(OddsTheme.orange)
                            .tracking(0.8)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .overlay(
                                Rectangle()
                                    .stroke(OddsTheme.orange, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, OddsTheme.horizontalPadding)
                    .padding(.vertical, 16)
                }
            }
        }
        .background(OddsTheme.bg)
    }

    // MARK: - Terminal-style Components

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
        items: [T],
        selected: T,
        label: @escaping (T) -> String,
        onSelect: @escaping (T) -> Void
    ) -> some View {
        HStack(spacing: 4) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                Button {
                    onSelect(item)
                } label: {
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
            Button {
                isOn.wrappedValue = true
            } label: {
                Text("[\(onLabel)]")
                    .font(OddsFonts.settingsValue)
                    .foregroundColor(isOn.wrappedValue ? OddsTheme.text1 : OddsTheme.text3)
            }
            .buttonStyle(.plain)

            Button {
                isOn.wrappedValue = false
            } label: {
                Text("[\(offLabel)]")
                    .font(OddsFonts.settingsValue)
                    .foregroundColor(!isOn.wrappedValue ? OddsTheme.text1 : OddsTheme.text3)
            }
            .buttonStyle(.plain)
        }
    }

    private func formatLastSync() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: store.lastUpdated) + " UTC"
    }
}
