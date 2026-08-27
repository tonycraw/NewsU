import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    let verse: Verse
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(NewsUTheme.gold)
                        Text(article.source)
                            .font(.newsUCaption.weight(.semibold))
                        Text("·")
                        Text(article.trustNote)
                            .font(.newsUCaption)
                    }
                    .foregroundStyle(NewsUTheme.inkFaint)

                    Text(article.headline)
                        .font(.newsUDisplay)
                        .foregroundStyle(NewsUTheme.ink)

                    Text(article.summary)
                        .font(.newsUBody)
                        .foregroundStyle(NewsUTheme.ink)
                        .lineSpacing(6)

                    Text("AI-curated summary. Read the full story at the original source below.")
                        .font(.newsUCaption)
                        .foregroundStyle(NewsUTheme.inkFaint)

                    if let url = URL(string: article.url) {
                        Button {
                            openURL(url)
                        } label: {
                            HStack {
                                Text("Read Full Story")
                                Image(systemName: "arrow.up.right")
                            }
                            .font(.newsUBody.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .foregroundStyle(.white)
                            .background(NewsUTheme.ink)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }

                    VerseCardView(verse: verse)
                        .padding(.top, 6)
                }
                .padding(24)
            }
            .background(NewsUTheme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .topBarLeading) {
                    ShareLink(item: URL(string: article.url) ?? URL(string: "https://newsu.app")!) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

#Preview {
    ArticleDetailView(
        article: Article(id: "1", headline: "Global Leaders Reach Framework on Cross-Border Data Rules", source: "Reuters", summary: "Negotiators from over 40 countries agreed on baseline privacy standards, a step observers say could reduce friction for smaller economies over the next several years.", url: "https://example.com", publishedAt: Date(), trustNote: "Corroborated by 3 outlets"),
        verse: Verse(reference: "Proverbs 3:5-6", text: "Trust in the LORD with all your heart.", reflection: "A reminder to trust beyond what we can see in any single negotiation.")
    )
}
