import SwiftUI

struct AddEditGoalView: View {
    @EnvironmentObject var store: GoalStore
    @Environment(\.dismiss) private var dismiss

    // Pass an existing goal to edit, or nil to create
    var editingGoal: Goal?
    var initialCategoryId: UUID?

    @State private var title = ""
    @State private var selectedCategoryId: UUID?
    @State private var status: GoalStatus = .notStarted
    @State private var hasTargetDate = false
    @State private var targetDate = Date().addingTimeInterval(60 * 60 * 24 * 30) // 30 days
    @State private var initialNote = ""

    private var isEditing: Bool { editingGoal != nil }
    private var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            // ── Sheet header ──────────────────────────────────────
            HStack {
                Text(isEditing ? "Edit Goal" : "New Goal")
                    .font(.headline)
                Spacer()
                Button("Cancel") { dismiss() }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .keyboardShortcut(.escape, modifiers: [])
            }
            .padding(20)

            Divider()

            // ── Form ──────────────────────────────────────────────
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {

                    // Title
                    formSection(label: "Goal", icon: "scope") {
                        TextField("What do you want to achieve?", text: $title, axis: .vertical)
                            .font(.body)
                            .lineLimit(1...4)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Category
                    formSection(label: "Category", icon: "tag.fill") {
                        Picker("Category", selection: $selectedCategoryId) {
                            Text("None").tag(UUID?.none)
                            Divider()
                            ForEach(store.categories) { cat in
                                HStack {
                                    Image(systemName: cat.icon)
                                    Text(cat.name)
                                }
                                .tag(Optional(cat.id))
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Status
                    formSection(label: "Status", icon: "circle.dotted") {
                        Picker("Status", selection: $status) {
                            ForEach(GoalStatus.allCases) { s in
                                Label(s.rawValue, systemImage: s.systemImage).tag(s)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Target date
                    formSection(label: "Target Date", icon: "calendar") {
                        Toggle("Set a target date", isOn: $hasTargetDate.animation())
                            .toggleStyle(.switch)
                        if hasTargetDate {
                            DatePicker("Target", selection: $targetDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }

                    // Initial note (only when creating)
                    if !isEditing {
                        formSection(label: "First Progress Note (optional)", icon: "note.text") {
                            TextEditor(text: $initialNote)
                                .font(.body)
                                .frame(minHeight: 72, maxHeight: 120)
                                .padding(8)
                                .background(Color(.controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(20)
            }

            Divider()

            // ── Footer ────────────────────────────────────────────
            HStack {
                if isEditing {
                    Button(role: .destructive) {
                        store.deleteGoal(editingGoal!)
                        dismiss()
                    } label: {
                        Label("Delete Goal", systemImage: "trash")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.red)
                }
                Spacer()
                Button(isEditing ? "Save Changes" : "Add Goal") {
                    save()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canSave)
                .keyboardShortcut(.return, modifiers: .command)
            }
            .padding(20)
        }
        .frame(width: 460)
        .onAppear(perform: populateIfEditing)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func formSection<Content: View>(label: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            content()
        }
    }

    private func populateIfEditing() {
        if let goal = editingGoal {
            title               = goal.title
            selectedCategoryId  = goal.categoryId
            status              = goal.status
            hasTargetDate       = goal.targetDate != nil
            targetDate          = goal.targetDate ?? Date().addingTimeInterval(60 * 60 * 24 * 30)
        } else {
            selectedCategoryId = initialCategoryId
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }

        if var existing = editingGoal {
            existing.title          = trimmedTitle
            existing.categoryId     = selectedCategoryId
            existing.status         = status
            existing.targetDate     = hasTargetDate ? targetDate : nil
            store.updateGoal(existing)
        } else {
            var newGoal = Goal(title: trimmedTitle)
            newGoal.categoryId  = selectedCategoryId
            newGoal.status      = status
            newGoal.targetDate  = hasTargetDate ? targetDate : nil
            store.addGoal(newGoal)

            // Add initial note if provided
            let noteText = initialNote.trimmingCharacters(in: .whitespacesAndNewlines)
            if !noteText.isEmpty {
                store.addNote(ProgressNote(content: noteText), to: newGoal)
            }
        }
        dismiss()
    }
}
