import SwiftUI

struct GoalListView: View {
    @EnvironmentObject var store: GoalStore
    let title: String
    let isAllGoals: Bool
    let goals: [Goal]
    @Binding var selectedGoalId: UUID?
    let onAdd: () -> Void

    @State private var searchText = ""
    @State private var statusFilter: GoalStatus? = nil

    var filtered: [Goal] {
        var list = goals
        if !searchText.isEmpty {
            list = list.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        if let status = statusFilter {
            list = list.filter { $0.status == status }
        }
        return list
    }

    var body: some View {
        Group {
            if goals.isEmpty {
                emptyState
            } else if filtered.isEmpty {
                filteredEmptyState
            } else {
                List(selection: $selectedGoalId) {
                    ForEach(filtered) { goal in
                        GoalRowView(goal: goal)
                            .tag(goal.id)
                            .contextMenu {
                                Button(role: .destructive) {
                                    if selectedGoalId == goal.id { selectedGoalId = nil }
                                    store.deleteGoal(goal)
                                } label: {
                                    Label("Delete Goal", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.inset)
            }
        }
        .searchable(text: $searchText, placement: .toolbar, prompt: "Search goals…")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                // Status filter menu
                Menu {
                    Button("All Statuses") { statusFilter = nil }
                    Divider()
                    ForEach(GoalStatus.allCases) { status in
                        Button {
                            statusFilter = status
                        } label: {
                            Label(status.rawValue, systemImage: status.systemImage)
                        }
                    }
                } label: {
                    Image(systemName: statusFilter == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                }
                .help("Filter by status")

                Button(action: onAdd) {
                    Label("Add Goal", systemImage: "plus")
                }
                .help("Add a new goal")
            }
        }
        .navigationTitle(navigationTitle)
    }

    private var navigationTitle: String {
        statusFilter.map { "\(title) · \($0.rawValue)" } ?? title
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "scope")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(.secondary)
            Text(isAllGoals ? "No Goals Yet" : "No Goals Here")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)
            Text(isAllGoals
                 ? "Tap + to add your first life goal."
                 : "Tap + to set your first goal for this category.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 220)
            Button("Add Goal", action: onAdd)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var filteredEmptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 40, weight: .ultraLight))
                .foregroundStyle(.secondary)
            Text("No Matching Goals")
                .font(.title3.weight(.semibold))
            Button("Clear Filters") {
                searchText = ""
                statusFilter = nil
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Goal Row

struct GoalRowView: View {
    @EnvironmentObject var store: GoalStore
    let goal: Goal

    var category: GoalCategory? { store.category(for: goal.categoryId) }

    var statusColor: Color {
        switch goal.status {
        case .notStarted: return .secondary
        case .inProgress: return .blue
        case .completed:  return .green
        case .paused:     return .orange
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Image(systemName: goal.status.systemImage)
                    .foregroundStyle(statusColor)
                    .font(.system(size: 13))
                Text(goal.title)
                    .font(.body.weight(.medium))
                    .lineLimit(2)
                Spacer()
            }

            HStack(spacing: 6) {
                // Category pill
                if let cat = category {
                    HStack(spacing: 4) {
                        Image(systemName: cat.icon)
                            .font(.caption2)
                        Text(cat.name)
                            .font(.caption2.weight(.medium))
                    }
                    .foregroundStyle(cat.swiftUIColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(cat.swiftUIColor.opacity(0.12), in: Capsule())
                }

                // Target date
                if let date = goal.targetDate {
                    HStack(spacing: 3) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text(date, style: .date)
                            .font(.caption2)
                    }
                    .foregroundStyle(date < Date() && goal.status != .completed ? .red : .secondary)
                }

                Spacer()

                // Notes count
                if !goal.notes.isEmpty {
                    HStack(spacing: 3) {
                        Image(systemName: "note.text")
                        Text("\(goal.notes.count)")
                    }
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
