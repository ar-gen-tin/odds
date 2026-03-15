import Foundation

enum MockData {
    static let watchlistMarkets: [Market] = [
        Market(
            id: "btc150k",
            question: "Bitcoin $150K by Jul '26",
            category: "CRYPTO",
            slug: "will-bitcoin-mass-150k-in-2026",
            yesPrice: 0.72,
            oneDayChange: 0.052,
            volume24h: 2_400_000,
            priceHistory: [0.60, 0.62, 0.65, 0.63, 0.67, 0.70, 0.72]
        ),
        Market(
            id: "fedcut",
            question: "Fed rate cut Jun '26",
            category: "ECONOMY",
            slug: "fed-cuts-rates-june-2026",
            yesPrice: 0.34,
            oneDayChange: -0.081,
            volume24h: 890_000,
            priceHistory: [0.45, 0.42, 0.40, 0.38, 0.36, 0.35, 0.34]
        ),
        Market(
            id: "gpt5",
            question: "GPT-5 before Sep '26",
            category: "AI",
            slug: "gpt-5-release-date",
            yesPrice: 0.56,
            oneDayChange: 0.123,
            volume24h: 1_700_000,
            priceHistory: [0.35, 0.38, 0.42, 0.45, 0.48, 0.52, 0.56]
        ),
    ]

    static let trendingMarkets: [Market] = [
        Market(
            id: "ethetf",
            question: "Ethereum ETF '26",
            category: "CRYPTO",
            slug: "ethereum-etf-approved-2026",
            yesPrice: 0.81,
            oneDayChange: 0.024,
            volume24h: 3_100_000,
            priceHistory: [0.72, 0.74, 0.76, 0.78, 0.79, 0.80, 0.81]
        ),
        Market(
            id: "lakers",
            question: "Lakers NBA champs '26",
            category: "SPORTS",
            slug: "nba-championship-2026",
            yesPrice: 0.12,
            oneDayChange: -0.037,
            volume24h: 560_000,
            priceHistory: [0.16, 0.15, 0.14, 0.13, 0.13, 0.12, 0.12]
        ),
        Market(
            id: "recession",
            question: "US recession Q4 '26",
            category: "ECONOMY",
            slug: "us-recession-2026",
            yesPrice: 0.29,
            oneDayChange: 0.002,
            volume24h: 420_000,
            priceHistory: [0.28, 0.29, 0.28, 0.29, 0.29, 0.29, 0.29]
        ),
        Market(
            id: "chinataiwan",
            question: "China-Taiwan conflict '26",
            category: "POLITICS",
            slug: "china-taiwan-conflict-2026",
            yesPrice: 0.08,
            oneDayChange: -0.012,
            volume24h: 340_000,
            priceHistory: [0.10, 0.09, 0.09, 0.08, 0.08, 0.08, 0.08]
        ),
    ]
}
