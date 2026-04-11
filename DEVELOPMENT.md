# BECOMING - Development Guide

## 🚀 Quick Start

### Opening the Project
1. Open `Becoming.xcodeproj` in Xcode
2. Select your development team in project settings
3. Choose an iOS device or simulator as the target
4. Build and run (⌘+R)

### Important Notes
- **This is an iOS-only project** - requires Xcode with iOS SDK
- **Camera access required** - must run on physical device for full functionality
- **Notifications require device** - push notifications don't work in simulator

## 📁 Project Structure

```
Becoming/
├── Becoming.xcodeproj/          # Xcode project file
├── Becoming/
│   ├── BecomingApp.swift        # App entry point (@main)
│   ├── ContentView.swift        # Root navigation controller
│   ├── Info.plist              # App configuration & permissions
│   ├── Assets.xcassets/         # App icons & colors
│   ├── Models/
│   │   ├── AppState.swift       # Global app state (@ObservableObject)
│   │   └── VideoEntry.swift     # Video data model (Codable)
│   ├── Managers/
│   │   ├── NotificationManager.swift  # Push notifications & scheduling
│   │   ├── VideoManager.swift         # Video recording & file management
│   │   └── StreakManager.swift        # Streak logic & persistence
│   └── Views/
│       ├── OnboardingView.swift       # 4-step setup flow
│       ├── HomeView.swift             # Main dashboard with record button
│       ├── RecordingView.swift        # Camera interface & recording
│       ├── TimelineView.swift         # Video history browser
│       └── SettingsView.swift         # App configuration
├── README.md                    # Project overview
├── DEVELOPMENT.md              # This file
└── .gitignore                  # Git ignore rules
```

## 🏗️ Architecture Overview

### State Management
- **SwiftUI + Combine**: Reactive UI updates
- **@ObservableObject**: Shared state across views
- **@EnvironmentObject**: Dependency injection
- **UserDefaults**: Simple persistence layer

### Key Managers

#### AppState
- Global app configuration
- Onboarding status
- User preferences (notification time, one-take mode)
- Persistence via UserDefaults

#### NotificationManager
- Daily reminder scheduling
- Motivational message rotation
- Permission handling
- Follow-up reminders

#### VideoManager
- AVFoundation camera integration
- File system management (Documents directory)
- Video compression & storage
- Timeline data management

#### StreakManager
- Daily streak calculation
- Consistency tier system
- Motivational messaging
- Streak reset logic

### Data Flow
```
User Action → View → Manager → State Update → UI Refresh
```

## 🎥 Video Recording Flow

### Recording Process
1. User taps record button → `RecordingView` presented
2. `CameraManager` sets up AVCaptureSession
3. Front-facing camera + microphone configured
4. Recording starts with 10-minute timer
5. Video saved to Documents directory
6. `VideoEntry` created and stored
7. Streak updated via `StreakManager`

### One Take Mode
- Prevents multiple recording attempts
- Forces authenticity by limiting retakes
- Configurable in settings
- Alert shown after first recording

## 📱 User Experience Design

### Core Principles
- **Minimal friction**: Direct camera access from notification
- **Dark mode first**: Reduces eye strain during daily use
- **Identity-based messaging**: "You've shown up X days"
- **Authentic over perfect**: One-take mode encourages realness

### Navigation Structure
```
TabView
├── Home (Record + Streak Display)
├── Timeline (Video History)
└── Settings (Configuration)
```

### Onboarding Flow
1. **Welcome**: Feature overview
2. **Notifications**: Time selection
3. **One Take Mode**: Authenticity explanation
4. **Ready**: Motivational completion

## 🔔 Notification System

### Daily Reminders
- Scheduled via `UNUserNotificationCenter`
- Repeating daily at user-selected time
- Motivational messages rotate randomly
- Includes current streak in message

### Message Examples
- "Day 12. Don't break it."
- "You haven't spoken today."
- "Future you is waiting."
- "Keep the streak alive."

### Follow-up Logic
- 1 hour after missed notification
- Only if user hasn't recorded yet
- Different message tone (more urgent)

## 📊 Streak System

### Calculation Logic
```swift
// Consecutive days = streak continues
if daysBetween == 1 { streak += 1 }

// Gap > 1 day = streak resets
if daysBetween > 1 { streak = 1 }

// Same day = no change
if daysBetween == 0 { /* no change */ }
```

### Consistency Tiers
- **Getting Started** (0+ days)
- **Building Momentum** (7+ days) 
- **Consistent Creator** (30+ days)
- **Dedicated Documenter** (100+ days)
- **Life Chronicler** (365+ days)

## 🗂️ Data Storage

### Local Storage Strategy
- **Videos**: Documents directory (`.mov` files)
- **Metadata**: UserDefaults (JSON encoded)
- **No cloud sync**: Privacy-first approach
- **File naming**: `video_{timestamp}.mov`

### Data Models
```swift
struct VideoEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let videoURL: URL
    let duration: TimeInterval
    let thumbnailURL: URL?
}
```

## 🔒 Privacy & Permissions

### Required Permissions
- **Camera**: Video recording
- **Microphone**: Audio recording
- **Notifications**: Daily reminders

### Privacy Approach
- All data stored locally on device
- No external servers or analytics
- User owns all content
- No automatic cloud backup

## 🐛 Common Issues & Solutions

### Build Errors
- **"Cannot find module"**: Ensure iOS SDK selected in Xcode
- **"UIKit unavailable"**: Project must target iOS, not macOS
- **Camera not working**: Must run on physical device

### Runtime Issues
- **Notifications not appearing**: Check device notification settings
- **Camera permission denied**: Reset in iOS Settings > Privacy
- **Videos not saving**: Check device storage space

### Development Tips
- Use iOS Simulator for UI development
- Use physical device for camera testing
- Test notification scheduling in background
- Verify streak logic across date boundaries

## 🔮 Future Development

### Phase 2 Features
- [ ] AI transcription (Speech framework)
- [ ] Mood analysis (Natural Language framework)
- [ ] "On this day" memories
- [ ] Video thumbnails (AVAssetImageGenerator)
- [ ] iCloud sync (CloudKit)

### Phase 3 Features
- [ ] Close friends sharing
- [ ] Apple Watch integration
- [ ] Export to Photos app
- [ ] Advanced analytics dashboard

## 🧪 Testing Strategy

### Manual Testing Checklist
- [ ] Complete onboarding flow
- [ ] Record video in both modes (normal + one-take)
- [ ] Verify streak calculation across days
- [ ] Test notification scheduling
- [ ] Check timeline video playback
- [ ] Validate settings persistence

### Edge Cases
- [ ] Date boundary crossing (11:59 PM recording)
- [ ] Storage full scenarios
- [ ] Permission denied handling
- [ ] Background app refresh
- [ ] Device restart persistence

## 📝 Code Style

### SwiftUI Conventions
- Use `@State` for local view state
- Use `@EnvironmentObject` for shared managers
- Prefer `@ViewBuilder` for conditional views
- Extract complex views into separate structs

### Naming Conventions
- Managers: `*Manager` (e.g., `VideoManager`)
- Views: `*View` (e.g., `RecordingView`)
- Models: Descriptive nouns (e.g., `VideoEntry`)
- Functions: Verb phrases (e.g., `recordVideo()`)

---

**Remember**: This app is about consistency, not perfection. Keep the code simple and the user experience frictionless.
