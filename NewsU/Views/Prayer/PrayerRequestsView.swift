import SwiftUI

struct PrayerRequestsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showNewRequest = false

    var body: some View {
        NavigationStack {
            ZStack {
                NewsUTheme.background.ignoresSafeArea()

                if appState.isLoadingPrayerRequests && appState.prayerRequests.isEmpty {
                    ProgressView()
                } else if appState.prayerRequests.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Prayer Requests")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showNewRequest = true } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showNewRequest) { NewPrayerRequestView() }
            .task { await appState.loadPrayerRequests() }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "hands.sparkles.fill")
                .font(.system(size: 44))
                .foregroundStyle(NewsUTheme.gold)
            Text("Nothing on your heart yet")
                .font(.newsUHeadline)
                .foregroundStyle(NewsUTheme.ink)
            Text("Jot down what you're carrying today — big or small — and come back to it in prayer.")
                .font(.newsUBody)
                .foregroundStyle(NewsUTheme.inkSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            PrimaryButton(title: "Add a Prayer Request") { showNewRequest = true }
                .padding(.horizontal, 60)
                .padding(.top, 8)
        }
    }

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(appState.prayerRequests) { request in
                    PrayerRequestCard(request: request)
                }
            }
            .padding(20)
        }
    }
}

private struct PrayerRequestCard: View {
    @EnvironmentObject var appState: AppState
    let request: PrayerRequest

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(request.category.label, systemImage: request.category.sfSymbol)
                    .font(.newsUCaption.weight(.semibold))
                    .foregroundStyle(NewsUTheme.gold)
                Spacer()
                Text(request.createdAt, style: .date)
                    .font(.newsUCaption)
                    .foregroundStyle(NewsUTheme.inkFaint)
            }

            Text(request.text)
                .font(.newsUBody)
                .foregroundStyle(NewsUTheme.ink)
                .strikethrough(request.isAnswered)
                .opacity(request.isAnswered ? 0.6 : 1)

            Button {
                Task { await appState.toggleAnswered(request) }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: request.isAnswered ? "checkmark.circle.fill" : "circle")
                    Text(request.isAnswered ? "Answered" : "Mark as answered")
                }
                .font(.newsUCaption.weight(.medium))
                .foregroundStyle(request.isAnswered ? NewsUTheme.gold : NewsUTheme.inkSecondary)
            }
        }
        .padding(16)
        .newsUCard()
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                Task { await appState.deletePrayerRequest(request) }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    PrayerRequestsView().environmentObject(AppState())
}
