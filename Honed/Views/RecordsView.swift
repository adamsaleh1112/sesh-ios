import SwiftUI
import Foundation

struct RecordsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var calendarManager: CalendarManager
    
    var body: some View {
        NavigationView {
            ZStack {
                appState.theme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Records")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(appState.theme.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 64))
                            .foregroundColor(appState.theme.textMuted)
                        
                        Text("No records yet")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(appState.theme.textPrimary)
                        
                        Text("Track your personal records and PRs here")
                            .font(.system(size: 16))
                            .foregroundColor(appState.theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxHeight: .infinity)
                    
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    RecordsView()
        .environmentObject(AppState())
        .environmentObject(CalendarManager())
}
