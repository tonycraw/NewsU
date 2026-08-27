import SwiftUI

struct ArticleRowView: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.headline)
                .font(.newsUHeadline)
                .foregroundStyle(NewsUTheme.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text(article.summary)
                .font(.newsUBody)
                .foregroundStyle(NewsUTheme.inkSecondary)
                .lineSpacing(3)

            HStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.caption2)
                    .foregroundStyle(NewsUTheme.gold)
                Text(article.source)
                    .font(.newsUCaption.weight(.semibold))
                Text("·")
                Text(article.trustNote)
                    .font(.newsUCaption)
                Spacer()
                Text(article.publishedAt, style: .relative)
                    .font(.newsUCaption)
            }
            .foregroundStyle(NewsUTheme.inkFaint)
        }
        .padding(.vertical, 14)
    }
}

#Preview {
    ArticleRowView(article: Article(
        id: "1",
        headline: "Global Leaders Reach Framework on Cross-Border Data Rules",
        source: "Reuters",
        summary: "Negotiators from over 40 countries agreed on a baseline framework for data privacy standards, a step observers say could reduce friction for smaller economies.",
        url: "https://example.com",
        publishedAt: Date(),
        trustNote: "Corroborated by 3 outlets"
    ))
    .padding()
    .background(NewsUTheme.background)
}
