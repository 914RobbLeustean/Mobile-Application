//
//  Habit.swift
//  HabitFlow
//
//  Data Model for Habit Tracker
//

import Foundation
import SwiftUI
import SwiftData

/// Represents a single habit with all its properties
/// Now persisted to local database using SwiftData and synced with server
@Model
class Habit {
    // Unique identifier for each habit (required for SwiftUI lists)
    var id: UUID

    // Habit properties
    var name: String
    var habitDescription: String  // Renamed to avoid @Model reserved keyword
    var category: HabitCategory
    var color: HabitColor
    var frequency: HabitFrequency
    var createdDate: Date

    /// Default initializer
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        category: HabitCategory,
        color: HabitColor,
        frequency: HabitFrequency,
        createdDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.habitDescription = description
        self.category = category
        self.color = color
        self.frequency = frequency
        self.createdDate = createdDate
    }

    // Computed property for backward compatibility
    var description: String {
        get { habitDescription }
        set { habitDescription = newValue }
    }
}

// Note: @Model macro provides Codable support automatically
// JSON serialization is handled via HabitDTO in NetworkService

// MARK: - Habit Category

/// Categories for organizing habits
enum HabitCategory: String, Codable, CaseIterable, Identifiable {
    case health = "Health"
    case productivity = "Productivity"
    case learning = "Learning"
    case fitness = "Fitness"
    case mindfulness = "Mindfulness"
    case social = "Social"
    case creative = "Creative"
    case finance = "Finance"
    
    var id: String { rawValue }
    
    /// SF Symbol icon for each category
    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .productivity: return "checkmark.circle.fill"
        case .learning: return "book.fill"
        case .fitness: return "figure.run"
        case .mindfulness: return "brain.head.profile"
        case .social: return "person.2.fill"
        case .creative: return "paintbrush.fill"
        case .finance: return "dollarsign.circle.fill"
        }
    }
}

// MARK: - Habit Color

/// Color options for habits (stored as string for Codable)
enum HabitColor: String, Codable, CaseIterable, Identifiable {
    case blue = "Blue"
    case purple = "Purple"
    case pink = "Pink"
    case red = "Red"
    case orange = "Orange"
    case yellow = "Yellow"
    case green = "Green"
    case teal = "Teal"
    
    var id: String { rawValue }
    
    /// Convert to SwiftUI Color
    var color: Color {
        switch self {
        case .blue: return .blue
        case .purple: return .purple
        case .pink: return .pink
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .teal: return .teal
        }
    }
}

// MARK: - Habit Frequency

/// How often the habit should be performed
enum HabitFrequency: String, Codable, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case custom = "Custom"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .daily: return "sun.max.fill"
        case .weekly: return "calendar.badge.clock"
        case .monthly: return "calendar"
        case .custom: return "slider.horizontal.3"
        }
    }
}

// MARK: - Sample Data

extension Habit {
    /// Sample habits for testing and demo purposes
    static let sampleHabits: [Habit] = [
        Habit(
            name: "Morning Meditation",
            description: "Start the day with 10 minutes of mindful meditation to clear my mind and set intentions.",
            category: .mindfulness,
            color: .purple,
            frequency: .daily
        ),
        Habit(
            name: "Read for 30 Minutes",
            description: "Read personal development or fiction books to expand knowledge and imagination.",
            category: .learning,
            color: .blue,
            frequency: .daily
        ),
        Habit(
            name: "Gym Workout",
            description: "Complete strength training or cardio workout at the gym.",
            category: .fitness,
            color: .red,
            frequency: .weekly
        ),
        Habit(
            name: "Drink 8 Glasses of Water",
            description: "Stay hydrated throughout the day for better health and energy.",
            category: .health,
            color: .teal,
            frequency: .daily
        ),
        Habit(
            name: "Weekly Budget Review",
            description: "Review expenses and update budget to stay on financial track.",
            category: .finance,
            color: .green,
            frequency: .weekly
        ),
        Habit(
            name: "Learn Swift",
            description: "Practice Swift programming for 1 hour to improve iOS development skills.",
            category: .learning,
            color: .orange,
            frequency: .daily
        ),
        Habit(
            name: "Evening Walk",
            description: "Take a relaxing 20-minute walk to unwind and reflect on the day.",
            category: .fitness,
            color: .yellow,
            frequency: .daily
        ),
        Habit(
            name: "Creative Writing",
            description: "Write at least 500 words of creative content, stories, or journal entries.",
            category: .creative,
            color: .pink,
            frequency: .weekly
        )
    ]
}
