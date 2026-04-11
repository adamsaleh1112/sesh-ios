import Foundation
import AVFoundation
import Photos

class VideoManager: ObservableObject {
    @Published var videoEntries: [VideoEntry] = []
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    
    private let maxRecordingDuration: TimeInterval = 600 // 10 minutes
    private var recordingTimer: Timer?
    
    init() {
        loadVideoEntries()
    }
    
    func startRecording() {
        isRecording = true
        recordingDuration = 0
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.recordingDuration += 1.0
            if self.recordingDuration >= self.maxRecordingDuration {
                self.stopRecording()
            }
        }
    }
    
    func stopRecording() {
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    func saveVideo(url: URL) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "video_\(Date().timeIntervalSince1970).mov"
        let destinationURL = documentsPath.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.copyItem(at: url, to: destinationURL)
            
            let videoEntry = VideoEntry(
                date: Date(),
                videoURL: destinationURL,
                duration: recordingDuration
            )
            
            videoEntries.insert(videoEntry, at: 0)
            saveVideoEntries()
            
        } catch {
            print("Error saving video: \(error)")
        }
    }
    
    func getVideoForDate(_ date: Date) -> VideoEntry? {
        return videoEntries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func hasRecordedToday() -> Bool {
        return getVideoForDate(Date()) != nil
    }
    
    func getVideosFromLastYear() -> [VideoEntry] {
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        return videoEntries.filter { $0.date >= oneYearAgo }
    }
    
    func getVideoFromSameDateLastYear() -> VideoEntry? {
        let lastYear = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        return videoEntries.first { Calendar.current.isDate($0.date, inSameDayAs: lastYear) }
    }
    
    private func loadVideoEntries() {
        if let data = UserDefaults.standard.data(forKey: "videoEntries"),
           let entries = try? JSONDecoder().decode([VideoEntry].self, from: data) {
            videoEntries = entries.sorted { $0.date > $1.date }
        }
    }
    
    private func saveVideoEntries() {
        if let data = try? JSONEncoder().encode(videoEntries) {
            UserDefaults.standard.set(data, forKey: "videoEntries")
        }
    }
    
    func deleteVideo(_ entry: VideoEntry) {
        if let index = videoEntries.firstIndex(where: { $0.id == entry.id }) {
            videoEntries.remove(at: index)
            
            // Delete the actual file
            try? FileManager.default.removeItem(at: entry.videoURL)
            
            saveVideoEntries()
        }
    }
}
