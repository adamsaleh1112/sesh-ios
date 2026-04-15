import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentStep = 0
    @State private var userName = ""

    var body: some View {
        ZStack {
            appState.theme.background.ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 0) {
                Spacer()
                
                // Animated content area
                VStack(spacing: 40) {
                    Group {
                        switch currentStep {
                        case 0:
                            NameStep()
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .offset(x: 50)),
                                    removal: .opacity.combined(with: .offset(x: -50))
                                ))
                        default:
                            CompletionStep()
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 0.9)),
                                    removal: .opacity.combined(with: .scale(scale: 1.1))
                                ))
                        }
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentStep)
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                // Button with animation
                Button(action: nextStep) {
                    Text(buttonText)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            Group {
                                if currentStep == 1 {
                                    AnimatedMeshGradientBackground()
                                        .clipShape(RoundedRectangle(cornerRadius: 40))
                                } else {
                                    RoundedRectangle(cornerRadius: 40)
                                        .fill(Color.white)
                                }
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(Color.white.opacity(0.2), lineWidth: 4)
                        )
                }
                .padding(.horizontal, 24)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .offset(y: 20)),
                    removal: .opacity
                ))
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: currentStep)
            }
            .padding(.vertical, 40)
        }
    }
    
    @ViewBuilder
    private func NameStep() -> some View {
        VStack(spacing: 50) {
            Text("What's your name?")
                .font(.system(size: 38, weight: .semibold, ))
                .foregroundColor(appState.theme.textPrimary)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            
            TextField("Enter name", text: $userName)
                .font(.system(size: 32, weight: .medium, ))
                .foregroundColor(appState.theme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
        .padding(.horizontal, 32)
    }
    
    @ViewBuilder
    private func CompletionStep() -> some View {
        VStack(spacing: 50) {
            Text("You're ready!")
                .font(.system(size: 38, weight: .semibold, ))
                .foregroundColor(appState.theme.textPrimary)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            
            Text("Start your journey.")
                .font(.system(size: 22, weight: .semibold, ))
                .foregroundColor(appState.theme.textSecondary)
                .multilineTextAlignment(.center)
                .transition(.opacity.combined(with: .offset(y: 15)))
        }
        .padding(.horizontal, 32)
    }
    
    private var buttonText: String {
        switch currentStep {
        case 0: // Name step
            return userName.isEmpty ? "Skip" : "Continue"
        default: // Completion step
            return "Start your journey"
        }
    }
    
    private func nextStep() {
        // Heavy haptic feedback on button tap
        HapticManager.shared.heavy()
        
        if currentStep == 0 {
            // Save name if not empty
            if !userName.isEmpty {
                appState.userName = userName
            }
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentStep += 1
            }
        } else {
            // Complete onboarding
            withAnimation(.easeInOut(duration: 0.6)) {
                appState.isOnboarded = true
            }
            appState.saveUserDefaults()
        }
    }
}

// Animated mesh gradient background using native SwiftUI MeshGradient
struct AnimatedMeshGradientBackground: View {
    @State private var isAnimating = false
    
    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [isAnimating ? 0.2 : 0.8, isAnimating ? 0.3 : 0.7], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                Color(red: 0.5, green: 0.7, blue: 0.15),        // Dark lime
                Color(red: 0.69, green: 0.851, blue: 0.212),    // Base lime #b0d936
                Color(red: 0.8, green: 0.9, blue: 0.35),        // Light lime
                Color(red: 0.6, green: 0.78, blue: 0.18),       // Medium lime
                isAnimating ? Color(red: 0.75, green: 0.88, blue: 0.3) : Color(red: 0.65, green: 0.82, blue: 0.25), // Yellow-green / Lime
                Color(red: 0.8, green: 0.9, blue: 0.35),        // Light lime
                Color(red: 0.69, green: 0.851, blue: 0.212),    // Base lime #b0d936
                Color(red: 0.6, green: 0.78, blue: 0.18),       // Medium lime
                Color(red: 0.5, green: 0.7, blue: 0.15)         // Dark lime
            ]
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                isAnimating.toggle()
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
