import SwiftUI

struct GoalDetailView: View {
    @EnvironmentObject var store: GoalStore
    let goal: Goal

    // Live version from store (stays updated after edits)
    var liveGoal: Goal { store.goals.first { $0.id == goal.id } ?? goal }

    @State private var showingEdit = false
    @State private var newNoteText = ""
    @State private var isAddingNote = false
    @FocusState private var noteFieldFocused: Bool

    private var statusColor: Color {
        switch liveGoal.status {
        case .notStarted: return .secondary
        case .inProgress: return .blue
        case .completed:  return .green
        case .paused:     return .orange
        }
    }

    private var category: GoalCategory? {
        store.category(for: liveGoal.categoryId)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // ── Header ────────────────────────────────────────
                VStack(alignment: .leading, spacing: 12) {
                    Text(liveGoal.title)
                        .font(.largeTitle.weight(.bold))
                        .textSelection(.enabled)

                    // Meta pills
                    HStack(spacing: 8) {
                        // Status badge
                        HStack(spacing: 5) {
                            Image(systemName: liveGoal.status.systemImage)
                            Text(liveGoal.status.rawValue)
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(statusColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(statusColor.opacity(0.12), in: Capsule())

                        // Category badge
                        if let cat = category {
                            HStack(spacing: 5) {
                                Image(systemName: cat.icon)
                                Text(cat.name)
                            }
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(cat.swiftUIColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(cat.swiftUIColor.opacity(0.12), in: Capsule())
                        }

                        // Target date
                        if let date = liveGoal.targetDate {
                            HStack(spacing: 5) {
                                Image(systemName: "calendar")
                                Text(date, style: .date)
                            }
                            .font(.subheadline)
                            .foregroundStyle(date < Date() && liveGoal.status != .completed ? .red : .secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.secondary.opacity(0.08), in: Capsule())
                        }

                        Spacer()
                    }

                    // Created / updated
                    HStack(spacing: 16) {
                        Label {
                            Text("Created ") + Text(liveGoal.createdAt, style: .date)
                        } icon: {
                            Image(systemName: "clock")
                        }
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                        if liveGoal.updatedAt > liveGoal.createdAt {
                            Label {
                                Text("Updated ") + Text(liveGoal.updatedAt, style: .relative) + Text(" ago")
                            } icon: {
                                Image(systemName: "arrow.clockwise")
                            }
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        }
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                // ── Progress Journal ──────────────────────────────
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Progress Journal")
                            .font(.title3.weight(.semibold))
                        Text("\(liveGoal.notes.count)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(.secondary, in: Capsule())
                        Spacer()
                        Button {
                            isAddingNote = true
                            noteFieldFocused = true
                        } label: {
                            Label("Add Note", systemImage: "plus.circle.fill")
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(Color.accentColor)
                    }

                    // Add Note inline editor
                    if isAddingNote {
                        VStack(spacing: 10) {
                            TextEditor(text: $newNoteText)
                                .font(.body)
                                .frame(minHeight: 80, maxHeight: 160)
                                .padding(8)
                                .background(Color(.textBackgroundColor), in: RoundedRectangle(cornerRadius: 10))
                                .focused($noteFieldFocused)
                                .onSubmit { submitNote() }

                            HStack {
                                Button("Cancel") {
                                    newNoteText = ""
                                    isAddingNote = false
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(.secondary)
                                Spacer()
                                Button("Save Note") { submitNote() }
                                    .buttonStyle(.borderedProminent)
                                    .disabled(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                        }
                        .padding(14)
                        .background(Color(.controlBackgroundColor), in: RoundedRectangle(cornerRadius: 12))
                        .transition(.asymmetric(
                            insertion: .push(from: .top).combined(with: .opacity),
                            removal: .push(from: .bottom).combined(with: .opacity)
                        ))
                    }

                    // Notes timeline
                    if liveGoal.notes.isEmpty && !isAddingNote {
                        VStack(spacing: 10) {
                            Image(systemName: "text.badge.plus")
                                .font(.system(size: 32, weight: .ultraLight))
                                .foregroundStyle(.tertiary)
                            Text("No notes yet")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                            Text("Track your progress by adding journal entries.")
                                .font(.caption)
                                .foregroundStyle(.quaternary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(liveGoal.notes) { note in
                                NoteRowView(note: note) {
                                    withAnimation {
                                        store.deleteNote(note, from: liveGoal)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(24)
                .animation(.spring(response: 0.3), value: isAddingNote)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingEdit = true
                } label: {
                    Label("Edit Goal", systemImage: "pencil")
                }
                .help("Edit this goal")
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddEditGoalView(editingGoal: liveGoal)
        }
    }

    private func submitNote() {
        let trimmed = newNoteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        withAnimation {
            store.addNote(ProgressNote(content: trimmed), to: liveGoal)
            newNoteText = ""
            isAddingNote = false
        }
    }
}

// MARK: - Note Row

struct NoteRowView: View {
    let note: ProgressNote
    let onDelete: () -> Void
    @State private var isHovering = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline dot
            VStack(spacing: 0) {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)
                Rectangle()
                    .fill(.quaternary)
                    .frame(width: 1)
            }
            .frame(width: 8)

            // Content card
            VStack(alignment: .leading, spacing: 6) {
                // Timestamp
                HStack(spacing: 4) {
                    Text(note.createdAt, style: .date)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.tertiary)
                    Text("·")
                        .font(.caption2)
                        .foregroundStyle(.quaternary)
                    Text(note.createdAt, style: .time)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                // Note text
                Text(note.content)
                    .font(.body)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(.controlBackgroundColor), in: RoundedRectangle(cornerRadius: 10))
            .overlay(alignment: .topTrailing) {
                if isHovering {
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(6)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .onHover { isHovering = $0 }
        }
    }
}
