import SwiftUI
import CoreText

enum OddsFonts {
    // Font family — IBM Plex Mono throughout
    private static let family = "IBM Plex Mono"
    private static let familyMedium = "IBM Plex Mono Medium"
    private static let familySemiBold = "IBM Plex Mono SemiBold"

    /// Register bundled fonts at app launch
    static func registerFonts() {
        let fontNames = [
            "IBMPlexMono-Regular",
            "IBMPlexMono-Medium",
            "IBMPlexMono-SemiBold"
        ]
        for name in fontNames {
            guard let url = Bundle.module.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts") else {
                print("[odds] Font not found: \(name)")
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    // Status bar — 10pt normal
    static let statusBar = Font.custom(family, size: 10)

    // Tab bar
    static let tabActive = Font.custom(familySemiBold, size: 9)
    static let tabInactive = Font.custom(family, size: 9)

    // Column headers — 9pt normal
    static let colHeader = Font.custom(family, size: 9)

    // Section labels — 9pt normal
    static let sectionLabel = Font.custom(family, size: 9)

    // Market name — 10.5pt normal
    static let marketName = Font.custom(family, size: 10.5)

    // Price/Prob — 11pt medium
    static let price = Font.custom(familyMedium, size: 11)

    // Change/Delta — 10pt normal
    static let change = Font.custom(family, size: 10)

    // Tag — 10pt normal
    static let tag = Font.custom(family, size: 10)

    // Footer ticker — 9pt / 8pt
    static let footerText = Font.custom(family, size: 9)
    static let footerSmall = Font.custom(family, size: 8)

    // Sparkline text — 10pt normal
    static let sparkline = Font.custom(family, size: 10)

    // Settings
    static let settingsLabel = Font.custom(family, size: 10)
    static let settingsValue = Font.custom(familyMedium, size: 10)
    static let settingsHeader = Font.custom(familySemiBold, size: 10)

    // Onboarding
    static let heroTitle = Font.custom(familyMedium, size: 16)
    static let heroSubtitle = Font.custom(family, size: 10)
}
