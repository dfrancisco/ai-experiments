import Foundation
import Combine

// MARK: - GoalStore

@MainActor
final class GoalStore: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var categories: [GoalCategory] = []

    private let goalsURL: URL
    private let categoriesURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = appSupport.appendingPathComponent("LifeGoals", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        goalsURL      = dir.appendingPathComponent("goals.json")
        categoriesURL = dir.appendingPathComponent("categories.json")

        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        load()
    }

    // MARK: - Persistence

    private func load() {
        if let data = try? Data(contentsOf: goalsURL),
           let decoded = try? decoder.decode([Goal].self, from: data) {
            goals = decoded
        }

        if let data = try? Data(contentsOf: categoriesURL),
           let decoded = try? decoder.decode([GoalCategory].self, from: data) {
            categories = decoded
        } else {
            // First launch: seed with defaults
            categories = GoalCategory.defaults
            saveCategories()
        }
    }

    private func saveGoals() {
        guard let data = try? encoder.encode(goals) else { return }
        try? data.write(to: goalsURL, options: .atomic)
    }

    private func saveCategories() {
        guard let data = try? encoder.encode(categories) else { return }
        try? data.write(to: categoriesURL, options: .atomic)
    }

    // MARK: - Goal CRUD

    func addGoal(_ goal: Goal) {
        goals.append(goal)
        saveGoals()
    }

    func updateGoal(_ goal: Goal) {
        guard let idx = goals.firstIndex(where: { $0.id == goal.id }) else { return }
        var updated = goal
        updated.updatedAt = Date()
        goals[idx] = updated
        saveGoals()
    }

    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        saveGoals()
    }

    func deleteGoals(at offsets: IndexSet, in list: [Goal]) {
        let idsToDelete = offsets.map { list[$0].id }
        goals.removeAll { idsToDelete.contains($0.id) }
        saveGoals()
    }

    // MARK: - Note CRUD

    func addNote(_ note: ProgressNote, to goal: Goal) {
        guard let idx = goals.firstIndex(where: { $0.id == goal.id }) else { return }
        goals[idx].notes.insert(note, at: 0)
        goals[idx].updatedAt = Date()
        saveGoals()
    }

    func deleteNote(_ note: ProgressNote, from goal: Goal) {
        guard let gIdx = goals.firstIndex(where: { $0.id == goal.id }) else { return }
        goals[gIdx].notes.removeAll { $0.id == note.id }
        goals[gIdx].updatedAt = Date()
        saveGoals()
    }

    // MARK: - Category CRUD

    func addCategory(_ category: GoalCategory) {
        categories.append(category)
        saveCategories()
    }

    func deleteCategory(_ category: GoalCategory) {
        categories.removeAll { $0.id == category.id }
        // Orphan goals by clearing their categoryId
        for i in goals.indices where goals[i].categoryId == category.id {
            goals[i].categoryId = nil
        }
        saveCategories()
        saveGoals()
    }

    // MARK: - Convenience

    func category(for id: UUID?) -> GoalCategory? {
        guard let id else { return nil }
        return categories.first { $0.id == id }
    }

    func goals(for categoryId: UUID) -> [Goal] {
        goals.filter { $0.categoryId == categoryId }
    }

    func goalCount(for categoryId: UUID) -> Int {
        goals.filter { $0.categoryId == categoryId }.count
    }
}
