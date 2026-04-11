import Foundation

struct VideoEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let videoURL: URL
    let duration: TimeInterval
    let thumbnailURL: URL?
    
    init(date: Date, videoURL: URL, duration: TimeInterval, thumbnailURL: URL? = nil) {
        self.id = UUID()
        self.date = date
        self.videoURL = videoURL
        self.duration = duration
        self.thumbnailURL = thumbnailURL
    }
    
    var daysSinceRecording: Int {
        Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
    }
    
    var isFromToday: Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    var isFromYesterday: Bool {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return Calendar.current.isDate(date, inSameDayAs: yesterday)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
