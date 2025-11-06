//
//  HabitRepository.swift
//  HabitFlow
//
//  Repository pattern for habit data access with offline-first approach
//  Tries server first, falls back to local DB if offline or server fails
//

import Foundation
import SwiftData

@MainActor
class HabitRepository {
    // MARK: - Properties

    private let networkService: NetworkService
    private let modelContext: ModelContext
    private let networkMonitor: NetworkMonitor

    // MARK: - Initialization

    init(
        networkService: NetworkService = .shared,
        modelContext: ModelContext,
        networkMonitor: NetworkMonitor
    ) {
        self.networkService = networkService
        self.modelContext = modelContext
        self.networkMonitor = networkMonitor
    }

    // MARK: - CRUD Operations

    /// Fetch all habits (server first, local DB fallback)
    func fetchHabits() async -> Result<[Habit], RepositoryError> {
        // Check network connectivity
        if networkMonitor.isConnected {
            do {
                // Try fetching from server
                let serverHabits = try await networkService.fetchHabits()
                print("✅ Fetched \(serverHabits.count) habits from server")

                // Sync to local DB (merge strategy)
                await syncToLocalDB(serverHabits)

                // Return habits from local DB to ensure we have the merged objects
                return await fetchFromLocalDB()
            } catch {
                print("⚠️  Server fetch failed: \(error.localizedDescription)")
                print("📴 Falling back to local database")

                // Fallback to local DB
                return await fetchFromLocalDB()
            }
        } else {
            print("📴 Offline - using local database")
            return await fetchFromLocalDB()
        }
    }

    /// Create new habit (server first, local DB fallback)
    func createHabit(_ habit: Habit) async -> Result<Habit, RepositoryError> {
        // Always save to local DB first (offline-first)
        await saveToLocalDB(habit)

        // If online, sync to server
        if networkMonitor.isConnected {
            do {
                _ = try await networkService.createHabit(habit)
                print("✅ Created habit on server and local DB")
            } catch {
                print("⚠️  Server create failed: \(error.localizedDescription)")
                print("📴 Habit saved locally only")
            }
        } else {
            print("📴 Offline - habit saved locally only")
        }

        // Always return the habit from local DB context to ensure it's properly managed
        return .success(habit)
    }

    /// Update existing habit (server first, local DB fallback)
    func updateHabit(_ habit: Habit) async -> Result<Habit, RepositoryError> {
        // Always update local DB first
        await updateInLocalDB(habit)

        // If online, sync to server
        if networkMonitor.isConnected {
            do {
                _ = try await networkService.updateHabit(habit)
                print("✅ Updated habit on server and local DB")
            } catch {
                print("⚠️  Server update failed: \(error.localizedDescription)")
                print("📴 Habit updated locally only")
            }
        } else {
            print("📴 Offline - habit updated locally only")
        }

        // Always return the habit from local DB context to ensure it's properly managed
        return .success(habit)
    }

    /// Delete habit (server first, local DB fallback)
    func deleteHabit(id: UUID) async -> Result<Void, RepositoryError> {
        // If online, delete from server first
        if networkMonitor.isConnected {
            do {
                try await networkService.deleteHabit(id: id)
                print("✅ Deleted habit from server")

                // Then delete from local DB
                await deleteFromLocalDB(id: id)
                return .success(())
            } catch {
                print("⚠️  Server delete failed: \(error.localizedDescription)")
                print("📴 Deleting from local DB only")

                await deleteFromLocalDB(id: id)
                return .success(())
            }
        } else {
            print("📴 Offline - deleting from local DB only")
            await deleteFromLocalDB(id: id)
            return .success(())
        }
    }

    // MARK: - Local Database Operations

    /// Fetch habits from local SwiftData database
    private func fetchFromLocalDB() async -> Result<[Habit], RepositoryError> {
        let descriptor = FetchDescriptor<Habit>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )

