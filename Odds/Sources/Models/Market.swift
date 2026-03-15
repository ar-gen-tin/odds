import Foundation

struct Market: Identifiable {
    let id: String
    let question: String
    let category: String
    let slug: String
    let yesPrice: Double
    let oneDayChange: Double
    let volume24h: Double
    var priceHistory: [Double]

    var trend: PriceTrend {
        if oneDayChange > 0.0001 { return .up }
        if oneDayChange < -0.0001 { return .down }
        return .flat
    }

    var polymarketURL: URL? {
        URL(string: "https://polymarket.com/event/\(slug)")
    }
}

enum PriceTrend {
    case up, down, flat
}
