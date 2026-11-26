import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var store: GoalStore
    @Binding var selection: SidebarSelection?
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""

    var body: some View {
        List(selection: $selection) {
            // All Goals
            Section {
                Label("All Goals", systemImage: "tray.full.fill")
                    .tag(SidebarSelection.all)
                    .badge(store.goals.count)
            }

            // Categories
            Section {
                ForEach(store.categories) { category in
                    HStack(spacing: 10) {
                        Image(systemName: category.icon)
                            .foregroundStyle(category.swiftUIColor)
                            .frame(width: 18)
                        Text(category.name)
                        Spacer()
                        Text("\(store.goalCount(for: category.id))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    .tag(SidebarSelection.category(category.id))
                    .contextMenu {
                        Button(role: .destructive) {
                            store.deleteCategory(category)
                            if selection == .category(category.id) {
                                selection = .all
                            }
                        } label: {
                            Label("Delete "\(category.name)"", systemImage: "trash")
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Categories")
                    Spacer()
                    Button { showingAddCategory = true } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Life Goals")
        .sheet(isPresented: $showingAddCategory) {
            AddCategorySheet(isPresented: $showingAddCategory)
        }
    }
}

// MARK: - Add Category Sheet

struct AddCategorySheet: View {
    @EnvironmentObject var store: GoalStore
    @Binding var isPresented: Bool
    @State private var name = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedColor = "#6C63FF"

    private let icons = [
        "star.fill", "flame.fill", "bolt.fill", "leaf.fill", "moon.fill",
        "sun.max.fill", "cloud.fill", "drop.fill", "snowflake", "wind",
        "figure.run", "dumbbell.fill", "brain.head.profile", "music.note",
        "gamecontroller.fill", "camera.fill", "building.2.fill", "tree.fill"
    ]
    private let colors = [
        "#FF6B6B", "#FF8E53", "#FFA07A", "#FFEAA7", "#96CEB4",
        "#4ECDC4", "#45B7D1", "#6C63FF", "#C9B1FF", "#FF6BB5",
        "#98D8C8", "#F7DC6F"
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("New Category")
                    .font(.headline)
                Spacer()
                Button("Cancel") { isPresented = false }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Name
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Name", systemImage: "textformat")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("e.g. Side Projects", text: $name)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Color
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Color", systemImage: "paintpalette")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                            ForEach(colors, id: \.self) { hex in
                                Circle()
                                    .fill(Color(hex: hex) ?? .accentColor)
                                    .frame(width: 28, height: 28)
                                    .overlay {
                                        if selectedColor == hex {
                                            Image(systemName: "checkmark")
                                                .font(.caption2.bold())
                                                .foregroundStyle(.white)
                                        }
                                    }
                                    .onTapGesture { selectedColor = hex }
                            }
                        }
                    }

                    // Icon
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Icon", systemImage: "square.grid.2x2")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                            ForEach(icons, id: \.self) { icon in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(selectedIcon == icon
                                              ? (Color(hex: selectedColor) ?? .accentColor).opacity(0.2)
                                              : Color(.windowBackgroundColor).opacity(0.6))
                                    Image(systemName: icon)
                                        .foregroundStyle(selectedIcon == icon
                                                         ? Color(hex: selectedColor) ?? .accentColor
                                                         : .secondary)
                                }
                                .frame(width: 36, height: 36)
                                .onTapGesture { selectedIcon = icon }
                            }
                        }
                    }
                }
                .padding()
            }

            Divider()

            // Footer
            HStack {
                Spacer()
                Button("Add Category") {
                    guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    store.addCategory(GoalCategory(name: name, icon: selectedIcon, colorHex: selectedColor))
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
        .frame(width: 340, height: 460)
    }
}
