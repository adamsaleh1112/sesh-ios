import SwiftUI

@main
struct BecomingApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var calendarManager = CalendarManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(calendarManager)
                .preferredColorScheme(appState.isDarkMode ? .dark : .light)
        }
    }
}
