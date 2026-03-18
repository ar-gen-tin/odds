import Foundation

/// Frozen contract: all API calls return [Market]
enum PolymarketAPI {
    static let baseURL = "https://gamma-api.polymarket.com"

    // 10s timeout
    private static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 15
        return URLSession(configuration: config)
    }()

    // MARK: - Fetch Trending (real data)

    static func fetchTrending(limit: Int = 20) async throws -> [Market] {
        let urlString = "\(baseURL)/events?limit=\(limit)&active=true&closed=false&order=volume24hr&ascending=false"
        guard let url = URL(string: urlString) else { throw APIError.invalidURL }

        let (data, response) = try await session.data(from: url)
        try validateResponse(response)

        let events = try parseEvents(data)
        return events.compactMap { parseEvent($0, filterPrice: true) }
    }

    // MARK: - Search

    static func search(query: String, limit: Int = 10) async throws -> [Market] {
        guard !query.isEmpty else { return [] }

        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(baseURL)/public-search?q=\(encoded)&limit_per_type=\(limit)"
        guard let url = URL(string: urlString) else { throw APIError.invalidURL }

        let (data, response) = try await session.data(from: url)
        try validateResponse(response)

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let eventsArray = json?["events"] as? [[String: Any]] else { return [] }

        return eventsArray.compactMap { parseEvent($0) }
    }

    // MARK: - Parsing

    private static func parseEvents(_ data: Data) throws -> [[String: Any]] {
        guard let array = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw APIError.parseError
        }
        return array
    }

    /// Unified event parser for both trending and search results
    private static func parseEvent(_ dict: [String: Any], filterPrice: Bool = false) -> Market? {
        guard let title = dict["title"] as? String,
              let slug = dict["slug"] as? String else { return nil }

        let id = stringID(dict["id"])
        let volume = dict["volume24hr"] as? Double ?? dict["volume"] as? Double ?? 0
        let markets = dict["markets"] as? [[String: Any]] ?? []

        let first = markets.first
        let outcomePrices = parseOutcomePrices(first?["outcomePrices"] as? String)
        let yesPrice = outcomePrices.first ?? 0

        if filterPrice {
            guard yesPrice > 0.01 && yesPrice < 0.99 else { return nil }
        }

        let change = first?["oneDayPriceChange"] as? Double ?? 0
        let rawCategory = first?["groupItemTitle"] as? String
        let category = (rawCategory?.isEmpty == false ? rawCategory!.uppercased() : nil) ?? guessCategory(title)

        return Market(
            id: id,
            question: String(title.prefix(50)),
            category: category,
            slug: slug,
            yesPrice: yesPrice,
            oneDayChange: change,
            volume24h: volume,
            priceHistory: [yesPrice],
            lastUpdated: Date()
        )
    }

    private static func parseOutcomePrices(_ raw: String?) -> [Double] {
        guard let raw else { return [] }
        let cleaned = raw
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
            .replacingOccurrences(of: "\"", with: "")
        return cleaned.split(separator: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
    }

    private static func stringID(_ value: Any?) -> String {
        if let s = value as? String { return s }
        if let i = value as? Int { return String(i) }
        if let d = value as? Double { return String(Int(d)) }
        return UUID().uuidString
    }

    private static func guessCategory(_ title: String) -> String {
        let t = title.lowercased()
        if t.contains("bitcoin") || t.contains("crypto") || t.contains("ethereum") || t.contains("btc") { return "CRYPTO" }
        if t.contains("trump") || t.contains("president") || t.contains("election") || t.contains("democrat") || t.contains("republican") { return "POLITICS" }
        if t.contains("fed") || t.contains("rate") || t.contains("recession") || t.contains("gdp") || t.contains("tariff") { return "ECONOMY" }
        if t.contains("nba") || t.contains("nfl") || t.contains("fifa") || t.contains("champion") { return "SPORTS" }
        if t.contains("gpt") || t.contains("openai") || t.contains("ai ") { return "AI" }
        return "MARKETS"
    }

    private static func validateResponse(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { throw APIError.networkError }
        guard (200...299).contains(http.statusCode) else { throw APIError.httpError(http.statusCode) }
    }
}

// MARK: - Error Types

enum APIError: LocalizedError {
    case invalidURL
    case networkError
    case httpError(Int)
    case parseError

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .networkError: return "Network error"
        case .httpError(let code): return "HTTP \(code)"
        case .parseError: return "Parse error"
        }
    }
}

