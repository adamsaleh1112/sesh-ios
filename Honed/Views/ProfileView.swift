import SwiftUI
import Foundation

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var calendarManager: CalendarManager
    
    var body: some View {
        NavigationView {
            ZStack {
                appState.theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        VStack(spacing: 16) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(appState.theme.cardBackground)
                                    .frame(width: 100, height: 100)
                                
                                Text(initials)
                                    .font(.system(size: 40, weight: .medium))
                                    .foregroundColor(appState.theme.textPrimary)
                            }
                            
                            // Name
                            Text(appState.userName.isEmpty ? "Your Name" : appState.userName)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(appState.theme.textPrimary)
                        }
                        .padding(.top, 20)
                        
                        // Stats Row
                        HStack(spacing: 24) {
                            StatBox(value: "\(totalWorkouts)", label: "Workouts")
                            StatBox(value: "\(currentStreak)", label: "Day Streak")
                            StatBox(value: "\(longestStreak)", label: "Best Streak")
                        }
                        .padding(.horizontal, 24)
                        
                        // Settings Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Settings")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(appState.theme.textPrimary)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 12) {
                                // Profile Settings
                                SettingsSection(title: "Profile") {
                                    VStack(spacing: 16) {
                                        HStack {
                                            Image(systemName: "person")
                                                .font(.system(size: 18))
                                                .foregroundColor(.gray)
                                                .frame(width: 28)
                                            Text("Your name")
                                                .font(.system(size: 16))
                                                .foregroundColor(appState.theme.textPrimary)
                                            Spacer()
                                            TextField("Enter name", text: $appState.userName)
                                                .font(.system(size: 16))
                                                .foregroundColor(appState.theme.textPrimary)
                                                .multilineTextAlignment(.trailing)
                                                .frame(maxWidth: 150)
                                        }
                                    }
                                }
                                
                                // About Section
                                SettingsSection(title: "About") {
                                    VStack(spacing: 16) {
                                        HStack {
                                            Image(systemName: "info.circle")
                                                .font(.system(size: 18))
                                                .foregroundColor(.gray)
                                                .frame(width: 28)
                                            InfoRow(label: "Version", value: "1.0.0")
                                        }
                                    }
                                }
                                
                                // Reset Section
                                SettingsSection(title: "Reset") {
                                    VStack(spacing: 16) {
                                        HStack {
                                            Image(systemName: "trash")
                                                .font(.system(size: 18))
                                                .foregroundColor(.red)
                                                .frame(width: 28)
                                            Button("Reset All Data") {
                                                resetAllData()
                                            }
                                            .foregroundColor(.red)
                                            Spacer()
                                        }
                                    }
                                }
                                
                                // Dev Section
                                SettingsSection(title: "Dev") {
                                    VStack(spacing: 16) {
                                        HStack {
                                            Image(systemName: "arrow.counterclockwise")
                                                .font(.system(size: 18))
                                                .foregroundColor(.orange)
                                                .frame(width: 28)
                                            Button("Back to Onboarding") {
                                                withAnimation(.easeInOut(duration: 0.6)) {
                                                    appState.isOnboarded = false
                                                }
                                            }
                                            .foregroundColor(.orange)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
    
    private var initials: String {
        let name = appState.userName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return "👤" }
        
        let components = name.split(separator: " ")
        if components.count > 1 {
            let first = String(components[0].prefix(1)).uppercased()
            let last = String(components[components.count - 1].prefix(1)).uppercased()
            return first + last
        } else {
            return String(name.prefix(2)).uppercased()
        }
    }
    
    private var totalWorkouts: Int {
        calendarManager.calendarEntries.count
    }
    
    private var currentStreak: Int {
        calculateStreak()
    }
    
    private var longestStreak: Int {
        calculateLongestStreak()
    }
    
    private func calculateStreak() -> Int {
        let entries = calendarManager.calendarEntries.sorted { $0.date > $1.date }
        guard !entries.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()
        
        // If no entry today, start checking from yesterday
        if !calendarManager.hasEntryToday() {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }
        
        for entry in entries {
            if calendar.isDate(entry.date, inSameDayAs: checkDate) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else if entry.date < checkDate {
                break
            }
        }
        
        return streak
    }
    
    private func calculateLongestStreak() -> Int {
        let entries = calendarManager.calendarEntries.sorted { $0.date < $1.date }
        guard !entries.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var longestStreak = 1
        var currentStreak = 1
        
        for i in 1..<entries.count {
            let previousDate = entries[i-1].date
            let currentDate = entries[i].date
            
            if let dayAfter = calendar.date(byAdding: .day, value: 1, to: previousDate),
               calendar.isDate(dayAfter, inSameDayAs: currentDate) {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return longestStreak
    }
    
    private func resetAllData() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "userName")
        defaults.removeObject(forKey: "notificationTime")
        defaults.removeObject(forKey: "calendarEntries")
        
        calendarManager.resetAllEntries()
        
        appState.userName = ""
    }
}

struct StatBox: View {
    let value: String
    let label: String
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(appState.theme.textPrimary)
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(appState.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(appState.theme.cardBackground)
        .cornerRadius(16)
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    @EnvironmentObject var appState: AppState

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(appState.theme.textSecondary)
                .textCase(.uppercase)

            VStack(spacing: 12) {
                content
            }
            .padding(20)
            .background(appState.theme.cardBackground)
            .cornerRadius(24)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(appState.theme.textPrimary)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
        .environmentObject(CalendarManager())
}
