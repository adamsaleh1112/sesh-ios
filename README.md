# BECOMING - Daily Video Log iOS App

A mobile app that enforces a daily habit of recording short, authentic video logs. Built around consistency, emotional reflection, and long-term personal growth.

## 🎯 Core Features

### MVP Features (Implemented)
- ✅ User onboarding with notification time setup
- ✅ Push notification system with motivational messages
- ✅ Camera + video recording (10 min max)
- ✅ Daily video saving (date-based)
- ✅ Streak tracking with identity-based feedback
- ✅ Timeline view of past videos
- ✅ One Take Mode for authenticity
- ✅ Dark mode UI design

### Key Differentiators
- **One Take Mode**: Forces authenticity by limiting retakes
- **Identity-Based Streaks**: "You've shown up X days in a row"
- **Motivational Notifications**: Personal, slightly pressuring messages
- **10-minute limit**: Prevents perfectionism
- **Front-facing camera default**: Focus on personal reflection

## 🏗️ Architecture

### Project Structure
```
Becoming/
├── BecomingApp.swift          # Main app entry point
├── ContentView.swift          # Root view controller
├── Models/
│   ├── AppState.swift         # App-wide state management
│   └── VideoEntry.swift       # Video data model
├── Managers/
│   ├── NotificationManager.swift  # Push notifications
│   ├── VideoManager.swift         # Video recording & storage
│   └── StreakManager.swift        # Streak tracking logic
└── Views/
    ├── OnboardingView.swift       # Initial setup flow
    ├── HomeView.swift             # Main dashboard
    ├── RecordingView.swift        # Camera interface
    ├── TimelineView.swift         # Video history
    └── SettingsView.swift         # App configuration
```

### Key Technologies
- **SwiftUI**: Modern declarative UI framework
- **AVFoundation**: Camera and video recording
- **UserNotifications**: Daily reminder system
- **UserDefaults**: Local data persistence
- **Combine**: Reactive programming for state management

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- iPhone (camera required)

### Installation
1. Clone the repository
2. Open `Becoming.xcodeproj` in Xcode
3. Select your development team in project settings
4. Build and run on device (camera access required)

### First Run
1. Complete onboarding flow
2. Set daily notification time
3. Grant camera and microphone permissions
4. Record your first video log!

## 📱 User Experience

### Core Loop
1. Daily notification at user-set time
2. Tap notification → opens directly to camera
3. Record video (max 10 minutes)
4. Video saved automatically
5. Streak updates
6. Repeat daily

### Notification Examples
- "Day 12. Don't break it."
- "You haven't spoken today."
- "Future you is waiting."
- "Keep the streak alive."

### Consistency Tiers
- **Getting Started** (0+ days)
- **Building Momentum** (7+ days)
- **Consistent Creator** (30+ days)
- **Dedicated Documenter** (100+ days)
- **Life Chronicler** (365+ days)

## 🔮 Future Features

### Phase 2
- [ ] AI transcription + mood analysis
- [ ] "On this day" playback (1 year ago)
- [ ] Side-by-side comparisons
- [ ] Video thumbnails
- [ ] Cloud storage integration

### Phase 3
- [ ] Close friends sharing (3-5 people)
- [ ] Mood tracking dashboard
- [ ] Export features
- [ ] Apple Watch integration

## 🎨 Design Philosophy

### What This App IS:
- A daily ritual
- A consistency system
- A tool for self-reflection and growth
- Raw and authentic

### What This App is NOT:
- A traditional journal
- A social media platform
- A highlight reel
- Over-edited content

## 📊 Technical Decisions

### Why SwiftUI?
- Modern, declarative syntax
- Built-in dark mode support
- Excellent camera integration
- Future-proof for iOS updates

### Why Local Storage?
- Privacy-first approach
- No server costs
- Instant access
- User owns their data

### Why One Take Mode?
- Reduces perfectionism
- Encourages authenticity
- Makes recording faster
- Builds confidence over time

## 🔒 Privacy

- All videos stored locally on device
- No data sent to external servers
- User controls all content
- Optional cloud backup (future feature)

## 📝 License

This project is private and proprietary.

## 🤝 Contributing

This is a personal project. Not accepting external contributions at this time.

---

**Remember**: Don't let your life go unrecorded. Talk to your future self.
