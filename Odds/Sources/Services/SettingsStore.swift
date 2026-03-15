import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable {
    case en = "en"
    case zh = "zh"
    case ja = "ja"

    var label: String {
        switch self {
        case .en: return "EN"
        case .zh: return "中"
        case .ja: return "日"
        }
    }
}

enum PriceFormat: String, CaseIterable {
    case cents = "cents"
    case dollar = "dollar"
    case percent = "percent"

    func display(for price: Double) -> String {
        let cents = Int((price * 100).rounded())
        switch self {
        case .cents: return "\(cents)¢"
        case .dollar: return String(format: "$%.2f", price)
        case .percent: return "\(cents)%"
        }
    }

    var example: String {
        switch self {
        case .cents: return "72¢"
        case .dollar: return "$0.72"
        case .percent: return "72%"
        }
    }
}

// P0 Fix: Use @Published + UserDefaults instead of @AppStorage in ObservableObject
final class SettingsStore: ObservableObject {
    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: "language") }
    }
    @Published var priceFormat: PriceFormat {
        didSet { UserDefaults.standard.set(priceFormat.rawValue, forKey: "priceFormat") }
    }
    @Published var refreshInterval: Double {
        didSet { UserDefaults.standard.set(refreshInterval, forKey: "refreshInterval") }
    }
    @Published var showSparklines: Bool {
        didSet { UserDefaults.standard.set(showSparklines, forKey: "showSparklines") }
    }
    @Published var launchAtLogin: Bool {
        didSet { UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin") }
    }
    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }

    init() {
        let defaults = UserDefaults.standard
        self.language = AppLanguage(rawValue: defaults.string(forKey: "language") ?? "en") ?? .en
        self.priceFormat = PriceFormat(rawValue: defaults.string(forKey: "priceFormat") ?? "cents") ?? .cents
        let interval = defaults.double(forKey: "refreshInterval")
        self.refreshInterval = interval > 0 ? interval : 30
        self.showSparklines = defaults.object(forKey: "showSparklines") as? Bool ?? true
        self.launchAtLogin = defaults.bool(forKey: "launchAtLogin")
        self.hasCompletedOnboarding = defaults.bool(forKey: "hasCompletedOnboarding")
    }

    func formatPrice(_ price: Double) -> String {
        priceFormat.display(for: price)
    }
}
