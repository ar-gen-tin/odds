import Foundation

enum PolymarketAPI {
    static let baseURL = "https://gamma-api.polymarket.com"

    static func search(query: String, limit: Int = 10) async throws -> [SearchResult] {
        guard !query.isEmpty else { return [] }

        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(baseURL)/public-search?q=\(encoded)&limit_per_type=\(limit)"

        guard let url = URL(string: urlString) else {
            print("[odds] Invalid URL: \(urlString)")
            return []
        }

        print("[odds] Searching: \(urlString)")

        let (data, response) = try await URLSession.shared.data(from: url)

        if let httpResponse = response as? HTTPURLResponse {
            print("[odds] HTTP \(httpResponse.statusCode), body size: \(data.count) bytes")
        }

        // The API returns events at top level, parse flexibly
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let eventsArray = json?["events"] as? [[String: Any]] else {
            print("[odds] No 'events' key in response")
            return []
        }

        print("[odds] Found \(eventsArray.count) events")

        return eventsArray.compactMap { parseEvent($0) }
    }

    private static func parseEvent(_ dict: [String: Any]) -> SearchResult? {
        guard let id = dict["id"] as? String ?? (dict["id"] as? Int).map(String.init),
              let title = dict["title"] as? String,
              let slug = dict["slug"] as? String else {
            return nil
        }

        let volume = dict["volume"] as? Double ?? 0

        // Parse markets array
        let marketsArray = dict["markets"] as? [[String: Any]] ?? []
        let markets = marketsArray.compactMap { parseMarket($0) }

        // Get category from first market's groupItemTitle or tag
        let category = (marketsArray.first?["groupItemTitle"] as? String) ?? ""

        return SearchResult(
            id: "\(id)",
            title: title,
            slug: slug,
            category: category,
            volume: volume,
            markets: markets
        )
    }

    private static func parseMarket(_ dict: [String: Any]) -> SearchResult.MarketInfo? {
        guard let id = dict["id"] as? String ?? (dict["id"] as? Int).map(String.init) else {
            return nil
        }

        let question = dict["question"] as? String ?? ""
        let slug = dict["slug"] as? String ?? ""
        let outcomePrices = parseOutcomePrices(dict["outcomePrices"] as? String)
        let change = dict["oneDayPriceChange"] as? Double

        return SearchResult.MarketInfo(
            id: "\(id)",
            question: question,
            slug: slug,
            outcomePrices: outcomePrices,
            oneDayPriceChange: change
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
}

// MARK: - Search Result

struct SearchResult: Identifiable {
    let id: String
    let title: String
    let slug: String
    let category: String
    let volume: Double
    let markets: [MarketInfo]

    struct MarketInfo: Identifiable {
        let id: String
        let question: String
        let slug: String
        let outcomePrices: [Double]
        let oneDayPriceChange: Double?

        var yesPrice: Double { outcomePrices.first ?? 0 }
    }

    var polymarketURL: URL? {
        URL(string: "https://polymarket.com/event/\(slug)")
    }
}
