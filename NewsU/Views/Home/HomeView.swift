import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NewsUTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header

                        if appState.isLoadingBrief && appState.brief == nil {
                            loadingState
                        } else if let brief = appState.brief {
                            PrayerCardView(prayer: brief.openingPrayer)

                            VStack(alignment: .leading, spacing: 14) {
                                Text("Your Topics")
                                    .font(.newsUTitle)
                                    .foregroundStyle(NewsUTheme.ink)

                                LazyVGrid(columns: columns, spacing: 14) {
                                    ForEach(brief.sections) { section in
                                        NavigationLink {
                                            TopicPageView(section: section)
                                        } label: {
                                            TopicGridCard(section: section)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }

                            closingBlessing(brief.closingBlessing)
                        } else if let error = appState.loadError {
                            errorState(error)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
                .refreshable { await appState.loadTodaysBrief() }
            }
            .task {
                if appState.brief == nil { await appState.loadTodaysBrief() }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(dateString.uppercased())
                .font(.newsUCaption.weight(.semibold))
                .tracking(1.4)
                .foregroundStyle(NewsUTheme.inkFaint)
            Text(appState.brief?.greeting ?? "Good morning")
                .font(.newsUDisplay)
                .foregroundStyle(NewsUTheme.ink)
        }
        .padding(.top, 8)
    }

    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Gathering today's brief…")
                .font(.newsUBody)
                .foregroundStyle(NewsUTheme.inkSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "cloud.moon.fill")
                .font(.largeTitle)
                .foregroundStyle(NewsUTheme.inkFaint)
            Text(message)
                .font(.newsUBody)
                .foregroundStyle(NewsUTheme.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private func closingBlessing(_ text: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles")
                .foregroundStyle(NewsUTheme.gold)
            Text(text)
                .font(.newsUVerse)
                .foregroundStyle(NewsUTheme.ink)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 12)
    }
}

#Preview {
    HomeView().environmentObject(AppState())
}
