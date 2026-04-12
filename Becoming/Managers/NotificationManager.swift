import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    @Published var hasPermission = false
    
    private let motivationalMessages = [
        "Day %d. Don't break it.",
        "You haven't spoken today.",
        "Future you is waiting.",
        "Keep the streak alive.",
        "Time to show up.",
        "Your story continues today.",
        "Don't let today slip by.",
        "Consistency builds character."
    ]
    
    init() {
        checkPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.hasPermission = granted
            }
        }
    }
    
    private func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasPermission = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleDailyNotification(at time: Date, streak: Int, userName: String = "") {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        let message = motivationalMessages.randomElement() ?? "Time to record your daily log."
        let title = userName.isEmpty ? "Becoming" : "Hey \(userName)"
        content.title = title
        content.body = String(format: message, streak + 1)
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func sendFollowUpReminder(streak: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Becoming"
        content.body = "Still time to keep your streak alive."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false) // 1 hour later
        let request = UNNotificationRequest(identifier: "followUpReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
