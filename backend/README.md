# NewsU backend — real, tested, and ready to schedule

This is what makes the app genuinely hands-off: a daily job that pulls real
headlines from major news outlets, has Claude curate + summarize + match
each topic with Scripture, and writes one JSON file the app reads. No server
to run — it's a script plus a scheduled GitHub Actions workflow.

**This isn't a mockup.** I ran the full pipeline for real from this machine:
live-fetched all ten topics' RSS feeds (confirmed real, current headlines —
Nepal flooding, a Meta settlement, midterm politics, etc.), and verified the
JSON it produces decodes correctly with the exact same Swift decoder the app
uses (`.iso8601`, in `BriefService.swift`) — including catching and fixing a
real date-formatting bug (JS's `toISOString()` includes milliseconds, which
Swift's default ISO 8601 decoder rejects; `toISOStringNoMillis()` in
`curate.js` fixes this). The only part I couldn't test end-to-end is the
actual Claude API call, since that needs a real key — I verified it with a
mocked server that returns the same response shape.

## What it does

1. **Fetches real headlines** per topic from major outlets' public RSS feeds
   — BBC, NPR, Religion News Service (see `feeds.js`). No news API key, no
   signup — these are outlets' own syndication feeds, meant for exactly this.
2. **Sends them to Claude**, which picks the most significant stories
   (preferring ones corroborated across outlets), writes neutral attributed
   summaries, and chooses a Bible verse + short reflection for each topic.
3. **Asks Claude for one opening prayer** that reads the overall tone of the
   day across all topics.
4. **Prints the resulting JSON** — matching `NewsU/NewsU/Models/NewsBrief.swift`
   exactly.

This curates once per topic, not once per individual user — everyone
subscribed to "Technology" reads the same AI-curated Technology section.
"Curated for each user" happens in the app: each person only ever sees the
topics they picked. Running the AI step per-topic instead of per-user is what
keeps this affordable regardless of how many people use the app.

## The two things only you can do

I can't create accounts or spend money on your behalf, so exactly two things
need you:

1. **Get an Anthropic API key** — [console.anthropic.com](https://console.anthropic.com),
   pay-as-you-go, generally cents per day for this volume of usage.
2. **Push this project to a GitHub repo** (free) — if you don't already have
   one:
   ```bash
   cd "NewsU"
   git init
   git add .
   git commit -m "Initial commit"
   ```
   Then create a repo on github.com and follow its "push an existing repo"
   instructions. It can be public or private — public is simpler (see below).

Everything else — the pipeline, the schedule, the hosting — is already built.

## Wiring it up (step by step)

1. **Add your API key as a repo secret**: on GitHub, go to your repo →
   Settings → Secrets and variables → Actions → New repository secret. Name
   it `ANTHROPIC_API_KEY`, paste your key, save. (Never put a real key
   directly in code or in a chat — a repo secret is the right place.)
2. **Run it once manually** to check it works: repo → Actions tab →
   "Daily NewsU curation" → Run workflow. After it finishes (~1-2 minutes),
   you should see a new commit updating `public/brief-latest.json`.
3. **Get the raw URL for that file**:
   `https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/public/brief-latest.json`
   (If your repo is private, this URL won't be publicly readable — either
   make the repo public, or use GitHub Pages / another host that supports
   private-but-served content. Public is simplest and the code here contains
   nothing sensitive.)
4. **Point the app at it**: open `NewsU/App/RemoteConfig.swift` and set
   `briefURL` to that URL. Rebuild the app. Done — it now shows real,
   AI-curated news, updated automatically every day.

From here it's genuinely hands-off: the GitHub Action runs on its own
schedule (`.github/workflows/daily-curation.yml`, 08:00 UTC by default —
edit the cron line to change it), regenerates the brief, and commits it.
The app just reads whatever's there.

## Notifications: local vs. push

The app schedules a **local** notification at the user's chosen time
(`NotificationManager.swift`) — it fires on-device regardless of whether
GitHub Actions has run yet that day. As long as your workflow runs a
comfortable margin before your users' morning (the default 08:00 UTC is
before sunrise across the US), this is good enough and needs zero extra
infrastructure.

For a tighter guarantee (the reminder never fires before the brief is
actually ready), you'd move to a **silent push notification** sent right
after the workflow commits, with the visible local notification scheduled
only on receipt. That needs an Apple Push Notification service (APNs) key
and a device token registry — a meaningfully bigger step, and optional.

## Accounts and prayer requests need their own backends too

This covers the news pipeline only. Two other pieces are mocked locally the
same way, and follow the same Mock/Remote pattern so swapping them in later
is mechanical:

- **Accounts** (`NewsU/Services/AuthService.swift`) — `MockAuthService` stores
  accounts in on-device `UserDefaults`. Replace with `RemoteAuthService`
  backed by a real provider (Firebase Auth, Supabase Auth, or your own
  server). Whatever you use, make sure account deletion actually erases the
  user's data server-side too — Apple checks this.
- **Prayer requests** (`NewsU/Services/PrayerRequestService.swift`) — shipped
  private-to-device by design. If you want these to reach a real prayer team,
  that's a small inbox to build: an endpoint, storage, and — since it becomes
  content another person reads — a moderation/reporting plan (App Review
  Guideline 1.2).

## Trustworthiness & editorial care

This pipeline asks Claude to prefer corroborated, multi-source stories and
write neutral, attributed summaries — but you're the publisher of record
here, not the AI. Before shipping to the App Store:

- Confirm you're comfortable with BBC/NPR/RNS's syndication terms for this
  kind of use (headline + short AI summary + link back to their site — not
  full article reproduction), or swap in sources you're more sure about.
- Consider a human spot-check early on; fully autonomous news judgment can
  occasionally miss context or nuance.
- Keep the in-app AI-generated-content disclosure and source linking intact
  (already built — see `ArticleDetailView`).

## Local development

```bash
cd backend
npm install
ANTHROPIC_API_KEY=sk-ant-... npm run curate
```

Prints today's brief JSON to stdout. `node --version` needs to be 18+ (for
built-in `fetch`); the GitHub Actions workflow uses Node 22.
