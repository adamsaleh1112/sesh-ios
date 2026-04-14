import Foundation

class CalendarManager: ObservableObject {
    @Published var calendarEntries: [CalendarEntry] = []
    
    init() {
        loadCalendarEntries()
    }
    
    func addEntry(for date: Date) {
        let entry = CalendarEntry(date: date)
        calendarEntries.append(entry)
        saveCalendarEntries()
    }
    
    func getEntryForDate(_ date: Date) -> CalendarEntry? {
        return calendarEntries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func hasEntryForDate(_ date: Date) -> Bool {
        return getEntryForDate(date) != nil
    }
    
    func hasEntryToday() -> Bool {
        return hasEntryForDate(Date())
    }
    
    private func loadCalendarEntries() {
        if let data = UserDefaults.standard.data(forKey: "calendarEntries"),
           let entries = try? JSONDecoder().decode([CalendarEntry].self, from: data) {
            calendarEntries = entries
        }
    }
    
    private func saveCalendarEntries() {
        if let data = try? JSONEncoder().encode(calendarEntries) {
            UserDefaults.standard.set(data, forKey: "calendarEntries")
        }
    }
    
    func resetAllEntries() {
        calendarEntries.removeAll()
        saveCalendarEntries()
    }
}
