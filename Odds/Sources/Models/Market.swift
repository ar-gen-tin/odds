import Foundation

/// Frozen contract — all market data flows through this type
struct Market: Identifiable, Codable, Hashable {
    let id: String
    let question: String
    let category: String
    let slug: String
    var yesPrice: Double
    var oneDayChange: Double
    var volume24h: Double
    var priceHistory: [Double]
    var lastUpdated: Date

    var priceInCents: Int { Int((yesPrice * 100).rounded()) }
    var changePercent: Double { oneDayChange * 100 }

    var trend: PriceTrend {
        if oneDayChange > 0.0001 { return .up }
        if oneDayChange < -0.0001 { return .down }
        return .flat
    }

    var changeText: String {
        let sign = trend == .up ? "+" : ""
        return "\(sign)\(String(format: "%.1f", changePercent))%"
    }

    var polymarketURL: URL? {
        URL(string: "https://polymarket.com/event/\(slug)")
    }
}

enum PriceTrend: String, Codable {
    case up, down, flat
}
