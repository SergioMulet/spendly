import SwiftUI
import SwiftData

@main struct MyApp: App {
    @AppStorage("language") private var language = Language.deviceDefault
    @State private var lock = AppLockViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.locale, language.locale)
                .overlay {
                    if lock.isLocked {
                        LockView { Task { await lock.unlock() } }
                    }
                }
                .task { await lock.unlock() }
                .onChange(of: scenePhase) { _, phase in
                    switch phase {
                    case .background: lock.appDidEnterBackground()
                    case .active: Task { await lock.unlock() }
                    default: break
                    }
                }
        }
        .modelContainer(AppModelContainer.shared)
    }
}
