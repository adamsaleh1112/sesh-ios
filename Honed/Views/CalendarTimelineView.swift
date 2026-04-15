import SwiftUI

struct CalendarTimelineView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @EnvironmentObject var appState: AppState
    @Binding var selectedDate: Date
    @State private var currentMonthIndex = 0
    
    private let calendar = Calendar.current
    private let visibleMonthRange = -6...6 // Show 6 months back and forward
    
    // Cache day headers for performance
    private let dayHeaders = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Day headers (fixed, not swiping)
            HStack {
                ForEach(dayHeaders, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.gray.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .frame(height: 14)
                }
            }
            .padding(.horizontal, 20)

            // Horizontal paging months
            TabView(selection: $currentMonthIndex) {
                ForEach(Array(visibleMonthRange), id: \.self) { offset in
                    MonthGridView(
                        monthOffset: offset,
                        selectedDate: $selectedDate,
                        calendarManager: calendarManager
                    )
                    .environmentObject(appState)
                    .tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 420)
        }
        .onAppear {
            currentMonthIndex = 0
        }
        .onChange(of: currentMonthIndex) { newIndex in
            // Soft haptic when swiping between months
            HapticManager.shared.soft()
            
            // Update selected date to the first day of the new month
            if let newDate = calendar.date(byAdding: .month, value: newIndex, to: Date()) {
                // Keep the day if possible, otherwise clamp to month end
                let day = calendar.component(.day, from: selectedDate)
                var components = calendar.dateComponents([.year, .month], from: newDate)
                components.day = min(day, calendar.range(of: .day, in: .month, for: newDate)?.count ?? day)
                if let finalDate = calendar.date(from: components) {
                    selectedDate = finalDate
                }
            }
        }
        .padding(.top, 16)
    }
}

struct MonthGridView: View {
    let monthOffset: Int
    @Binding var selectedDate: Date
    let calendarManager: CalendarManager
    
    @EnvironmentObject var appState: AppState
    private let calendar = Calendar.current
    
    private var monthDate: Date {
        calendar.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()
    }
    
    private var calendarDays: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: monthDate) else {
            return []
        }
        
        let monthFirstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let daysToSubtract = monthFirstWeekday - 1
        
        guard let startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: monthInterval.start) else {
            return []
        }
        
        var days: [Date] = []
        var currentDate = startDate
        
        // Generate 42 days (6 weeks) to fill the calendar grid
        for _ in 0..<42 {
            days.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        return days
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 14) {
            ForEach(calendarDays, id: \.self) { date in
                let hasEntry = calendarManager.hasEntryForDate(date)
                CalendarDayView(
                    date: date,
                    hasEntry: hasEntry,
                    isCurrentMonth: calendar.isDate(date, equalTo: monthDate, toGranularity: .month),
                    isToday: calendar.isDateInToday(date),
                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate)
                ) {
                    // Light haptic when tapping on a day
                    HapticManager.shared.light()
                    selectedDate = date
                }
                .environmentObject(appState)
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CalendarDayView: View {
    let date: Date
    let hasEntry: Bool
    let isCurrentMonth: Bool
    let isToday: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    @EnvironmentObject var appState: AppState
    @State private var isPressed = false
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .frame(height: 52)
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0), value: isPressed)
                
                // Day number
                Text(dayFormatter.string(from: date))
                    .font(.system(size: 22, weight: hasEntry ? .bold : .medium, ))
                    .foregroundColor(textColor)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0), value: isPressed)
                
                // Today indicator - accent color dot centered at bottom
                if isToday {
                    VStack {
                        Spacer()
                        Circle()
                            .fill(appState.accentColor.swiftUIColor)
                            .frame(width: 6, height: 6)
                            .padding(.bottom, 6)
                    }
                }
                
                // Entry indicator dot (bottom right)
                if hasEntry {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Circle()
                                .fill(appState.accentColor.swiftUIColor)
                                .frame(width: 8, height: 8)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                .offset(x: -4, y: -4)
                                .scaleEffect(isPressed ? 0.8 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0), value: isPressed)
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)) {
                isPressed = pressing
            }
        }, perform: {})
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return appState.accentColor.swiftUIColor.opacity(0.3)
        } else if isToday {
            return appState.theme.isDarkMode ? Color.white.opacity(0.2) : Color.black.opacity(0.1)
        } else if hasEntry {
            return appState.theme.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05)
        } else {
            return Color.clear
        }
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return Color.gray.opacity(0.5)
        } else if isSelected {
            return appState.theme.textPrimary
        } else if isToday {
            return appState.theme.textPrimary
        } else if hasEntry {
            return appState.theme.textPrimary
        } else {
            return appState.theme.textSecondary
        }
    }
}

#Preview {
    CalendarTimelineView(selectedDate: .constant(Date()))
        .environmentObject(CalendarManager())
        .environmentObject(AppState())
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
}
