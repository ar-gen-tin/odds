import SwiftUI

enum OddsTheme {
    // Backgrounds — navy-tinted near-black (from .pen design)
    static let bg = Color(hex: 0x0A0A0F)
    static let bgCard = Color(hex: 0x141418)
    static let bgElevated = Color(hex: 0x1C1C22)

    // Borders — solid color (not translucent)
    static let border = Color(hex: 0x2A2A30)

    // Text hierarchy — cool blue-white tones
    static let text1 = Color(hex: 0xE8E8F0)
    static let text2 = Color(hex: 0x6B6B80)
    static let text3 = Color(hex: 0x52526A)

    // Semantic — orange accent, aurora-lime positive, hot-pink negative
    static let orange = Color(hex: 0xFF6B2C)
    static let lime = Color(hex: 0xB8FF57)
    static let downRed = Color(hex: 0xFF3B5C)

    // Layout — matches .pen DESIGN_SPECS
    static let panelWidth: CGFloat = 380
    static let panelHeight: CGFloat = 620
    static let statusBarHeight: CGFloat = 28
    static let tabBarHeight: CGFloat = 28
    static let tableHeaderHeight: CGFloat = 22
    static let rowHeight: CGFloat = 36
    static let categoryHeight: CGFloat = 24
    static let footerHeight: CGFloat = 24
    static let horizontalPadding: CGFloat = 12

    // Column widths
    static let colIdxWidth: CGFloat = 28
    static let colProbWidth: CGFloat = 50
    static let colDeltaWidth: CGFloat = 36
    static let colTrendWidth: CGFloat = 56

    // App metadata
    static let appVersion = "1.0.1"
}

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
