import SwiftUI

struct PrayerCardView: View {
    let prayer: Prayer
    @Environment(\.colorScheme) private var colorScheme
    @State private var hasPrayed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "hands.sparkles.fill")
                    .font(.title3)
                Text("Today's Prayer")
                    .font(.newsUCaption.weight(.semibold))
                    .tracking(1.2)
                    .textCase(.uppercase)
                Spacer()
            }
            .foregroundStyle(.white.opacity(0.9))

            Text(prayer.title)
                .font(.newsUTitle)
                .foregroundStyle(.white)

            Text(prayer.body)
                .font(.newsUBody)
                .foregroundStyle(.white.opacity(0.95))
                .lineSpacing(5)

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) { hasPrayed.toggle() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: hasPrayed ? "checkmark.circle.fill" : "circle")
                    Text(hasPrayed ? "Amen" : "Mark as prayed")
                }
                .font(.newsUBody.weight(.medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.white.opacity(0.18))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NewsUTheme.dawn(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: NewsUTheme.cardRadius, style: .continuous))
        .shadow(color: NewsUTheme.cardShadow, radius: 16, x: 0, y: 8)
    }
}

#Preview {
    PrayerCardView(prayer: Prayer(
        title: "A Steady Heart",
        body: "Lord, before I read a single headline today, settle my heart in Your peace. Whatever the news holds, remind me that You are already there, already at work, already good. Amen."
    ))
    .padding()
    .background(NewsUTheme.background)
}
