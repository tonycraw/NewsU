import SwiftUI

struct TopicPageView: View {
    let section: NewsSection
    @State private var selectedArticle: Article?

    var body: some View {
        ZStack {
            NewsUTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(section.articles.enumerated()), id: \.element.id) { index, article in
                            Button { selectedArticle = article } label: {
                                ArticleRowView(article: article)
                            }
                            .buttonStyle(.plain)

                            if index < section.articles.count - 1 {
                                Divider().background(NewsUTheme.divider)
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .newsUCard()

                    VerseCardView(verse: section.verse)
                }
                .padding(20)
            }
        }
        .navigationTitle(section.topic.name)
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedArticle) { article in
            ArticleDetailView(article: article, verse: section.verse)
        }
    }
}

#Preview {
    NavigationStack {
        TopicPageView(section: NewsSection(
            topicId: "world",
            articles: [
                Article(id: "1", headline: "Global Leaders Reach Framework on Cross-Border Data Rules", source: "Reuters", summary: "Negotiators from over 40 countries agreed on baseline privacy standards.", url: "https://example.com", publishedAt: Date(), trustNote: "Corroborated by 3 outlets"),
                Article(id: "2", headline: "Relief Efforts Expand After Regional Flooding", source: "AP", summary: "Aid groups report steady progress reaching affected communities this week.", url: "https://example.com", publishedAt: Date(), trustNote: "Primary source: AP wire")
            ],
            verse: Verse(reference: "Philippians 4:6-7", text: "Do not be anxious about anything.", reflection: "A reminder that peace isn't tied to headlines.")
        ))
    }
}
