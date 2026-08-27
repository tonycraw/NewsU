/**
 * Public RSS feeds, mapped to NewsU's topic IDs. No API key needed — these
 * are outlets' own public syndication feeds, meant for exactly this kind of
 * aggregation. We only ever pull headline + short description + link, then
 * link out to the original source (see ArticleDetailView) — never full
 * article bodies — which keeps this on the right side of fair use.
 *
 * Feed URLs were verified live as of this writing, but any RSS feed can move
 * or shut down — if a topic's articles dry up, check these first.
 */
export const FEEDS_BY_TOPIC = {
  world: [
    "http://feeds.bbci.co.uk/news/world/rss.xml",
    "https://feeds.npr.org/1004/rss.xml"
  ],
  us: [
    "http://feeds.bbci.co.uk/news/world/us_and_canada/rss.xml",
    "https://feeds.npr.org/1003/rss.xml"
  ],
  politics: [
    "https://feeds.npr.org/1014/rss.xml",
    "http://feeds.bbci.co.uk/news/world/rss.xml"
  ],
  business: [
    "http://feeds.bbci.co.uk/news/business/rss.xml",
    "https://feeds.npr.org/1006/rss.xml"
  ],
  technology: [
    "http://feeds.bbci.co.uk/news/technology/rss.xml",
    "https://feeds.npr.org/1019/rss.xml"
  ],
  health: [
    "http://feeds.bbci.co.uk/news/health/rss.xml",
    "https://feeds.npr.org/1128/rss.xml"
  ],
  science: [
    "http://feeds.bbci.co.uk/news/science_and_environment/rss.xml",
    "https://feeds.npr.org/1007/rss.xml"
  ],
  faith: [
    "https://religionnews.com/feed/"
  ],
  sports: [
    "http://feeds.bbci.co.uk/sport/rss.xml?edition=int"
  ],
  entertainment: [
    "http://feeds.bbci.co.uk/news/entertainment_and_arts/rss.xml"
  ]
  // "local" has no generic feed — it depends on where each user lives. Add
  // your own local paper's RSS feed here if you want to support it.
};
