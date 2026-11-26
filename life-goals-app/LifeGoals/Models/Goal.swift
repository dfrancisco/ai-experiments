import Foundation

// MARK: - Goal

struct Goal: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var categoryId: UUID?
    var status: GoalStatus = .notStarted
    var targetDate: Date?
    var notes: [ProgressNote] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

// MARK: - GoalStatus

enum GoalStatus: String, Codable, CaseIterable, Identifiable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case completed   = "Completed"
    case paused      = "Paused"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .notStarted: return "circle"
        case .inProgress: return "arrow.triangle.2.circlepath.circle.fill"
        case .completed:  return "checkmark.circle.fill"
        case .paused:     return "pause.circle.fill"
        }
    }

    /// Semantic color name used in the view layer
    var colorName: String {
        switch self {
        case .notStarted: return "secondary"
        case .inProgress: return "blue"
        case .completed:  return "green"
        case .paused:     return "orange"
        }
    }
}

// MARK: - ProgressNote

struct ProgressNote: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var content: String
    var createdAt: Date = Date()
}
