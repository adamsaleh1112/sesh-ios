import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var selectedTime = Date()
    @State private var currentStep = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                switch currentStep {
                case 0:
                    WelcomeStep()
                case 1:
                    NotificationStep()
                case 2:
                    OneTakeModeStep()
                default:
                    CompletionStep()
                }
                
                Spacer()
                
                Button(action: nextStep) {
                    Text(currentStep == 3 ? "Start Your Journey" : "Continue")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func WelcomeStep() -> some View {
        VStack(spacing: 30) {
            Text("BECOMING")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Talk to your future self.")
                .font(.title2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 20) {
                FeatureRow(icon: "video.fill", text: "Record daily video logs")
                FeatureRow(icon: "flame.fill", text: "Build consistency streaks")
                FeatureRow(icon: "clock.fill", text: "Max 10 minutes per day")
                FeatureRow(icon: "heart.fill", text: "Watch yourself grow")
            }
        }
    }
    
    @ViewBuilder
    private func NotificationStep() -> some View {
        VStack(spacing: 30) {
            Text("Daily Reminder")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("When should we remind you to record?")
                .font(.title3)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            DatePicker("Notification Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .colorScheme(.dark)
        }
    }
    
    @ViewBuilder
    private func OneTakeModeStep() -> some View {
        VStack(spacing: 30) {
            Text("One Take Mode")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Force authenticity by limiting retakes")
                .font(.title3)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 20) {
                Toggle("Enable One Take Mode", isOn: $appState.oneTakeMode)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("When enabled, you only get one attempt to record. This reduces perfectionism and keeps your logs authentic.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    @ViewBuilder
    private func CompletionStep() -> some View {
        VStack(spacing: 30) {
            Text("You're Ready!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Don't let your life go unrecorded.")
                .font(.title3)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 15) {
                Text("Remember:")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("• Show up every day")
                Text("• Speak honestly")
                Text("• Watch yourself grow")
            }
            .font(.body)
            .foregroundColor(.gray)
        }
    }
    
    private func nextStep() {
        if currentStep < 3 {
            withAnimation {
                currentStep += 1
            }
        } else {
            // Complete onboarding
            appState.notificationTime = selectedTime
            notificationManager.scheduleDailyNotification(at: selectedTime, streak: 0)
            appState.completeOnboarding()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 24)
            
            Text(text)
                .foregroundColor(.gray)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
        .environmentObject(NotificationManager())
}
