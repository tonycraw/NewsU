import Foundation

/// The one line you need to edit to go from "demo with sample data" to
/// "real AI-curated news, updated daily." See backend/README.md for the full
/// setup (an Anthropic API key + pushing this project to GitHub is all it
/// takes — the scheduled workflow and hosting are already built).
enum RemoteConfig {
    /// Once your GitHub Actions workflow has run at least once, set this to
    /// your repo's raw URL for the generated brief, e.g.:
    ///
    ///   static let briefURL: URL? = URL(string:
    ///     "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/public/brief-latest.json"
    ///   )
    ///
    /// Leave it `nil` to keep using the bundled sample data — the app works
    /// fully either way.
    static let briefURL: URL? = nil
}