        do {
            let habits = try modelContext.fetch(descriptor)
            print("✅ Fetched \(habits.count) habits from local DB")
            return .success(habits)
        } catch {
            print("❌ Local DB fetch failed: \(error.localizedDescription)")
            return .failure(.localDBError(error))
        }
    }

    /// Save habit to local database
    private func saveToLocalDB(_ habit: Habit) async {
        modelContext.insert(habit)
        do {
            try modelContext.save()
            print("💾 Saved habit to local DB: \(habit.name)")
        } catch {
            print("❌ Failed to save to local DB: \(error.localizedDescription)")
        }
    }

    /// Update habit in local database
    private func updateInLocalDB(_ habit: Habit) async {
        do {
            try modelContext.save()
            print("💾 Updated habit in local DB: \(habit.name)")
        } catch {
            print("❌ Failed to update local DB: \(error.localizedDescription)")
        }
    }

    /// Delete habit from local database
    private func deleteFromLocalDB(id: UUID) async {
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            let habits = try modelContext.fetch(descriptor)
            if let habit = habits.first {
                modelContext.delete(habit)
                try modelContext.save()
                print("💾 Deleted habit from local DB")
            }
        } catch {
            print("❌ Failed to delete from local DB: \(error.localizedDescription)")
        }
    }

    /// Sync server data to local database (merge strategy)
    private func syncToLocalDB(_ serverHabits: [Habit]) async {
        // Merge strategy: update existing, add new, delete removed
        // This prevents SwiftData faults by not deleting objects that are still in use

        do {
            // Fetch all existing habits
            let descriptor = FetchDescriptor<Habit>()
            let existingHabits = try modelContext.fetch(descriptor)

            // Create a map of existing habits by ID for quick lookup
            var existingMap = Dictionary(uniqueKeysWithValues: existingHabits.map { ($0.id, $0) })

            // Track server IDs
            let serverIDs = Set(serverHabits.map { $0.id })

            // Update or insert habits from server
            for serverHabit in serverHabits {
                if let existingHabit = existingMap[serverHabit.id] {
                    // Update existing habit in-place (prevents detachment)
                    existingHabit.name = serverHabit.name
                    existingHabit.habitDescription = serverHabit.habitDescription
                    existingHabit.category = serverHabit.category
                    existingHabit.color = serverHabit.color
                    existingHabit.frequency = serverHabit.frequency
                    existingHabit.createdDate = serverHabit.createdDate
                } else {
                    // Insert new habit
                    modelContext.insert(serverHabit)
                }
            }

            // Delete habits that are no longer on server
            for (id, existingHabit) in existingMap {
                if !serverIDs.contains(id) {
                    modelContext.delete(existingHabit)
                }
            }

            try modelContext.save()
            print("💾 Synced \(serverHabits.count) habits to local DB (merge strategy)")
        } catch {
            print("❌ Sync to local DB failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Helper Methods

    /// Force sync with server (manual refresh)
    func syncWithServer() async -> Result<[Habit], RepositoryError> {
        guard networkMonitor.isConnected else {
            return .failure(.noConnection)
        }

        do {
            let serverHabits = try await networkService.fetchHabits()
            await syncToLocalDB(serverHabits)
            print("🔄 Manual sync completed")

            // Return habits from local DB to ensure we have the merged objects
            return await fetchFromLocalDB()
        } catch {
            print("❌ Manual sync failed: \(error.localizedDescription)")
            return .failure(.serverError(error))
        }
    }

    /// Clear all local data
    func clearLocalCache() async {
        let descriptor = FetchDescriptor<Habit>()
        do {
            let habits = try modelContext.fetch(descriptor)
            for habit in habits {
                modelContext.delete(habit)
            }
            try modelContext.save()
            print("🧹 Cleared local cache")
        } catch {
            print("❌ Failed to clear cache: \(error.localizedDescription)")
        }
    }
}

// MARK: - Repository Errors

enum RepositoryError: Error, LocalizedError {
    case noConnection
    case serverError(Error)
    case localDBError(Error)
    case syncFailed

    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No network connection"
        case .serverError(let error):
            return "Server error: \(error.localizedDescription)"
        case .localDBError(let error):
            return "Local database error: \(error.localizedDescription)"
        case .syncFailed:
            return "Failed to sync with server"
        }
    }
}
