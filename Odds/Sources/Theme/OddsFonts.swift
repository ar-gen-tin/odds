import SwiftUI
import CoreText

enum OddsFonts {
    // Font names — use PostScript names for Font.custom()
    private static let regular = "IBMPlexMono"
    private static let medium = "IBMPlexMono-Medium"
    private static let semiBold = "IBMPlexMono-SemiBold"

    /// Register bundled fonts at app launch
    static func registerFonts() {
        for name in ["IBMPlexMono-Regular", "IBMPlexMono-Medium", "IBMPlexMono-SemiBold"] {
            guard let url = Bundle.module.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts") else {
                print("[odds] Font not found: \(name)")
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    // Status bar — 10pt
    static let statusBar = Font.custom(regular, size: 10)

    // Tab bar
    static let tabActive = Font.custom(semiBold, size: 9)
    static let tabInactive = Font.custom(regular, size: 9)

    // Column headers — 9pt
    static let colHeader = Font.custom(regular, size: 9)

    // Section labels — 9pt
    static let sectionLabel = Font.custom(regular, size: 9)

    // Market name — 10.5pt
    static let marketName = Font.custom(regular, size: 10.5)

    // Price/Prob — 11pt medium
    static let price = Font.custom(medium, size: 11)

    // Change/Delta — 10pt
    static let change = Font.custom(regular, size: 10)

    // Tag — 10pt
    static let tag = Font.custom(regular, size: 10)

    // C4: Footer minimum 9pt (was 8pt)
    static let footerText = Font.custom(regular, size: 9)
    static let footerSmall = Font.custom(regular, size: 9)

    // Sparklines
    static let sparkline = Font.custom(regular, size: 10)
    static let sparklineSmall = Font.custom(regular, size: 9)
    static let sparklineExpanded = Font.custom(regular, size: 9)

    // Medium weight labels
    static let labelMedium = Font.custom(medium, size: 10)
    static let buttonLabel = Font.custom(medium, size: 9)
    static let buttonSmall = Font.custom(medium, size: 11)

    // Settings
    static let settingsLabel = Font.custom(regular, size: 10)
    static let settingsValue = Font.custom(medium, size: 10)
    static let settingsHeader = Font.custom(semiBold, size: 10)

    // Onboarding
    static let heroTitle = Font.custom(medium, size: 16)
    static let heroSubtitle = Font.custom(regular, size: 10)
}
