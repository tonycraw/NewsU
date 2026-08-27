import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Today", systemImage: "sun.horizon.fill") }

            PrayerRequestsView()
                .tabItem { Label("Prayer", systemImage: "hands.sparkles.fill") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(NewsUTheme.gold)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
        .environmentObject(StoreKitManager())
}
