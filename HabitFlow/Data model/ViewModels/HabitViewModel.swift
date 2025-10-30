//
//  HabitViewModel.swift
//  HabitFlow
//
//  ViewModel - Manages habit data and CRUD operations
//

import Foundation
import Combine
import SwiftUI

/// Main ViewModel that manages all habit data and operations
/// Uses @Observable macro (iOS 17+) or ObservableObject (iOS 16+)
@MainActor
class HabitViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Array of all habits (triggers UI updates when changed)
    @Published var habits: [Habit] = []
    
    // MARK: - Initialization
    
    init() {
        // Load sample data for demo
        loadSampleData()
    }
    
    // MARK: - CRUD Operations
    
    /// CREATE - Add a new habit
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        // Sort by creation date (newest first)
        habits.sort { $0.createdDate > $1.createdDate }
    }
    
    /// READ - Get all habits (already available via 'habits' property)
    /// This computed property can be used for filtering/sorting if needed
    var allHabits: [Habit] {
        habits
    }
    
    /// READ - Get a specific habit by ID
    func getHabit(by id: UUID) -> Habit? {
        habits.first { $0.id == id }
    }
    
    /// UPDATE - Update an existing habit
    func updateHabit(_ updatedHabit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == updatedHabit.id }) else {
            print("❌ Habit not found for update")
            return
        }
        
        habits[index] = updatedHabit
        print("✅ Habit updated: \(updatedHabit.name)")
    }
    
    /// DELETE - Remove a habit by ID
    func deleteHabit(id: UUID) {
        habits.removeAll { $0.id == id }
        print("🗑️ Habit deleted")
    }
    
    /// DELETE - Remove habits at specific indices (for swipe-to-delete)
    func deleteHabits(at offsets: IndexSet) {
        habits.remove(atOffsets: offsets)
        print("🗑️ Habits deleted at indices: \(offsets)")
    }
    
    // MARK: - Utility Functions
    
    /// Load sample data for testing
    private func loadSampleData() {
        habits = Habit.sampleHabits
        print("📦 Loaded \(habits.count) sample habits")
    }
    
    /// Get habits filtered by category
    func habits(for category: HabitCategory) -> [Habit] {
        habits.filter { $0.category == category }
    }
    
    /// Get habits filtered by frequency
    func habits(for frequency: HabitFrequency) -> [Habit] {
        habits.filter { $0.frequency == frequency }
    }
    
    /// Get count of habits by category
    func habitCount(for category: HabitCategory) -> Int {
        habits(for: category).count
    }
    
    /// Clear all habits (useful for testing)
    func clearAllHabits() {
        habits.removeAll()
        print("🧹 All habits cleared")
    }
    
    /// Reset to sample data
    func resetToSampleData() {
        loadSampleData()
        print("🔄 Reset to sample data")
    }
}

// MARK: - Preview Helper

extension HabitViewModel {
    /// Create a view model with sample data for previews
    static var preview: HabitViewModel {
        let vm = HabitViewModel()
        return vm
    }
}
