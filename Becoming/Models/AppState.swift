import SwiftUI
import Foundation

class AppState: ObservableObject {
    @Published var isOnboarded: Bool = false
    @Published var hasRecordedToday: Bool = false
    @Published var currentStreak: Int = 0
    @Published var notificationTime: Date = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var oneTakeMode: Bool = true
    
    init() {
        loadUserDefaults()
    }
    
    private func loadUserDefaults() {
        isOnboarded = UserDefaults.standard.bool(forKey: "isOnboarded")
        hasRecordedToday = UserDefaults.standard.bool(forKey: "hasRecordedToday")
        currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        oneTakeMode = UserDefaults.standard.bool(forKey: "oneTakeMode")
        
        if let timeData = UserDefaults.standard.data(forKey: "notificationTime"),
           let time = try? JSONDecoder().decode(Date.self, from: timeData) {
            notificationTime = time
        }
    }
    
    func saveUserDefaults() {
        UserDefaults.standard.set(isOnboarded, forKey: "isOnboarded")
        UserDefaults.standard.set(hasRecordedToday, forKey: "hasRecordedToday")
        UserDefaults.standard.set(currentStreak, forKey: "currentStreak")
        UserDefaults.standard.set(oneTakeMode, forKey: "oneTakeMode")
        
        if let timeData = try? JSONEncoder().encode(notificationTime) {
            UserDefaults.standard.set(timeData, forKey: "notificationTime")
        }
    }
    
    func completeOnboarding() {
        isOnboarded = true
        saveUserDefaults()
    }
    
    func recordedToday() {
        hasRecordedToday = true
        saveUserDefaults()
    }
}
