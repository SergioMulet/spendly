import AppIntents

/// The phrases Siri listens for. Every phrase must contain the app name; the Spanish ones live in AppShortcuts.xcstrings.
struct SpendlyShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddExpenseIntent(),
            phrases: [
                "Add an expense in \(.applicationName)",
                "Add a \(\.$category) expense in \(.applicationName)",
                "Register a new \(\.$category) expense in \(.applicationName)",
                "Create a new \(\.$category) expense in \(.applicationName)"
            ],
            shortTitle: "Add expense",
            systemImageName: "plus.circle"
        )
    }
}
