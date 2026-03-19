import Foundation
import UserNotifications

/// Price alert model — notify when a market crosses a threshold
struct PriceAlert: Codable, Identifiable {
    let id: String // market id
    let marketName: String
    let threshold: Double // price to trigger (0-1)
    let direction: Direction // above or below

    enum Direction: String, Codable {
        case above, below
    }

    func shouldFire(currentPrice: Double) -> Bool {
        switch direction {
        case .above: return currentPrice >= threshold
        case .below: return currentPrice <= threshold
        }
    }
}

/// Manages price alerts and fires macOS notifications on threshold crossings
/// Pattern learned from upto's StatusMonitor notification system
@MainActor
final class AlertManager: ObservableObject {
    @Published var alerts: [PriceAlert] = []
    private var firedAlertIDs: Set<String> = []

    init() {
        loadAlerts()
        requestNotificationPermission()
    }

    // MARK: - Permission

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if !granted {
                print("[odds] Notification permission denied")
            }
        }
    }

    // MARK: - CRUD

    func addAlert(_ alert: PriceAlert) {
        guard !alerts.contains(where: { $0.id == alert.id && $0.direction == alert.direction }) else { return }
        alerts.append(alert)
        saveAlerts()
    }

    func removeAlert(id: String) {
        alerts.removeAll { $0.id == id }
        firedAlertIDs.remove(id)
        saveAlerts()
    }

    func removeAll() {
        alerts.removeAll()
        firedAlertIDs.removeAll()
        saveAlerts()
    }

    // MARK: - Check (called on each price update)

    func checkAlerts(against markets: [Market]) {
        for alert in alerts {
            guard !firedAlertIDs.contains(alert.id) else { continue }
            guard let market = markets.first(where: { $0.id == alert.id }) else { continue }

            if alert.shouldFire(currentPrice: market.yesPrice) {
                fireNotification(alert: alert, currentPrice: market.yesPrice)
                firedAlertIDs.insert(alert.id)
            }
        }
    }

    // MARK: - Notification (learned from upto)

    private func fireNotification(alert: PriceAlert, currentPrice: Double) {
        let content = UNMutableNotificationContent()
        let priceText = "\(Int((currentPrice * 100).rounded()))¢"
        let thresholdText = "\(Int((alert.threshold * 100).rounded()))¢"

        switch alert.direction {
        case .above:
            content.title = "▲ \(alert.marketName)"
            content.body = "Price hit \(priceText) (alert: ≥\(thresholdText))"
        case .below:
            content.title = "▼ \(alert.marketName)"
            content.body = "Price hit \(priceText) (alert: ≤\(thresholdText))"
        }
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "odds-alert-\(alert.id)-\(alert.direction.rawValue)",
            content: content,
            trigger: nil // fire immediately
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Persistence

    private func saveAlerts() {
        if let data = try? JSONEncoder().encode(alerts) {
            UserDefaults.standard.set(data, forKey: "price_alerts")
        }
    }

    private func loadAlerts() {
        guard let data = UserDefaults.standard.data(forKey: "price_alerts"),
              let decoded = try? JSONDecoder().decode([PriceAlert].self, from: data) else { return }
        alerts = decoded
    }
}
