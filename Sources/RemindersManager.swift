import Foundation
import UserNotifications

final class RemindersManager {
    static let shared = RemindersManager()

    private init() {}

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            completion(granted)
        }
    }

    /// Schedule a repeating hourly reminder (demo). In a real app, let user configure times.
    func scheduleHourlyReminder() {
        requestAuthorization { granted in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "🚶 Time to move!"
            content.body = "Take a short walk to reach your daily goal."
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: true)
            let request = UNNotificationRequest(identifier: "health_hourly_reminder", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let e = error {
                    print("Notification schedule error: \(e)")
                }
            }
        }
    }
}
