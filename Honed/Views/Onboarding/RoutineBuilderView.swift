import SwiftUI

struct RoutineBuilderView: View {
    @EnvironmentObject var authState: AuthState
    @EnvironmentObject var appState: AppState
    @State private var showingDayPicker = false
    @State private var draggedItem: WorkoutDayType?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Text("Build your routine")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(appState.theme.textPrimary)
                
                Text("Add days to create your workout cycle")
                    .font(.system(size: 17))
                    .foregroundColor(appState.theme.textMuted)
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)
            
            // Routine display
            if authState.routine.days.isEmpty {
                // Empty state
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 48))
                        .foregroundColor(appState.theme.textMuted.opacity(0.5))
                    
                    Text("No days added yet")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(appState.theme.textMuted)
                    
                    Text("Tap + to add your first workout day")
                        .font(.system(size: 14))
                        .foregroundColor(appState.theme.textMuted.opacity(0.7))
                }
                
                Spacer()
            } else {
                // List of days
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(authState.routine.days.enumerated()), id: \.element.id) { index, day in
                            RoutineDayCard(
                                day: day,
                                index: index,
                                onDelete: { deleteDay(at: index) },
                                onMove: { direction in moveDay(from: index, direction: direction) }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                }
                
                // Cycle preview
                VStack(spacing: 8) {
                    Text("Your cycle repeats indefinitely")
                        .font(.system(size: 13))
                        .foregroundColor(appState.theme.textMuted)
                    
                    HStack(spacing: 4) {
                        ForEach(authState.routine.days.prefix(5), id: \.id) { day in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(day.swiftUIColor)
                                .frame(width: 24, height: 8)
                        }
                        if authState.routine.days.count > 5 {
                            Text("+")
                                .font(.system(size: 12))
                                .foregroundColor(appState.theme.textMuted)
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            
            // Bottom buttons
            VStack(spacing: 12) {
                // Add button
                Button(action: { showingDayPicker = true }) {
                    ZStack {
                        Circle()
                            .fill(appState.accentColor.swiftUIColor)
                            .frame(width: 64, height: 64)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
                .padding(.bottom, 8)
                
                // Continue button
                Button(action: continueToRestDays) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(authState.routine.days.isEmpty ? appState.theme.textMuted : .black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 40)
                                .fill(authState.routine.days.isEmpty ? appState.theme.cardBackground : appState.accentColor.swiftUIColor)
                        )
                }
                .disabled(authState.routine.days.isEmpty)
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 32)
        }
        .sheet(isPresented: $showingDayPicker) {
            DayPickerSheet { dayType in
                authState.routine.days.append(dayType)
                showingDayPicker = false
            }
            .environmentObject(appState)
        }
    }
    
    private func deleteDay(at index: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            authState.routine.days.remove(at: index)
        }
    }
    
    private func moveDay(from index: Int, direction: Int) {
        let newIndex = index + direction
        guard newIndex >= 0 && newIndex < authState.routine.days.count else { return }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            authState.routine.days.swapAt(index, newIndex)
        }
    }
    
    private func continueToRestDays() {
        HapticManager.shared.heavy()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            authState.nextStep()
        }
    }
}

struct RoutineDayCard: View {
    let day: WorkoutDayType
    let index: Int
    let onDelete: () -> Void
    let onMove: (Int) -> Void
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 16) {
            // Index number
            Text("\(index + 1)")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(appState.theme.textMuted)
                .frame(width: 32)
            
            // Icon
            Image(systemName: day.icon)
                .font(.system(size: 20))
                .foregroundColor(day.swiftUIColor)
                .frame(width: 40, height: 40)
                .background(day.swiftUIColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Name
            Text(day.name)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(appState.theme.textPrimary)
            
            Spacer()
            
            // Move buttons
            VStack(spacing: 4) {
                Button(action: { onMove(-1) }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(appState.theme.textMuted)
                }
                .disabled(index == 0)
                
                Button(action: { onMove(1) }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(appState.theme.textMuted)
                }
                .disabled(false) // Always enabled for simplicity
            }
            .frame(width: 32)
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(appState.theme.textMuted)
                    .frame(width: 32, height: 32)
                    .background(appState.theme.cardBackground)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(appState.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct DayPickerSheet: View {
    let onSelect: (WorkoutDayType) -> Void
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(WorkoutDayType.allTypes) { dayType in
                        DayTypeButton(dayType: dayType) {
                            onSelect(dayType)
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle("Select Day Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(appState.theme.textSecondary)
                }
            }
            .background(appState.theme.background.ignoresSafeArea())
        }
    }
}

struct DayTypeButton: View {
    let dayType: WorkoutDayType
    let action: () -> Void
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: dayType.icon)
                    .font(.system(size: 28))
                    .foregroundColor(dayType.swiftUIColor)
                    .frame(width: 60, height: 60)
                    .background(dayType.swiftUIColor.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Text(dayType.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(appState.theme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(appState.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    RoutineBuilderView()
        .environmentObject(AuthState())
        .environmentObject(AppState())
}
