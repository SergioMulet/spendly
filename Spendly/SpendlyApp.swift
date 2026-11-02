import SwiftUI
import SwiftData

@main struct MyApp: App {
    @AppStorage("language") private var language = Language.deviceDefault
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.locale, language.locale)
        }
        .modelContainer(AppModelContainer.shared)
    }
}
