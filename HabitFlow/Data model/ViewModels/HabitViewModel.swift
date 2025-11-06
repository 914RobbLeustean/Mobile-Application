//
//  HabitViewModel.swift
//  HabitFlow
//
//  ViewModel - Manages habit data and CRUD operations
//  Now uses repository pattern with server sync and offline fallback
//

import Foundation
import Combine
import SwiftUI
import SwiftData

/// Main ViewModel that manages all habit data and operations
/// Uses repository pattern for server sync with offline-first approach
@MainActor
class HabitViewModel: ObservableObject {

    // MARK: - Properties

    /// Repository for data access
    private let repository: HabitRepository

    /// Network monitor for connectivity status
    private let networkMonitor: NetworkMonitor

    /// SwiftData model context (still needed for repository)
    private var modelContext: ModelContext

    /// Published array for UI updates
    @Published var habits: [Habit] = []

    /// Network connectivity status
    @Published var isOnline: Bool = true

    /// Loading state
    @Published var isLoading: Bool = false

    /// Error message for UI
    @Published var errorMessage: String?

    // MARK: - Initialization

    init(
        modelContext: ModelContext,
        networkMonitor: NetworkMonitor
    ) {
        self.modelContext = modelContext
        self.networkMonitor = networkMonitor
        self.repository = HabitRepository(
            networkService: .shared,
            modelContext: modelContext,
            networkMonitor: networkMonitor
        )

        // Bind network status
        self.isOnline = networkMonitor.isConnected

        // Fetch existing habits
        Task {
            await fetchHabits()

            // Check if database is empty and seed sample data on first launch
            if habits.isEmpty {
                print("📦 First launch detected - seeding sample data")
                await loadSampleDataToDB()
                await fetchHabits()
            }
        }

        // Observe network changes
        setupNetworkObserver()
    }

    private func setupNetworkObserver() {
        networkMonitor.$isConnected
            .sink { [weak self] isConnected in
                self?.isOnline = isConnected
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - CRUD Operations

    /// CREATE - Add a new habit (server + local DB)
    func addHabit(_ habit: Habit) {
        // Extract name before entering async context to avoid SwiftData faults
        let habitName = habit.name

        Task {
            isLoading = true
            let result = await repository.createHabit(habit)

            switch result {
            case .success(let createdHabit):
                // Add to local array instead of fetching all
                habits.append(createdHabit)
                print("✅ Habit created: \(habitName)")
            case .failure(let error):
                errorMessage = error.localizedDescription
                print("❌ Failed to create habit: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }

    /// READ - Fetch all habits (server + local DB fallback)
    func fetchHabits() async {
        isLoading = true
        let result = await repository.fetchHabits()

        switch result {
        case .success(let fetchedHabits):
            habits = fetchedHabits
            print("✅ Fetched \(habits.count) habits")
        case .failure(let error):
            errorMessage = error.localizedDescription
            print("❌ Failed to fetch habits: \(error.localizedDescription)")
        }
        isLoading = false
    }

    /// READ - Get all habits (already available via 'habits' property)
    var allHabits: [Habit] {
        habits
    }

    /// READ - Get a specific habit by ID
    func getHabit(by id: UUID) -> Habit? {
        habits.first { $0.id == id }
    }

    /// UPDATE - Update an existing habit (server + local DB)
    func updateHabit(_ updatedHabit: Habit) {
        // Extract name and ID before entering async context to avoid SwiftData faults
        let habitName = updatedHabit.name
        let habitId = updatedHabit.id

        Task {
            isLoading = true
            let result = await repository.updateHabit(updatedHabit)

            switch result {
            case .success(let updated):
                // Update in local array instead of fetching all
                if let index = habits.firstIndex(where: { $0.id == habitId }) {
                    habits[index] = updated
                }
                print("✅ Habit updated: \(habitName)")
            case .failure(let error):
                errorMessage = error.localizedDescription
                print("❌ Failed to update habit: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }

    /// DELETE - Remove a habit by ID (server + local DB)
    func deleteHabit(id: UUID) {
        Task {
            isLoading = true
            let result = await repository.deleteHabit(id: id)

            switch result {
            case .success:
                // Remove from local array instead of fetching all
                habits.removeAll { $0.id == id }
                print("🗑️ Habit deleted")
            case .failure(let error):
                errorMessage = error.localizedDescription
                print("❌ Failed to delete habit: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }

    /// DELETE - Remove a habit object (server + local DB)
    func deleteHabit(_ habit: Habit) {
        deleteHabit(id: habit.id)
    }

    /// DELETE - Remove habits at specific indices (for swipe-to-delete)
    func deleteHabits(at offsets: IndexSet) {
        // Extract IDs before entering async context to avoid SwiftData faults
        let habitIds = offsets.map { habits[$0].id }

        Task {
            isLoading = true
            for habitId in habitIds {
                let result = await repository.deleteHabit(id: habitId)
                if case .success = result {
                    // Remove from local array immediately
                    habits.removeAll { $0.id == habitId }
                }
            }
            isLoading = false
            print("🗑️ Deleted \(habitIds.count) habit(s)")
        }
    }

    // MARK: - Sync Operations

    /// Force sync with server (manual refresh)
    func syncWithServer() {
        Task {
            isLoading = true
            let result = await repository.syncWithServer()

            switch result {
            case .success(let syncedHabits):
                habits = syncedHabits
                print("🔄 Synced \(habits.count) habits from server")
            case .failure(let error):
                errorMessage = error.localizedDescription
                print("❌ Sync failed: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }

    // MARK: - Utility Functions

    /// Load sample data (only on first launch)
    private func loadSampleDataToDB() async {
        for sampleHabit in Habit.sampleHabits {
            _ = await repository.createHabit(sampleHabit)
        }
        print("📦 Sample data seeded")
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
        Task {
            await repository.clearLocalCache()
            await fetchHabits()
            print("🧹 All habits cleared")
        }
    }

    /// Reset to sample data
    func resetToSampleData() {
        Task {
            await repository.clearLocalCache()
            await loadSampleDataToDB()
            await fetchHabits()
            print("🔄 Reset to sample data")
        }
    }
}

// MARK: - Preview Helper

extension HabitViewModel {
    /// Create a view model with in-memory container for previews
    static var preview: HabitViewModel {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Habit.self, configurations: config)
        let context = container.mainContext

        // Add sample data to preview context
        for habit in Habit.sampleHabits {
            context.insert(habit)
        }

        let networkMonitor = NetworkMonitor()
        return HabitViewModel(modelContext: context, networkMonitor: networkMonitor)
    }
}
