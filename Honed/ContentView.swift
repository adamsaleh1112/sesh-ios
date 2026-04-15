import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var calendarManager: CalendarManager
    
    var body: some View {
        ZStack {
            appState.theme.background.ignoresSafeArea()
            
            if appState.isOnboarded {
                MainView()
                    .transition(.blurReplace)
            } else {
                OnboardingView()
                    .transition(.blurReplace)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.6), value: appState.isOnboarded)
    }
}

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var selectedDate = Date()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab - Calendar
            HomeContentView(selectedDate: $selectedDate)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Home")
                }
                .tag(0)
            
            // Records Tab
            RecordsView()
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Records")
                }
                .tag(1)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(2)
        }
        .tint(appState.theme.textPrimary)
    }
}

struct HomeContentView: View {
    @Binding var selectedDate: Date
    @EnvironmentObject var calendarManager: CalendarManager
    @EnvironmentObject var appState: AppState
    
    // Staggered animation states
    @State private var headerOpacity = 0.0
    @State private var headerOffset: CGFloat = -15
    @State private var lineOpacity = 0.0
    @State private var lineOffset: CGFloat = -15
    @State private var calendarOpacity = 0.0
    @State private var calendarOffset: CGFloat = -15
    
    var body: some View {
        ZStack {
            appState.theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Date Header
                DateHeaderView(selectedDate: $selectedDate)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .opacity(headerOpacity)
                    .offset(y: headerOffset)
                
                // Dotted line separator
                HStack(spacing: 5.5) {
                    ForEach(0..<42) { _ in
                        Circle()
                            .fill(appState.theme.dotColor)
                            .frame(width: 3, height: 3)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                .opacity(lineOpacity)
                .offset(y: lineOffset)
                
                // Calendar Timeline
                CalendarTimelineView(selectedDate: $selectedDate)
                    .padding(.top, 16)
                    .opacity(calendarOpacity)
                    .offset(y: calendarOffset)
                
                Spacer()
            }
            .onAppear {
                // Reset states first for re-animation
                headerOpacity = 0
                headerOffset = -15
                lineOpacity = 0
                lineOffset = -15
                calendarOpacity = 0
                calendarOffset = -15
                
                // Staggered reveal from top to bottom
                withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
                    headerOpacity = 1
                    headerOffset = 0
                }
                withAnimation(.easeOut(duration: 0.4).delay(0.25)) {
                    lineOpacity = 1
                    lineOffset = 0
                }
                withAnimation(.easeOut(duration: 0.4).delay(0.4)) {
                    calendarOpacity = 1
                    calendarOffset = 0
                }
            }
        }
    }
}

struct DateHeaderView: View {
    @Binding var selectedDate: Date
    @EnvironmentObject var appState: AppState
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    private var accentColor: Color {
        return appState.accentColor.swiftUIColor
    }
    
    private var monthNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        return formatter.string(from: selectedDate)
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: selectedDate)
    }
    
    private var yearNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy"
        return formatter.string(from: selectedDate)
    }
    
    private var dayAbbreviation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            // Month (grayed out)
            Text(monthNumber)
                .font(.system(size: 48, weight: .regular))
                .fontWidth(.expanded)
                .foregroundColor(appState.theme.textMuted)
                .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity).combined(with: .scale(scale: 0.5)), removal: .move(edge: .leading).combined(with: .opacity).combined(with: .scale(scale: 0.5))))
                .id("month-\(monthNumber)")
            
            // Day (primary text)
            Text(dayNumber)
                .font(.system(size: 48, weight: .regular))
                .fontWidth(.expanded)
                .foregroundColor(appState.theme.textPrimary)
                .transition(.asymmetric(insertion: .scale(scale: 1.2).combined(with: .opacity), removal: .scale(scale: 0.8).combined(with: .opacity)))
                .id("day-\(dayNumber)")
            
            // Year (grayed out)
            Text(yearNumber)
                .font(.system(size: 48, weight: .regular))
                .fontWidth(.expanded)
                .foregroundColor(appState.theme.textMuted)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale(scale: 0.5)), removal: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale(scale: 0.5))))
                .id("year-\(yearNumber)")
            
            // Accent color bullet for today
            if isToday {
                Text("•")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(accentColor)
                    .padding(.leading, 4)
                    .transition(.asymmetric(insertion: .scale(scale: 1.2).combined(with: .opacity), removal: .scale(scale: 0.8).combined(with: .opacity)))
            }
            
            Spacer()
            
            // Day of week abbreviation (top right)
            Text(dayAbbreviation.uppercased())
                .font(.system(size: 48, weight: .regular))
                .fontWidth(.compressed)
                .foregroundColor(appState.theme.textMuted)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale(scale: 0.5)), removal: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale(scale: 0.5))))
                .id("dayAbbr-\(dayAbbreviation)")
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 4)
        .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0), value: selectedDate)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(CalendarManager())
        .preferredColorScheme(.dark)
}
