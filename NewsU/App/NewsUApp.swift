import SwiftUI

@main
struct NewsUApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var store = StoreKitManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(store)
        }
    }
}

/// Gates the app in order: sign in/up, then an active subscription, then
/// one-time onboarding, before landing on the real app. Each stage owns a
/// hard requirement — no piece of app content should be reachable without
/// satisfying the ones before it.
struct RootView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var store: StoreKitManager

    var body: some View {
        Group {
            if appState.currentUser == nil {
                AuthView()
            } else if !store.isSubscribed && !appState.hasOwnerAccess {
                SubscriptionPaywallView()
            } else if !appState.preferences.hasCompletedOnboarding {
                OnboardingWelcomeView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut, value: appState.currentUser)
        .animation(.easeInOut, value: store.isSubscribed)
        .animation(.easeInOut, value: appState.preferences.hasCompletedOnboarding)
    }
}
