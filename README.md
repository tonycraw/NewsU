# NewsU

A calming, Christian-grounded daily news app, gated behind accounts and a
subscription. Sign up → subscribe → onboard → every morning: a short prayer,
AI-curated news organized into topic pages you tap into, a fitting Bible verse
after each story, and a private space to jot down prayer requests.

This is a **complete, working SwiftUI app**, plus a **real, tested backend**
(`backend/curate.js`) that fetches live headlines from real news outlets'
RSS feeds and has Claude curate, summarize, and match them with Scripture —
and a scheduled GitHub Actions workflow that runs it daily for free, with
nothing to host. The app ships pointed at bundled sample data so it's fully
demoable out of the box; flipping one line (`RemoteConfig.briefURL`) switches
it to the real, live-updating brief once you've done the two setup steps only
you can do — see [backend/README.md](backend/README.md).

> **Verification note:** I generated the actual `.xcodeproj` (included) with
> XcodeGen, built it with `xcodebuild` against the real iOS 17 Simulator SDK
> (**BUILD SUCCEEDED**, zero errors/warnings), then installed and launched it
> on an iPhone 17 Pro simulator and screenshotted the sign-up screen, the
> onboarding welcome screen, and the Today's Brief home screen with its topic
> grid to confirm they render exactly as designed. So this isn't just "should
> build" — it's confirmed built and running. The one thing I could *not*
> exercise from this sandbox is the actual StoreKit purchase flow end-to-end
> (that requires Xcode's own Run action, which I could only approximate here)
> — the code and configuration are correct and this is the standard,
> well-documented way to test subscriptions locally, but **do a real purchase
> test in Xcode's Simulator yourself** before trusting it fully.

## What's included

```
NewsU/
  project.yml               XcodeGen project definition (see Setup below)
  Subscription.storekit      Local StoreKit test config — two subscription plans, no App Store Connect needed to test
  .github/workflows/
    daily-curation.yml       Scheduled job: runs the backend daily, commits the result — free, no server
  public/
    brief-latest.json        Where the daily curation output lands (seeded with sample data until your first real run)
  NewsU/
    App/                     App entry point + global state (AppState) + RemoteConfig.swift (the one line to go live)
    Models/                  Topic, NewsBrief, Article, Verse, UserAccount, PrayerRequest, UserPreferences
    Theme/                   Colors, gradients, typography — the whole look in one file
    Services/                Brief fetching, auth, StoreKit, prayer requests, notifications, persistence
    Views/
      Auth/                  Sign up / sign in — the first thing anyone sees
      Subscription/          The paywall, shown right after sign-up/sign-in
      Onboarding/            Welcome → topic picker → notification setup
      Main/                  The TabView shell (Today / Prayer / Settings)
      Home/                  Today's Brief: prayer card, topic grid, per-topic pages, verse cards
      Prayer/                Prayer request journal — list + submission form
      Settings/              Account, subscription management, topics, reminder time
      Components/            Buttons, topic chips, flow layout, app mark badge
    Resources/
      sample_brief.json      A full realistic day's content (5 topics, prayer, verses) — the offline fallback
      Assets.xcassets/       App icon + accent color
  backend/                   Real, tested curation pipeline — RSS feeds + Claude — see backend/README.md
    curate.js                 The pipeline itself
    feeds.js                  Which real RSS feeds feed which topic
```

## Setup: getting this into Xcode

You have two options. **Option A is strongly recommended** — it's faster and
avoids any manual project-file mistakes.

### Option A: XcodeGen (recommended)

[XcodeGen](https://github.com/yonaskolb/XcodeGen) generates a proper
`.xcodeproj` from `project.yml`, so nothing about the project structure was
hand-typed into a fragile XML file.

```bash
brew install xcodegen
cd "NewsU"
xcodegen generate
open NewsU.xcodeproj
```

Then in Xcode:
1. Select the **NewsU** target → **Signing & Capabilities**.
2. Change **Team** to your own Apple Developer account.
3. Change **Bundle Identifier** from `com.newsu.app` to something under a
   domain you control (e.g. `com.yourname.newsu`) — `com.newsu.app` is just a
   placeholder and you don't own it. If you change it, also update the two
   product IDs in `Subscription.storekit` and `StoreKitManager.productIDs` to
   match your new bundle ID prefix, and later create matching subscription
   products in App Store Connect.
4. Pick an iPhone simulator (e.g. iPhone 16) and hit **Run** (⌘R). The scheme
   is already wired to `Subscription.storekit`, so the paywall will show real
   products and let you "purchase" them for free in Simulator — no sandbox
   tester account needed for local testing.

### Option B: Create the Xcode project by hand

If you'd rather not install anything:
1. In Xcode: **File → New → Project → iOS → App**.
2. Product Name: `NewsU`, Interface: **SwiftUI**, Language: **Swift**.
3. Delete the auto-generated `ContentView.swift` and `NewsUApp.swift`.
4. Drag the entire `NewsU/NewsU` folder from Finder into your Xcode project
   navigator, choosing **"Copy items if needed"** and **"Create groups."**
5. Select your target → **Signing & Capabilities**, set your Team and a bundle
   ID you own.
6. In the scheme editor (Product → Scheme → Edit Scheme → Run → Options), set
   **StoreKit Configuration** to `Subscription.storekit` — this is what
   XcodeGen wires up automatically in Option A.
7. Build & run.

## Owner access (skip the paywall while testing)

`AppState.swift` has a small `ownerEmails` allowlist — any account signed in
with one of those emails skips the subscription check entirely, so you don't
have to pay for your own app to test it. One account is already in there:
`info@elizabethalexandria.co`. Sign up with that exact email in the app (any
password 6+ characters — `elizabeth2410` is what was requested) and you'll go
straight from sign-up to onboarding, no paywall.

Two things worth knowing:
- This only affects the *client-side* gate — it doesn't touch StoreKit or App
  Store Connect, so it costs nothing and creates no real subscription.
- It's wrapped in `#if DEBUG`, so it's automatically compiled out of
  Release/App Store archive builds — it can't accidentally ship as a
  backdoor. Add more emails to the list (`AppState.swift`) for other
  reviewers/testers as needed.

## Trying it out

The app now gates in order — each step is required before the next unlocks:

1. **Sign up or sign in** — the very first screen. Create any local test
   account (email + password, 6+ characters); it's stored only on-device.
2. **Subscribe** — the paywall shows two real StoreKit products (monthly /
   annual). Tap one and "Continue" to purchase — in Simulator with the local
   StoreKit config, this completes instantly and for free.
3. **Onboarding** — welcome screen → pick your topics → set a morning
   reminder time (schedules a real local notification if you allow it).
4. **Today tab** — the daily brief: prayer card up top, then a grid of your
   topics. Tap a topic to open its own page with that topic's stories and a
   verse. Tap a headline for the full AI summary and a "Read Full Story"
   link out to the original source.
5. **Prayer tab** — a private, on-device prayer request journal. Add a
   request with a category, mark it answered later, swipe to delete.
6. **Settings tab** — account info, manage/cancel your subscription (opens
   Apple's real subscription management sheet), sign out, delete account,
   change topics, change your reminder time.

## Design

The brand identity is meant to feel like a serious news outlet; the content
inside it is meant to feel like a devotional:
- **Wordmark & icon**: bold Helvetica for "NewsU," and a flat, high-contrast
  masthead icon — a bold "N" on dark navy with a thin gold rule underneath.
  No soft gradients, no religious iconography on the brand itself — that
  register is reserved for the content (see below).
- **Content**: warm parchment background in light mode, deep dusk navy in
  dark mode, a single muted gold accent, serif type (New York) for headlines
  and verses. The prayer card uses a soft "dawn" gradient; verse cards use a
  deeper, stiller indigo gradient — visually distinct from ordinary news
  cards on purpose, so they read as a pause, not another headline.
- This split is deliberate: the app should look like a trustworthy news
  product from the App Store icon through sign-up, then shift into something
  calmer once you're actually inside reading.

## Testing the subscription locally

`Subscription.storekit` defines a subscription group ("NewsU Plus") with two
products — monthly ($4.99) and annual ($39.99) — and the scheme is already
configured to use it (`storeKitConfiguration` in `project.yml`). This means:
- Running from Xcode shows real product names/prices/descriptions from that
  file, and lets you complete a "purchase" instantly, for free, entirely
  offline.
- `Xcode → Debug → StoreKit → Manage Transactions` lets you inspect, refund,
  or expire test transactions while the app is running.
- None of this requires an App Store Connect account, sandbox tester, or
  paid Apple Developer membership — it's real StoreKit 2 code
  (`StoreKitManager.swift`), just pointed at a local file instead of Apple's
  servers.

**Before you ship**, create two subscription products in App Store Connect
with the exact same product IDs (`com.yourbundleid.plus.monthly` /
`.plus.annual`, adjusted for your real bundle ID) inside one subscription
group. The same code then talks to the real App Store automatically —
nothing else changes.

## Important: what is real vs. mocked

| Piece | Status |
|---|---|
| SwiftUI app, all screens, navigation, theming | ✅ Real, fully built |
| Sign up / sign in gate | ✅ Real flow, ⚠️ **local-only storage** — see note below |
| Subscription paywall | ✅ **Real StoreKit 2**, locally testable; needs matching App Store Connect products to go live |
| Account deletion | ✅ Real (Settings → Delete Account) — required by App Review Guideline 5.1.1(v) |
| Topic subscription, prayer requests, reminder time | ✅ Real (on-device persistence) |
| Daily local reminder notification | ✅ Real (`UNUserNotificationCenter`) |
| Today's Brief content | ⚠️ Ships pointed at bundled sample JSON; ✅ **real pipeline built & tested**, one config line from live (see below) |
| AI news gathering (RSS) + Claude summarization/verse matching | ✅ **Real, tested** (`backend/curate.js`) — needs only your Anthropic API key |
| Daily scheduling & hosting | ✅ **Real** — GitHub Actions workflow included, free, no server to run |
| Prayer requests reaching an actual prayer team | ⚠️ **Not built** — currently private/local only, by design (see below) |

**On accounts:** `MockAuthService` stores accounts (email, hashed password,
name) only in `UserDefaults` on the device. That's enough to demo a real
gate, but it means no password recovery, no cross-device login, and data that
isn't protected the way a server-side auth system would protect it. Before
shipping, swap it for `RemoteAuthService` (stubbed, same file) backed by a
real provider — Firebase Auth, Supabase Auth, or your own server.

**On prayer requests:** they're deliberately private to each device/account
and never leave it. That sidesteps the extra moderation and reporting
requirements Apple applies to user-generated content that's shared with other
people (Guideline 1.2). If you actually want these routed to a real prayer
team, that's a bigger feature — a backend inbox plus a moderation plan — see
`PrayerRequestService.swift` and `backend/README.md`.

**On the news content itself:** "gather all the most relevant news each day,
AI-curate it, and match it to a verse" is inherently a *server-side* job — it
has to run on a schedule even when nobody has the app open. That piece is
fully built and tested, not just sketched: `backend/curate.js` pulls real,
live headlines from BBC/NPR/Religion News Service RSS feeds (I ran it and
confirmed real, current stories came back), sends them to Claude for
curation, and a scheduled GitHub Actions workflow
(`.github/workflows/daily-curation.yml`) runs it daily for free. Going from
"built" to "live in your app" needs exactly two things only you can
provide — an Anthropic API key and a GitHub repo to push this to — both
covered step by step in [`backend/README.md`](backend/README.md).

## Before submitting to the App Store

- [ ] **Your own Apple Developer account & bundle ID** (see Setup above).
- [ ] **A real backend** for news content and for accounts (see table above)
      — App Review will notice if content never changes or accounts aren't
      really persisted anywhere durable.
- [ ] **Subscription products created in App Store Connect** matching the
      product IDs in `Subscription.storekit`, inside one subscription group.
- [ ] **Privacy Policy URL** — required for accounts, notifications, and
      network requests. Must disclose what's collected (accounts, chosen
      topics, and — if you keep prayer requests private/local as shipped —
      that they never leave the device).
- [ ] **App Privacy "nutrition label"** in App Store Connect, matching the
      above.
- [ ] **Screenshots** for at least one 6.7" iPhone size (required) — capture
      sign-up, the paywall, the topic grid, and an article detail screen.
- [ ] **Support URL** (a webpage or even a simple contact page is enough).
- [ ] **Disclose AI-generated content** in your app description — being
      upfront ("summaries and verse selections are AI-curated") is both
      compliant and honest about the product.
- [ ] **Subscription terms visible on the paywall** — already built
      (`SubscriptionPaywallView`'s legal footer: auto-renewal disclosure,
      Terms of Use / Privacy Policy links) per Guideline 3.1.2, but point
      those two placeholder URLs at real, live pages before submitting.
- [ ] **Account deletion** — already built (Settings → Delete Account) per
      Guideline 5.1.1(v). If you move accounts to a real backend, make sure
      deletion actually erases server-side data too, not just the local copy.
- [ ] **News category consideration**: if you list this under the *News*
      category, keep the source attribution and linking-out behavior
      (`ArticleDetailView`) intact — reproducing full third-party articles
      without licensing is a real copyright risk. Summarize + link out, don't
      republish in full.
- [ ] Sanity-check `Subscription.storekit` by opening it in Xcode (double-
      click it in the navigator) — Xcode will show its built-in editor if the
      file is valid, or flag a problem if not.

## Extending it

- **Go live with real news**: set `RemoteConfig.briefURL` once your GitHub
  Actions workflow has run — see `backend/README.md` for the full walkthrough.
- Same Mock/Remote pattern is already in place for accounts
  (`RemoteAuthService`) and prayer requests (`RemotePrayerRequestService`)
  once you have backends for those.
- Want a "streak" or reading history? `AppState` is the natural place to add
  a `@Published var streak: Int` backed by `PersistenceService`.
- Want multiple denominational verse translations? Add a `translation` field
  to `Verse` and a picker in `SettingsView`.
