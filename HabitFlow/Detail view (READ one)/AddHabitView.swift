//
//  AddHabitView.swift
//  HabitFlow
//
//  Form to create a new habit (CREATE operation)
//

import SwiftUI

struct AddHabitView: View {
    // Environment
    @EnvironmentObject var viewModel: HabitViewModel
    @Environment(\.dismiss) var dismiss
    
    // Form fields
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedCategory: HabitCategory = .health
    @State private var selectedColor: HabitColor = .blue
    @State private var selectedFrequency: HabitFrequency = .daily
    
    // Validation
    @State private var showingValidationAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                backgroundGradient
                
                // Form
                ScrollView {
                    VStack(spacing: 20) {
                        // Preview card
                        previewCard
                        
                        // Form sections
                        formSections
                    }
                    .padding()
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveHabit()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("Invalid Input", isPresented: $showingValidationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter a habit name.")
            }
        }
    }
    
    // MARK: - Subviews
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                selectedColor.color.opacity(0.15),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var previewCard: some View {
        ColoredGlassCard(color: selectedColor.color) {
            HStack(spacing: 16) {
                GlassIconBadge(
                    icon: selectedCategory.icon,
                    color: selectedColor.color,
                    size: 60
                )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(name.isEmpty ? "Habit Name" : name)
                        .font(.headline)
                        .foregroundStyle(name.isEmpty ? .secondary : .primary)
                    
                    Text(selectedCategory.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: selectedFrequency.icon)
                            .font(.caption)
                        Text(selectedFrequency.rawValue)
                            .font(.caption)
                    }
                    .foregroundStyle(selectedColor.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(selectedColor.color.opacity(0.2))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
        }
    }
    
    private var formSections: some View {
        VStack(spacing: 16) {
            // Name field
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Habit Name", systemImage: "pencil")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    TextField("e.g., Morning Meditation", text: $name)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(10)
                }
            }
            
            // Description field
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Description", systemImage: "text.alignleft")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .scrollContentBackground(.hidden)
                        .padding(8)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(10)
                }
            }
            
            // Category picker
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Category", systemImage: "folder.fill")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(HabitCategory.allCases) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(12)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(10)
                }
            }
            
            // Color picker
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Color", systemImage: "paintpalette.fill")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(HabitColor.allCases) { color in
                                ColorCircle(
                                    color: color,
                                    isSelected: selectedColor == color
                                ) {
                                    selectedColor = color
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            // Frequency picker
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Frequency", systemImage: "calendar")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Picker("Frequency", selection: $selectedFrequency) {
                        ForEach(HabitFrequency.allCases) { frequency in
                            Text(frequency.rawValue).tag(frequency)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func saveHabit() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedName.isEmpty else {
            showingValidationAlert = true
            return
        }
        
        let newHabit = Habit(
            name: trimmedName,
            description: description,
            category: selectedCategory,
            color: selectedColor,
            frequency: selectedFrequency
        )
        
        viewModel.addHabit(newHabit)
        dismiss()
    }
}

// MARK: - Color Circle Button

struct ColorCircle: View {
    let color: HabitColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.color)
                    .frame(width: 50, height: 50)
                
                if isSelected {
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .stroke(color.color, lineWidth: 2)
                        .frame(width: 58, height: 58)
                    
                    Image(systemName: "checkmark")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    AddHabitView()
        .environmentObject(HabitViewModel.preview)
}
