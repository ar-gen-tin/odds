import AppKit

/// Dynamic menu bar icon that reflects market trend
/// Inspired by upto's color-coded triangle approach
enum MenuBarIcon {
    /// Generate a status-aware menu bar icon
    /// - Green up-triangle: markets trending up
    /// - Red down-triangle: markets trending down
    /// - Orange neutral: mixed/flat
    /// - Gray: offline/no data
    static func statusImage(isLive: Bool, trend: MarketTrend) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            let color: NSColor
            switch (isLive, trend) {
            case (false, _):
                color = NSColor(red: 0.32, green: 0.32, blue: 0.41, alpha: 1) // text3
            case (true, .bullish):
                color = NSColor(red: 0.72, green: 1.0, blue: 0.34, alpha: 1) // lime
            case (true, .bearish):
                color = NSColor(red: 1.0, green: 0.23, blue: 0.36, alpha: 1) // downRed
            case (true, .neutral):
                color = NSColor(red: 1.0, green: 0.42, blue: 0.17, alpha: 1) // orange
            }

            // Draw a small filled triangle (pointing up or down based on trend)
            let path = NSBezierPath()
            let cx = rect.midX
            let cy = rect.midY
            let half: CGFloat = 5

            if trend == .bearish {
                // Down triangle
                path.move(to: NSPoint(x: cx - half, y: cy + half * 0.7))
                path.line(to: NSPoint(x: cx + half, y: cy + half * 0.7))
                path.line(to: NSPoint(x: cx, y: cy - half * 0.7))
            } else {
                // Up triangle (also for neutral/offline)
                path.move(to: NSPoint(x: cx - half, y: cy - half * 0.7))
                path.line(to: NSPoint(x: cx + half, y: cy - half * 0.7))
                path.line(to: NSPoint(x: cx, y: cy + half * 0.7))
            }
            path.close()

            color.setFill()
            path.fill()

            return true
        }
        image.isTemplate = false
        return image
    }

    enum MarketTrend {
        case bullish, bearish, neutral
    }
}
