import SwiftUI

// MARK: - SidebarSelection

enum SidebarSelection: Hashable {
    case all
    case category(UUID)
}

// MARK: - ContentView

struct ContentView: View {
    @EnvironmentObject var store: GoalStore
    @State private var sidebarSelection: SidebarSelection? = .all
    @State private var selectedGoalId: UUID?
    @State private var showingAddGoal = false

    // Goals visible in the middle column based on sidebar selection
    var currentGoals: [Goal] {
        switch sidebarSelection {
        case .all, nil:
            return store.goals.sorted { $0.updatedAt > $1.updatedAt }
        case .category(let id):
            return store.goals
                .filter { $0.categoryId == id }
                .sorted { $0.updatedAt > $1.updatedAt }
        }
    }

    var currentTitle: String {
        switch sidebarSelection {
        case .all, nil:
            return "All Goals"
        case .category(let id):
            return store.category(for: id)?.name ?? "Goals"
        }
    }

    var isAllGoalsSelected: Bool {
        switch sidebarSelection {
        case .all, nil:
            return true
        case .category:
            return false
        }
    }

    // Keep selectedGoalId valid when goals change
    var selectedGoal: Goal? {
        guard let id = selectedGoalId else { return nil }
        return store.goals.first { $0.id == id }
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $sidebarSelection)
                .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 280)
        } content: {
            GoalListView(
                title: currentTitle,
                isAllGoals: isAllGoalsSelected,
                goals: currentGoals,
                selectedGoalId: $selectedGoalId,
                onAdd: { showingAddGoal = true }
            )
            .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 440)
        } detail: {
            if let goal = selectedGoal {
                GoalDetailView(goal: goal)
            } else {
                EmptyDetailView()
            }
        }
        .sheet(isPresented: $showingAddGoal) {
            AddEditGoalView(initialCategoryId: {
                if case .category(let id) = sidebarSelection { return id }
                return nil
            }())
        }
    }
}

// MARK: - EmptyDetailView

struct EmptyDetailView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "scope")
                .font(.system(size: 56, weight: .ultraLight))
                .foregroundStyle(.secondary)
            Text("Select a Goal")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("Choose a goal from the list to view progress and notes.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 260)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
