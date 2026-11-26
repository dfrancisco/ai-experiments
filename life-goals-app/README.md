# Life Goals Mac App

A native macOS app to track your personal goals, organized by category, with timestamped progress notes.

Built with **SwiftUI** · **macOS 13+** · **Local JSON storage**

## Features

- 🎯 **Goals** — title, category, status, and optional target date
- 🗂 **Categories** — 8 built-in defaults, fully customizable (name, icon, color)
- 📓 **Progress Journal** — timestamped notes per goal, with a clean timeline UI
- 🔍 **Search & Filter** — find goals by name or filter by status
- 💾 **Fully local** — all data stored in `~/Library/Application Support/LifeGoals/`

## Getting Started

```bash
open life-goals-app/LifeGoals.xcodeproj
```

Then press **⌘R** to run.

> **Requirements:** Xcode 15+, macOS 13 Ventura or later.

## Project Structure

```
LifeGoals/
├── Models/
│   ├── Goal.swift           # Goal, GoalStatus, ProgressNote
│   └── GoalCategory.swift   # Category + built-in defaults
├── Store/
│   └── GoalStore.swift      # JSON persistence & CRUD
├── Views/
│   ├── SidebarView.swift    # Category sidebar
│   ├── GoalListView.swift   # Filterable goal list
│   ├── GoalDetailView.swift # Notes timeline + editing
│   └── AddEditGoalView.swift # Create / edit sheet
├── ContentView.swift        # Three-column NavigationSplitView
└── LifeGoalsApp.swift       # @main entry point
```

## Data Storage

User data is stored **only** on your local machine at:

```
~/Library/Application Support/LifeGoals/
├── goals.json
└── categories.json
```

No data is synced to the cloud or included in this repository.

## Privacy

This repository contains **no personal data**. The `.gitignore` excludes all Xcode-generated artifacts and no user data files are ever stored inside the project directory.
