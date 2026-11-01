import SwiftUI
import SwiftData

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(AppModelContainer.shared)
    }
}
