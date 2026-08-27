import SwiftUI

struct TopicGridCard: View {
    let section: NewsSection

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(section.topic.color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: section.topic.sfSymbol)
                        .foregroundStyle(section.topic.color)
                }
                Spacer()
                Text("\(section.articles.count)")
                    .font(.newsUCaption.weight(.semibold))
                    .foregroundStyle(NewsUTheme.inkFaint)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(section.topic.name)
                    .font(.newsUHeadline)
                    .foregroundStyle(NewsUTheme.ink)
                    .lineLimit(1)
                Text(section.articles.first?.headline ?? "")
                    .font(.newsUCaption)
                    .foregroundStyle(NewsUTheme.inkSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            HStack(spacing: 4) {
                Image(systemName: "book.closed.fill")
                    .font(.caption2)
                Text("Verse inside")
                    .font(.caption2.weight(.medium))
            }
            .foregroundStyle(NewsUTheme.gold)
        }
        .padding(16)
        .frame(height: 152, alignment: .topLeading)
        .frame(maxWidth: .infinity)
        .newsUCard()
    }
}

#Preview {
    TopicGridCard(section: NewsSection(
        topicId: "world",
        articles: [
            Article(id: "1", headline: "Global Leaders Reach Framework on Cross-Border Data Rules", source: "Reuters", summary: "…", url: "https://example.com", publishedAt: Date(), trustNote: "Corroborated by 3 outlets")
        ],
        verse: Verse(reference: "Philippians 4:6-7", text: "…", reflection: "…")
    ))
    .padding()
    .background(NewsUTheme.background)
}
