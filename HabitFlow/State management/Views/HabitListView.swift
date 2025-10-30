//
//  HabitListView.swift
//  HabitFlow
//
//  Main screen displaying all habits (READ operation)
//

import SwiftUI

struct HabitListView: View {
    // Access to the view model (shared state)
    @StateObject private var viewModel = HabitViewModel()
    
    // Navigation state
    @State private var showingAddHabit = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // BACKGROUND - Liquid Glass inspired gradient
                backgroundGradient
                
                // CONTENT
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if viewModel.habits.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(viewModel.habits) { habit in
                                NavigationLink(destination: HabitDetailView(habit: habit)) {
                                    HabitCardView(habit: habit)
                                }
                                .buttonStyle(.plain)
                            }
                            .onDelete { indexSet in
                                // Swipe-to-delete (DELETE operation)
                                viewModel.deleteHabits(at: indexSet)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("HabitFlow")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // Add button
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
                    .environmentObject(viewModel)
            }
        }
        .environmentObject(viewModel)
    }
    
    // MARK: - Subviews
    
    /// Background gradient inspired by iOS 26
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.15),
                Color.purple.opacity(0.15),
                Color.pink.opacity(0.1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    /// Empty state when no habits exist
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            GlassIconBadge(
                icon: "sparkles",
                color: .purple,
                size: 100
            )
            
            Text("No Habits Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Tap the + button to create your first habit")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Habit Card View

struct HabitCardView: View {
    let habit: Habit
    
    var body: some View {
        ColoredGlassCard(color: habit.color.color) {
            HStack(spacing: 16) {
                // Icon
                GlassIconBadge(
                    icon: habit.category.icon,
                    color: habit.color.color,
                    size: 60
                )
                
                // Details
                VStack(alignment: .leading, spacing: 6) {
                    Text(habit.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    Text(habit.category.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    // Frequency badge
                    HStack(spacing: 4) {
                        Image(systemName: habit.frequency.icon)
                            .font(.caption)
                        Text(habit.frequency.rawValue)
                            .font(.caption)
                    }
                    .foregroundStyle(habit.color.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(habit.color.color.opacity(0.2))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    HabitListView()
}
