//
//  EditHabitView.swift
//  HabitFlow
//
//  Form to edit an existing habit (UPDATE operation)
//

import SwiftUI

struct EditHabitView: View {
    // Environment
    @EnvironmentObject var viewModel: HabitViewModel
    @Environment(\.dismiss) var dismiss
    
    // The habit to edit
    let habit: Habit
    
    // Form fields (initialized with habit data)
    @State private var name: String
    @State private var description: String
    @State private var selectedCategory: HabitCategory
    @State private var selectedColor: HabitColor
    @State private var selectedFrequency: HabitFrequency
    
    // Validation
    @State private var showingValidationAlert = false
    
    init(habit: Habit) {
        self.habit = habit
        // Initialize state with existing habit data
        _name = State(initialValue: habit.name)
        _description = State(initialValue: habit.description)
        _selectedCategory = State(initialValue: habit.category)
        _selectedColor = State(initialValue: habit.color)
        _selectedFrequency = State(initialValue: habit.frequency)
    }
    
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
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveChanges()
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
                    
                    TextField("Habit name", text: $name)
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
            
            // Metadata (non-editable)
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Created", systemImage: "calendar")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text(habit.createdDate, style: .date)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    // MARK: - Actions

    private func saveChanges() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        guard !trimmedName.isEmpty else {
            showingValidationAlert = true
            return
        }

        // Update the habit object directly (SwiftData managed object)
        habit.name = trimmedName
        habit.description = description
        habit.category = selectedCategory
        habit.color = selectedColor
        habit.frequency = selectedFrequency
        // Note: id and createdDate are preserved automatically

        viewModel.updateHabit(habit)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    EditHabitView(habit: Habit.sampleHabits[0])
        .environmentObject(HabitViewModel.preview)
}
