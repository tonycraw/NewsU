import SwiftUI

struct VerseCardView: View {
    let verse: Verse

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "book.closed.fill")
                Text("A Verse For This")
                    .font(.newsUCaption.weight(.semibold))
                    .tracking(1.2)
                    .textCase(.uppercase)
            }
            .foregroundStyle(NewsUTheme.gold)

            Text("\u{201C}\(verse.text)\u{201D}")
                .font(.newsUVerse)
                .foregroundStyle(.white)
                .lineSpacing(4)

            Text(verse.reference)
                .font(.newsUBody.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))

            Divider().background(.white.opacity(0.2))

            Text(verse.reflection)
                .font(.newsUCaption)
                .foregroundStyle(.white.opacity(0.8))
                .lineSpacing(3)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NewsUTheme.verseGradient)
        .clipShape(RoundedRectangle(cornerRadius: NewsUTheme.cardRadius, style: .continuous))
        .shadow(color: NewsUTheme.cardShadow, radius: 12, x: 0, y: 6)
    }
}

#Preview {
    VerseCardView(verse: Verse(
        reference: "Philippians 4:6-7",
        text: "Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.",
        reflection: "Reflection: Today's economic headlines can feel unsettling — this verse is a reminder that peace isn't tied to the markets."
    ))
    .padding()
    .background(NewsUTheme.background)
}
