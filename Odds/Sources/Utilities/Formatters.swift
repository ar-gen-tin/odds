import Foundation

/// Rule 5: Isolated shared formatters (extracted from duplicate code)
enum Fmt {
    static func volume(_ vol: Double) -> String {
        if vol >= 1_000_000 { return String(format: "$%.1fM", vol / 1_000_000) }
        if vol >= 1_000 { return String(format: "$%.0fK", vol / 1_000) }
        return String(format: "$%.0f", vol)
    }

    static func delta(_ change: Double) -> String {
        if abs(change) < 0.0001 { return ".00" }
        let sign = change > 0 ? "+" : "-"
        return String(format: "%@.%02d", sign, abs(Int((change * 100).rounded())))
    }

    static func safePrice(_ price: Double) -> Double {
        guard price.isFinite else { return 0 }
        return max(0, min(1, price))
    }

    static func tickerName(_ question: String) -> String {
        let skip: Set<String> = ["by", "in", "the", "a", "an", "before", "after", "will", "be", "of", "to", "for"]
        let words = question
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
            .components(separatedBy: " ")
            .filter { !skip.contains($0.lowercased()) }
        return String(words.prefix(2).joined().uppercased().prefix(8))
    }
}
