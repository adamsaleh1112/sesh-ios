import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var videoManager: VideoManager
    @EnvironmentObject var streakManager: StreakManager
    
    var body: some View {
        Group {
            if !appState.isOnboarded {
                OnboardingView()
            } else {
                MainView()
            }
        }
    }
}

struct MainView: View {
    @EnvironmentObject var videoManager: VideoManager
    @EnvironmentObject var streakManager: StreakManager
    @State private var showingRecordingView = false
    @State private var showingSettingsView = false
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.1).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Date Header
                DateHeaderView()
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                // Calendar Timeline - expanded to take more vertical space
                CalendarTimelineView()
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                
                Spacer()
            }
            
            // Floating Record Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingRecordButton {
                        showingRecordingView = true
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 50)
                }
            }
        }
        .sheet(isPresented: $showingRecordingView) {
            RecordingView()
        }
        .sheet(isPresented: $showingSettingsView) {
            SettingsView()
        }
    }
}

struct DateHeaderView: View {
    private let today = Date()
    @State private var isVisible = false
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: today)
    }
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: today)
    }
    
    private var monthAndDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd"
        return formatter.string(from: today)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // Large day number on the left
            Text(dayNumber)
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .scaleEffect(isVisible ? 1.0 : 0.8)
                .opacity(isVisible ? 1.0 : 0.0)
                .animation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0), value: isVisible)
            
            Spacer()
            
            // Day name and date on the right
            VStack(alignment: .trailing, spacing: 6) {
                Text(dayName)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .offset(x: isVisible ? 0 : 30)
                    .opacity(isVisible ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0).delay(0.1), value: isVisible)
                
                Text(monthAndDay)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .offset(x: isVisible ? 0 : 30)
                    .opacity(isVisible ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0).delay(0.2), value: isVisible)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 4)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}

struct FloatingRecordButton: View {
    let action: () -> Void
    @State private var isPressed = false
    @State private var isVisible = false
    
    var body: some View {
        Button(action: {
            // Trigger action with subtle animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)) {
                action()
            }
        }) {
            ZStack {
                // Outer glow effect
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .scaleEffect(isPressed ? 1.2 : 1.0)
                    .opacity(isPressed ? 0.0 : 1.0)
                    .animation(.easeOut(duration: 0.6), value: isPressed)
                
                // Main button
                Circle()
                    .fill(Color.white)
                    .frame(width: 64, height: 64)
                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .scaleEffect(isVisible ? 1.0 : 0.8)
                    .opacity(isVisible ? 1.0 : 0.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0), value: isPressed)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0).delay(0.3), value: isVisible)
                
                // Icon
                Image(systemName: "video.fill")
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .foregroundColor(.black)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0), value: isPressed)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)) {
                isPressed = pressing
            }
        }, perform: {})
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(NotificationManager())
        .environmentObject(VideoManager())
        .environmentObject(StreakManager())
}
