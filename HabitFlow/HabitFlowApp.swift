//
//  HabitFlowApp.swift
//  HabitFlow
//
//  Main app entry point
//

import SwiftUI
import SwiftData

@main
struct HabitFlowApp: App {
    // Create the model container
    let modelContainer: ModelContainer

    // Network monitor
    @StateObject private var networkMonitor = NetworkMonitor()

    // Create the viewModel with the container's main context
    @StateObject private var viewModel: HabitViewModel

    init() {
        do {
            // Initialize SwiftData container
            let container = try ModelContainer(for: Habit.self)
            modelContainer = container

            // Initialize network monitor
            let monitor = NetworkMonitor()

            // Initialize viewModel with the container's mainContext and network monitor
            let context = container.mainContext
            _viewModel = StateObject(wrappedValue: HabitViewModel(
                modelContext: context,
                networkMonitor: monitor
            ))

            // Note: We use a separate monitor instance here because @StateObject
            // is created in init. The monitor will be shared via environment object.
            _networkMonitor = StateObject(wrappedValue: monitor)

        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            HabitListView()
                .environmentObject(viewModel)
                .environmentObject(networkMonitor)
        }
        .modelContainer(modelContainer)
    }
}
