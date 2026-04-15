import Foundation

struct CalendarEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    
    init(id: UUID? = nil, date: Date) {
        self.id = id ?? UUID()
        self.date = date
    }
}
