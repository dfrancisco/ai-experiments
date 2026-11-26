import SwiftUI

@main
struct LifeGoalsApp: App {
    @StateObject private var store = GoalStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .commands {
            CommandGroup(replacing: .newItem) { }   // remove default "New" shortcut
        }
    }
}
