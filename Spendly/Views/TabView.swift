import SwiftUI

enum AppTab {
    case home, settings
}

struct MainTabView: View {
    @State private var selection: AppTab = .home
    
    var body: some View {
        TabView(selection: $selection) {
            Tab("Home", systemImage: "house.fill", value: AppTab.home) {
                HomeView()
            }
            Tab("Settings", systemImage: "gearshape.fill", value: AppTab.settings) {
                SettingsView()
            }
        }
    }
}
