import SwiftUI

struct HomeView: View {
    @EnvironmentObject var streakManager: StreakManager
    @EnvironmentObject var videoManager: VideoManager
    @State private var showingRecordingView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 10) {
                        Text("BECOMING")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(streakManager.streakMessage)
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    
                    // Streak Display
                    StreakCard()
                    
                    Spacer()
                    
                    // Record Button
                    RecordButton()
                    
                    // Today's Status
                    TodayStatusCard()
                    
                    Spacer()
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingRecordingView) {
            RecordingView()
        }
    }
    
    @ViewBuilder
    private func StreakCard() -> some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Current Streak")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("\(streakManager.currentStreak)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Best Streak")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("\(streakManager.longestStreak)")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.orange)
                }
            }
            
            Text(streakManager.consistencyTier)
                .font(.subheadline)
                .foregroundColor(.orange)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(8)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private func RecordButton() -> some View {
        Button(action: {
            showingRecordingView = true
        }) {
            VStack(spacing: 8) {
                Image(systemName: "video.fill")
                    .font(.system(size: 32))
                
                Text(videoManager.hasRecordedToday() ? "Record Again" : "Record Today")
                    .font(.headline)
            }
            .foregroundColor(.black)
            .frame(width: 120, height: 120)
            .background(Color.white)
            .clipShape(Circle())
        }
        .scaleEffect(videoManager.hasRecordedToday() ? 0.9 : 1.0)
        .opacity(videoManager.hasRecordedToday() ? 0.7 : 1.0)
    }
    
    @ViewBuilder
    private func TodayStatusCard() -> some View {
        HStack {
            Image(systemName: videoManager.hasRecordedToday() ? "checkmark.circle.fill" : "clock.fill")
                .foregroundColor(videoManager.hasRecordedToday() ? .green : .orange)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text(videoManager.hasRecordedToday() ? "Recorded Today" : "Not Recorded Yet")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(streakManager.motivationalMessage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    HomeView()
        .environmentObject(StreakManager())
        .environmentObject(VideoManager())
}
