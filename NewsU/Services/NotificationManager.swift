import Foundation
import UserNotifications

/// Schedules the single daily "your brief is ready" reminder.
///
/// This is a local, repeating notification — it fires at the chosen time whether or
/// not the backend has finished curating, which keeps the app fully functional with
/// zero server setup. For a truly hands-off product you'd instead have the backend
/// send a silent push once the brief is written, then trigger a local notification
/// on receipt (see the note in /backend/README.md) so the reminder never fires early.
final class NotificationManager {
    static let shared = NotificationManager()
    private let identifier = "com.newsu.morningBrief"

    private init() {}

    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleDailyReminder(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "🙏 Your NewsU Morning Brief is ready"
        content.body = "Start with a moment of peace, then the news that matters to you."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
