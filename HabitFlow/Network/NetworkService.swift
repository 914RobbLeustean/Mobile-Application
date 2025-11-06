//
//  NetworkService.swift
//  HabitFlow
//
//  REST API client for communicating with HabitFlow server
//

import Foundation

/// Network service for API communication
@MainActor
class NetworkService {
    /// Shared singleton instance
    static let shared = NetworkService()

    /// Base URL for API endpoints
    private let baseURL = "http://localhost:3000/api"

    /// URL session for network requests
    private let session: URLSession

    /// JSON encoder with ISO8601 date strategy
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    /// JSON decoder with ISO8601 date strategy
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10 // 10 second timeout
        configuration.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - API Endpoints

    /// Fetch all habits from server
    func fetchHabits() async throws -> [Habit] {
        let url = URL(string: "\(baseURL)/habits")!

        print("🌐 Fetching habits from server...")
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        let habitsResponse = try decoder.decode(HabitsDTOResponse.self, from: data)
        let habits = habitsResponse.habits.map { $0.toHabit() }
        print("✅ Fetched \(habits.count) habits from server")
        return habits
    }

    /// Fetch single habit by ID
    func fetchHabit(id: UUID) async throws -> Habit {
        let url = URL(string: "\(baseURL)/habits/\(id.uuidString)")!

        print("🌐 Fetching habit \(id)...")
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        let habitResponse = try decoder.decode(HabitDTOResponse.self, from: data)
        print("✅ Fetched habit from server")
        return habitResponse.habit.toHabit()
    }

    /// Create new habit on server
    func createHabit(_ habit: Habit) async throws -> Habit {
        let url = URL(string: "\(baseURL)/habits")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Convert Habit to HabitDTO for JSON encoding
        let dto = HabitDTO(from: habit)
        request.httpBody = try encoder.encode(dto)

        print("🌐 Creating habit on server: \(habit.name)")
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard httpResponse.statusCode == 201 else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        let habitResponse = try decoder.decode(HabitDTOResponse.self, from: data)
        print("✅ Created habit on server")
        return habitResponse.habit.toHabit()
    }

    /// Update existing habit on server
    func updateHabit(_ habit: Habit) async throws -> Habit {
        let url = URL(string: "\(baseURL)/habits/\(habit.id.uuidString)")!

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Convert Habit to HabitDTO for JSON encoding
        let dto = HabitDTO(from: habit)
        request.httpBody = try encoder.encode(dto)

        print("🌐 Updating habit on server: \(habit.name)")
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        let habitResponse = try decoder.decode(HabitDTOResponse.self, from: data)
        print("✅ Updated habit on server")
        return habitResponse.habit.toHabit()
    }

    /// Delete habit from server
    func deleteHabit(id: UUID) async throws {
        let url = URL(string: "\(baseURL)/habits/\(id.uuidString)")!

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        print("🌐 Deleting habit from server: \(id)")
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        let deleteResponse = try decoder.decode(DeleteResponse.self, from: data)
        guard deleteResponse.success else {
            throw NetworkError.deleteFailed
        }

        print("✅ Deleted habit from server")
    }

    /// Health check endpoint
    func healthCheck() async throws -> HealthResponse {
        let url = URL(string: "\(baseURL)/health")!

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        return try decoder.decode(HealthResponse.self, from: data)
    }
}

// MARK: - Response Models (using DTOs)

struct HabitsDTOResponse: Codable {
    let habits: [HabitDTO]
}

struct HabitDTOResponse: Codable {
    let habit: HabitDTO
}

struct DeleteResponse: Codable {
    let success: Bool
}

struct HealthResponse: Codable {
    let status: String
    let timestamp: String
    let habitsCount: Int
}

// MARK: - Data Transfer Object

/// DTO for encoding/decoding Habit to/from JSON
struct HabitDTO: Codable {
    let id: String
    let name: String
    let description: String
    let category: String
    let color: String
    let frequency: String
    let createdDate: String

    init(from habit: Habit) {
        self.id = habit.id.uuidString
        self.name = habit.name
        self.description = habit.description
        self.category = habit.category.rawValue.lowercased()
        self.color = habit.color.rawValue.lowercased()
        self.frequency = habit.frequency.rawValue.lowercased()

        let formatter = ISO8601DateFormatter()
        self.createdDate = formatter.string(from: habit.createdDate)
    }

    /// Convert DTO back to Habit object
    func toHabit() -> Habit {
        let uuid = UUID(uuidString: id) ?? UUID()

        // Parse category (case-insensitive)
        let categoryValue = category.capitalized
        let habitCategory = HabitCategory(rawValue: categoryValue) ?? .health

        // Parse color (case-insensitive)
        let colorValue = color.capitalized
        let habitColor = HabitColor(rawValue: colorValue) ?? .blue

        // Parse frequency (case-insensitive)
        let frequencyValue = frequency.capitalized
        let habitFrequency = HabitFrequency(rawValue: frequencyValue) ?? .daily

        // Parse date
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: createdDate) ?? Date()

        return Habit(
            id: uuid,
            name: name,
            description: description,
            category: habitCategory,
            color: habitColor,
            frequency: habitFrequency,
            createdDate: date
        )
    }
}

// MARK: - Network Errors

enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
    case encodingError
    case deleteFailed
    case noConnection

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError:
            return "Failed to decode response"
        case .encodingError:
            return "Failed to encode request"
        case .deleteFailed:
            return "Failed to delete habit"
        case .noConnection:
            return "No network connection"
        }
    }
}
