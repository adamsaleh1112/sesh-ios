import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var calendarManager: CalendarManager
    
    var body: some View {
        NavigationView {
            ZStack {
                appState.theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
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
                        
                        // Appearance Settings
                        SettingsSection(title: "Appearance") {
                            VStack(spacing: 14) {
                                // Theme selector
                                HStack(spacing: 12) {
                                    Text("Theme")
                                        .font(.system(size: 16))
                                        .foregroundColor(appState.theme.textPrimary)
                                    
                                    Spacer()
                                    
                                    // Capsule icon toggle
                                    HStack(spacing: 0) {
                                        // Light button (sun icon)
                                        Button(action: {
                                            appState.isDarkMode = false
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(!appState.isDarkMode ? appState.accentColor.swiftUIColor : Color.clear)
                                                    .frame(width: 36, height: 36)
                                                Image(systemName: "sun.max.fill")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(!appState.isDarkMode ? .white : appState.theme.textSecondary)
                                            }
                                            .frame(width: 40, height: 40)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        // Dark button (moon icon)
                                        Button(action: {
                                            appState.isDarkMode = true
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(appState.isDarkMode ? appState.accentColor.swiftUIColor : Color.clear)
                                                    .frame(width: 36, height: 36)
                                                Image(systemName: "moon.fill")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(appState.isDarkMode ? .white : appState.theme.textSecondary)
                                            }
                                            .frame(width: 40, height: 40)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    .padding(2)
                                    .background(appState.theme.cardBackground)
                                    .clipShape(Capsule())
                                }
                                
                                HStack {
                                    Image(systemName: "paintpalette")
                                        .font(.system(size: 18))
                                        .foregroundColor(.gray)
                                        .frame(width: 28)
                                    Text("Accent color")
                                        .font(.system(size: 16))
                                        .foregroundColor(appState.theme.textPrimary)
                                    Spacer()
                                    Picker("Accent Color", selection: $appState.accentColor) {
                                        ForEach(AccentColorOption.allCases, id: \.self) { color in
                                            HStack {
                                                Circle()
                                                    .fill(color.swiftUIColor)
                                                    .frame(width: 12, height: 12)
                                                Text(color.rawValue)
                                            }
                                            .tag(color)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(appState.accentColor.swiftUIColor)
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
                    .padding(.vertical)
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func resetAllData() {
        // Reset all user defaults
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "isDarkMode")
        defaults.removeObject(forKey: "accentColor")
        defaults.removeObject(forKey: "userName")
        defaults.removeObject(forKey: "notificationTime")
        defaults.removeObject(forKey: "calendarEntries")
        
        // Reset calendar entries
        calendarManager.resetAllEntries()
        
        // Reset app state
        appState.isDarkMode = true
        appState.accentColor = .blue
        appState.userName = ""
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
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(appState.theme.textPrimary)

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
    SettingsView()
        .environmentObject(AppState())
        .environmentObject(CalendarManager())
}
