import SwiftUI

struct NotificationSetupView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTime = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
    @State private var isRequesting = false

    var body: some View {
        ZStack {
            NewsUTheme.background.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(NewsUTheme.gold.opacity(0.18))
                        .frame(width: 132, height: 132)
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(NewsUTheme.gold)
                }

                VStack(spacing: 10) {
                    Text("One gentle reminder")
                        .font(.newsUTitle)
                        .foregroundStyle(NewsUTheme.ink)
                    Text("NewsU will nudge you once each morning to open your brief. No breaking-news pings, no noise.")
                        .font(.newsUBody)
                        .foregroundStyle(NewsUTheme.inkSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                DatePicker("Reminder time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxHeight: 160)
                    .newsUCard()
                    .padding(.horizontal, 40)

                Spacer()
                Spacer()

                VStack(spacing: 14) {
                    PrimaryButton(title: isRequesting ? "Setting up…" : "Enable & Finish") {
                        finish(enableNotifications: true)
                    }
                    SecondaryLinkButton(title: "Not now") {
                        finish(enableNotifications: false)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isRequesting)
    }

    private func finish(enableNotifications: Bool) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
        appState.preferences.notificationHour = components.hour ?? 7
        appState.preferences.notificationMinute = components.minute ?? 0

        guard enableNotifications else {
            appState.preferences.notificationsEnabled = false
            appState.completeOnboarding()
            return
        }

        isRequesting = true
        Task {
            let granted = await NotificationManager.shared.requestAuthorization()
            appState.preferences.notificationsEnabled = granted
            appState.completeOnboarding()
            isRequesting = false
        }
    }
}

#Preview {
    NavigationStack { NotificationSetupView() }
        .environmentObject(AppState())
}
