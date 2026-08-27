import SwiftUI

/// The in-app echo of the Home Screen icon: bold "N" mark on dark navy with a
/// thin gold rule. Used on branding moments (Welcome, Sign In) so the app's
/// identity is consistent from the App Store icon through to first launch.
struct AppMarkBadge: View {
    var size: CGFloat = 84

    private var ruleWidth: CGFloat { size * 0.34 }
    private var ruleHeight: CGFloat { max(2, size * 0.018) }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                .fill(Color(hex: "12141C"))
            VStack(spacing: size * 0.08) {
                Text("N")
                    .font(.custom("HelveticaNeue-CondensedBlack", size: size * 0.5))
                    .foregroundStyle(Color(hex: "FAF8F4"))
                Rectangle()
                    .fill(NewsUTheme.gold)
                    .frame(width: ruleWidth, height: ruleHeight)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    AppMarkBadge()
        .padding()
        .background(NewsUTheme.background)
}
