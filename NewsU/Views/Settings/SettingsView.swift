import SwiftUI
import StoreKit

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var store: StoreKitManager
    @State private var notificationTime: Date = Date()
    @State private var showManageSubscriptions = false
    @State private var showSignOutConfirmation = false
    @State private var showDeleteAccountConfirmation = false
    @State private var isDeletingAccount = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    if let user = appState.currentUser {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.displayName)
                                .font(.newsUBody.weight(.semibold))
                            Text(user.email)
                                .font(.newsUCaption)
                                .foregroundStyle(NewsUTheme.inkFaint)
                        }
                        .padding(.vertical, 2)
                    }

                    HStack {
                        Text("Subscription")
                        Spacer()
                        Text(subscriptionStatusLabel)
                            .foregroundStyle(NewsUTheme.inkFaint)
                    }

                    Button("Manage Subscription") { showManageSubscriptions = true }

                    Button("Sign Out", role: .destructive) { showSignOutConfirmation = true }

                    Button("Delete Account", role: .destructive) {
                        showDeleteAccountConfirmation = true
                    }
                    .disabled(isDeletingAccount)
                }

                Section("My Topics") {
                    NavigationLink {
                        TopicManagementView()
                    } label: {
                        HStack {
                            Text("Subscribed Topics")
                            Spacer()
                            Text("\(appState.preferences.selectedTopicIDs.count) selected")
                                .foregroundStyle(NewsUTheme.inkFaint)
                        }
                    }
                }

                Section("Morning Reminder") {
                    Toggle("Daily reminder", isOn: Binding(
                        get: { appState.preferences.notificationsEnabled },
                        set: { appState.setNotificationsEnabled($0) }
                    ))

                    if appState.preferences.notificationsEnabled {
                        DatePicker("Reminder time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                            .onChange(of: notificationTime) { _, newValue in
                                let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                                appState.updateNotificationTime(hour: components.hour ?? 7, minute: components.minute ?? 0)
                            }
                    }
                }

                Section("About") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("NewsU exists to ground your day in prayer and Scripture before the noise of the news cycle. Every brief is gathered and written by AI, then paired with a verse chosen for what you're about to read.")
                            .font(.newsUCaption)
                            .foregroundStyle(NewsUTheme.inkSecondary)
                    }
                    .padding(.vertical, 4)

                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(NewsUTheme.inkFaint)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
            .confirmationDialog("Sign out of NewsU?", isPresented: $showSignOutConfirmation, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) { appState.signOut() }
                Button("Cancel", role: .cancel) {}
            }
            .confirmationDialog(
                "Delete your account?",
                isPresented: $showDeleteAccountConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Account", role: .destructive) {
                    isDeletingAccount = true
                    Task {
                        try? await appState.deleteAccount()
                        isDeletingAccount = false
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently deletes your account, topics, and prayer requests from this device. This can't be undone. Your subscription isn't cancelled automatically — manage that separately in Settings.")
            }
            .onAppear {
                notificationTime = Calendar.current.date(
                    from: DateComponents(hour: appState.preferences.notificationHour, minute: appState.preferences.notificationMinute)
                ) ?? Date()
            }
        }
    }

    private var subscriptionStatusLabel: String {
        if store.isSubscribed { return "NewsU Plus" }
        if appState.hasOwnerAccess { return "Owner access (debug)" }
        return "Not subscribed"
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .environmentObject(StoreKitManager())
}
