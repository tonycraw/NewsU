import SwiftUI

// MARK: - Hex + adaptive color helpers

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }

    static func adaptive(light: String, dark: String) -> Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(Color(hex: dark)) : UIColor(Color(hex: light))
        })
    }
}

/// NewsU's visual language: a quiet, devotional calm — warm parchment light mode,
/// deep dusk navy dark mode, a single muted gold accent used sparingly.
enum NewsUTheme {

    // MARK: Core palette
    static let background = Color.adaptive(light: "FBF7EF", dark: "10121C")
    static let surface = Color.adaptive(light: "FFFFFF", dark: "1B1E2C")
    static let surfaceRaised = Color.adaptive(light: "FFFDF8", dark: "232739")

    static let ink = Color.adaptive(light: "2A2620", dark: "F3EFE6")
    static let inkSecondary = Color.adaptive(light: "6B6357", dark: "A9A398")
    static let inkFaint = Color.adaptive(light: "9A917F", dark: "6F6A60")

    static let gold = Color.adaptive(light: "B9893C", dark: "D9AE66")
    static let divider = Color.adaptive(light: "E7DFCE", dark: "2C3040")

    // MARK: Gradients
    /// The dawn gradient behind the morning prayer card — first light, not sunset.
    static let dawnGradient = LinearGradient(
        colors: [Color(hex: "F6E3C5"), Color(hex: "F2C9B0"), Color(hex: "CFE0E8")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let dawnGradientDark = LinearGradient(
        colors: [Color(hex: "2C2A3D"), Color(hex: "3A2E3D"), Color(hex: "23324A")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    /// The verse card background — deep, still, a little more formal than the news cards.
    static let verseGradient = LinearGradient(
        colors: [Color(hex: "2E2A4A"), Color(hex: "463659")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static func dawn(for scheme: ColorScheme) -> LinearGradient {
        scheme == .dark ? dawnGradientDark : dawnGradient
    }

    // MARK: Radii & shadow
    static let cardRadius: CGFloat = 22
    static let cardShadow = Color.black.opacity(0.08)
}

// MARK: - Typography

extension Font {
    /// Large serif display, used once per screen for the marquee headline.
    static let newsUDisplay = Font.system(.largeTitle, design: .serif).weight(.semibold)
    static let newsUTitle = Font.system(.title2, design: .serif).weight(.semibold)
    static let newsUHeadline = Font.system(.headline, design: .serif).weight(.semibold)
    static let newsUBody = Font.system(.body, design: .default)
    static let newsUCaption = Font.system(.footnote, design: .default)
    static let newsUVerse = Font.system(.title3, design: .serif).italic()

    /// The "NewsU" wordmark specifically — bold Helvetica, tight tracking, a
    /// masthead feel. Deliberately distinct from the serif devotional type
    /// used everywhere else (prayers, verses, headlines): this is the one
    /// place the app should read as a *news* brand first.
    static func newsUWordmark(_ size: CGFloat) -> Font {
        .custom("HelveticaNeue-Bold", size: size)
    }
}

// MARK: - Reusable modifiers

struct CardBackground: ViewModifier {
    var color: Color = NewsUTheme.surface
    func body(content: Content) -> some View {
        content
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: NewsUTheme.cardRadius, style: .continuous))
            .shadow(color: NewsUTheme.cardShadow, radius: 14, x: 0, y: 6)
    }
}

extension View {
    func newsUCard(_ color: Color = NewsUTheme.surface) -> some View {
        modifier(CardBackground(color: color))
    }
}
