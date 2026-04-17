import SwiftUI
import Combine

// MARK: - Auth Models

enum AuthStatus {
    case unknown
    case authenticated(userId: String)
    case unauthenticated
}

enum OnboardingStep {
    case auth
    case routineBuilder
    case restDays
    case complete
}

struct WorkoutDayType: Identifiable, Codable, Equatable {
    var id: UUID
    let name: String
    let colorHex: String
    let icon: String
    
    init(id: UUID = UUID(), name: String, colorHex: String, icon: String) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.icon = icon
    }
    
    static let allTypes: [WorkoutDayType] = [
        WorkoutDayType(name: "Push", colorHex: "#FF6B6B", icon: "arrow.up"),
        WorkoutDayType(name: "Pull", colorHex: "#4ECDC4", icon: "arrow.down"),
        WorkoutDayType(name: "Legs", colorHex: "#95E1D3", icon: "figure.walk"),
        WorkoutDayType(name: "Chest", colorHex: "#FFB6B9", icon: "heart.fill"),
        WorkoutDayType(name: "Back", colorHex: "#6C5CE7", icon: "figure.archery"),
        WorkoutDayType(name: "Arms", colorHex: "#A8E6CF", icon: "figure.arms.open"),
        WorkoutDayType(name: "Shoulders", colorHex: "#FFD93D", icon: "figure.stand"),
        WorkoutDayType(name: "Full Body", colorHex: "#FD79A8", icon: "figure.strengthtraining.traditional"),
        WorkoutDayType(name: "Cardio", colorHex: "#74B9FF", icon: "figure.run"),
        WorkoutDayType(name: "Rest", colorHex: "#636E72", icon: "bed.double.fill")
    ]
    
    var swiftUIColor: Color {
        Color(hex: colorHex) ?? .gray
    }
}

struct UserRoutine: Codable {
    var days: [WorkoutDayType] = []
    
    func workoutForDate(_ date: Date, startingFrom startDate: Date = Date()) -> WorkoutDayType? {
        guard !days.isEmpty else { return nil }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: date)
        let dayDifference = components.day ?? 0
        
        let index = dayDifference % days.count
        let safeIndex = index < 0 ? index + days.count : index
        
        return days[safeIndex % days.count]
    }
}

class AuthState: ObservableObject {
    @Published var authStatus: AuthStatus = .unknown
    @Published var currentStep: OnboardingStep = .auth
    @Published var routine: UserRoutine = UserRoutine()
    @Published var restDays: [Int] = [] // 0 = Sunday, 6 = Saturday
    @Published var currentUser: UserProfile?
    
    var isAuthenticated: Bool {
        if case .authenticated = authStatus {
            return true
        }
        return false
    }
    
    var isOnboardingComplete: Bool {
        currentStep == .complete
    }
    
    func completeOnboarding() {
        currentStep = .complete
    }
    
    func nextStep() {
        switch currentStep {
        case .auth:
            currentStep = .routineBuilder
        case .routineBuilder:
            currentStep = .restDays
        case .restDays:
            currentStep = .complete
        case .complete:
            break
        }
    }
    
    func previousStep() {
        switch currentStep {
        case .auth:
            break
        case .routineBuilder:
            currentStep = .auth
        case .restDays:
            currentStep = .routineBuilder
        case .complete:
            currentStep = .restDays
        }
    }
}

struct UserProfile: Codable {
    let id: String
    let username: String?
    let createdAt: Date
    let onboardingCompleted: Bool
    let routine: UserRoutine
    let restDays: [Int]
}

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
