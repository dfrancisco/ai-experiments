import Foundation
import SwiftUI

// MARK: - GoalCategory

struct GoalCategory: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var icon: String
    var colorHex: String

    var swiftUIColor: Color {
        Color(hex: colorHex) ?? .accentColor
    }

    // MARK: Built-in defaults

    static let defaults: [GoalCategory] = [
        GoalCategory(name: "Health & Fitness",  icon: "heart.fill",              colorHex: "#FF6B6B"),
        GoalCategory(name: "Career & Work",     icon: "briefcase.fill",           colorHex: "#4ECDC4"),
        GoalCategory(name: "Learning",          icon: "book.fill",                colorHex: "#45B7D1"),
        GoalCategory(name: "Finance",           icon: "dollarsign.circle.fill",   colorHex: "#96CEB4"),
        GoalCategory(name: "Relationships",     icon: "person.2.fill",            colorHex: "#FFEAA7"),
        GoalCategory(name: "Personal Growth",   icon: "sparkles",                 colorHex: "#C9B1FF"),
        GoalCategory(name: "Travel",            icon: "airplane",                 colorHex: "#FFA07A"),
        GoalCategory(name: "Creativity",        icon: "paintbrush.fill",          colorHex: "#98D8C8"),
    ]
}

// MARK: - Color hex initializer

extension Color {
    init?(hex: String) {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        guard sanitized.count == 6 else { return nil }
        var rgb: UInt64 = 0
        guard Scanner(string: sanitized).scanHexInt64(&rgb) else { return nil }
        self.init(
            red:   Double((rgb & 0xFF0000) >> 16) / 255,
            green: Double((rgb & 0x00FF00) >> 8)  / 255,
            blue:  Double( rgb & 0x0000FF)         / 255
        )
    }
}
