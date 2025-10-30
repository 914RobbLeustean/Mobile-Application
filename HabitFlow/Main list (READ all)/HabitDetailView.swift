//
//  HabitDetailView.swift
//  HabitFlow
//
//  Detail view for a single habit (READ single + DELETE)
//

import SwiftUI

struct HabitDetailView: View {
    // Environment to access view model
    @EnvironmentObject var viewModel: HabitViewModel
    
    // Environment to dismiss the view
    @Environment(\.dismiss) var dismiss
    
    // The habit to display
    let habit: Habit
    
    // Navigation state
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Header with icon
                    headerSection
                    
                    // Habit details
                    detailsSection
                    
                    // Action buttons
                    actionsSection
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingEditSheet = true
                } label: {
                    Text("Edit")
                        .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditHabitView(habit: habit)
                .environmentObject(viewModel)
        }
        .alert("Delete Habit?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteHabit()
            }
        } message: {
            Text("Are you sure you want to delete '\(habit.name)'? This action cannot be undone.")
        }
    }
    
    // MARK: - Subviews
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                habit.color.color.opacity(0.2),
                habit.color.color.opacity(0.05),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Large icon
            GlassIconBadge(
                icon: habit.category.icon,
                color: habit.color.color,
                size: 120
            )
            
            // Habit name
            Text(habit.name)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Category badge
            HStack(spacing: 8) {
                Image(systemName: habit.category.icon)
                Text(habit.category.rawValue)
            }
            .font(.subheadline)
            .foregroundStyle(habit.color.color)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(habit.color.color.opacity(0.2))
            )
        }
        .padding(.top, 20)
    }
    
    private var detailsSection: some View {
        VStack(spacing: 16) {
            // Description
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Description", systemImage: "text.alignleft")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text(habit.description)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Frequency
            GlassCard {
                HStack {
                    Label("Frequency", systemImage: habit.frequency.icon)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(habit.frequency.rawValue)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(habit.color.color)
                }
            }
            
            // Color
            GlassCard {
                HStack {
                    Label("Color", systemImage: "paintpalette.fill")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Circle()
                            .fill(habit.color.color)
                            .frame(width: 24, height: 24)
                        
                        Text(habit.color.rawValue)
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                }
            }
            
            // Created date
            GlassCard {
                HStack {
                    Label("Created", systemImage: "calendar")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(habit.createdDate, style: .date)
                        .font(.body)
                }
            }
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            // Delete button
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Delete Habit")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    ZStack {
                        Color.red.opacity(0.15)
                        Rectangle()
                            .fill(.ultraThinMaterial)
                    }
                )
                .foregroundStyle(.red)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1.5)
                )
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Actions
    
    private func deleteHabit() {
        viewModel.deleteHabit(id: habit.id)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HabitDetailView(habit: Habit.sampleHabits[0])
            .environmentObject(HabitViewModel.preview)
    }
}
