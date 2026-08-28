/**
 * NewsU daily curation pipeline — REFERENCE IMPLEMENTATION, now wired to real
 * news sources.
 *
 * This is what makes the app "hands-off": run this once a day (see README.md
 * for scheduling — a ready-made GitHub Actions workflow is included) and it
 * produces the exact JSON shape the iOS app's `NewsBrief` model decodes (see
 * NewsU/NewsU/Models/NewsBrief.swift).
 *
 * Pipeline:
 *   1. Pull real headlines per topic from major outlets' public RSS feeds
 *      (see feeds.js) — no news API key needed, these are outlets' own
 *      syndication feeds, meant for exactly this.
 *   2. Ask Claude to pick the most newsworthy, well-corroborated stories,
 *      write neutral attributed summaries, and choose a fitting Bible verse
 *      (+ one-line reflection) for each topic section.
 *   3. Ask Claude for one short opening prayer that responds to today's
 *      overall tone (calm day vs. heavy news day).
 *   4. Print the resulting JSON — the GitHub Actions workflow writes this to
 *      a file and commits it, so the app can fetch it from a stable URL.
 *
 * This curates once per topic, not once per individual user — every user
 * subscribed to "Technology" reads the same AI-curated Technology section.
 * "Curated for each user" happens client-side: the app only ever shows each
 * user the topics they picked (see MockBriefService/RemoteBriefService).
 * Running the AI step per-topic instead of per-user keeps this affordable at
 * any number of users — it's the right tradeoff, not a shortcut.
 *
 * Required environment variable:
 *   ANTHROPIC_API_KEY   - Claude API key (https://console.anthropic.com)
 */

import Anthropic from "@anthropic-ai/sdk";
import { XMLParser } from "fast-xml-parser";
import { pathToFileURL } from "node:url";
import { FEEDS_BY_TOPIC } from "./feeds.js";

const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
const xmlParser = new XMLParser({ ignoreAttributes: false });

/**
 * Swift's default `.iso8601` JSONDecoder strategy (used in BriefService.swift)
 * does NOT accept fractional seconds — but `Date.prototype.toISOString()`
 * always includes milliseconds. Using the built-in method directly here would
 * produce dates the app fails to decode. This formats without them instead.
 */
function toISOStringNoMillis(date) {
  return date.toISOString().replace(/\.\d{3}Z$/, "Z");
}

const TOPIC_NAMES = {
  world: "World",
  us: "U.S. News",
  politics: "Politics",
  business: "Business & Economy",
  technology: "Technology",
  health: "Health",
  science: "Science",
  faith: "Faith & Culture",
  sports: "Sports",
  entertainment: "Entertainment"
};

const HTML_ENTITIES = {
  amp: "&", lt: "<", gt: ">", quot: '"', apos: "'", nbsp: " ",
  ldquo: "“", rdquo: "”", lsquo: "‘", rsquo: "’",
  mdash: "—", ndash: "–", hellip: "…"
};

function decodeEntities(value) {
  return value
    .replace(/&#(\d+);/g, (_, code) => String.fromCharCode(Number(code)))
    .replace(/&#x([0-9a-fA-F]+);/g, (_, code) => String.fromCharCode(parseInt(code, 16)))
    .replace(/&(\w+);/g, (match, name) => HTML_ENTITIES[name] ?? match);
}

function stripHtml(value) {
  if (!value) return "";
  return decodeEntities(String(value).replace(/<[^>]+>/g, "")).replace(/\s+/g, " ").trim();
}

/**
 * Pulls the JSON payload out of a Claude response. Deliberately not just
 * `message.content[0].text` — some responses include a non-text block first
 * (e.g. thinking), and models occasionally wrap JSON in a ```json fence
 * despite being told not to. This handles both, and if the text truly can't
 * be found or parsed, logs the full raw response so the real cause is
 * visible in the Action's log instead of a bare "undefined is not valid JSON".
 */
function extractJSON(message) {
  const textBlock = message.content?.find((block) => block.type === "text");
  if (!textBlock?.text) {
    console.error("Unexpected Claude response — no text block found:");
    console.error(JSON.stringify(message, null, 2));
    throw new Error(`Claude response had no text content (stop_reason: ${message.stop_reason ?? "unknown"})`);
  }

  const cleaned = textBlock.text.trim().replace(/^```(?:json)?\n?/, "").replace(/\n?```$/, "");
  try {
    return JSON.parse(cleaned);
  } catch (err) {
    if (message.stop_reason === "max_tokens") {
      console.error(
        `Claude's response was cut off by the max_tokens limit before finishing the JSON. ` +
        `Raise max_tokens in the anthropic.messages.create() call this came from. Raw (truncated) text was:`
      );
    } else {
      console.error("Failed to parse JSON from Claude's response. Raw text was:");
    }
    console.error(textBlock.text);
    throw err;
  }
}

/** Step 1: pull and parse raw headlines for a topic from its RSS feeds. */
async function fetchHeadlinesForTopic(topicId) {
  const feedUrls = FEEDS_BY_TOPIC[topicId] || [];
  const items = [];

  for (const feedUrl of feedUrls) {
    try {
      const res = await fetch(feedUrl, {
        headers: { "User-Agent": "Mozilla/5.0 (compatible; NewsUCurationBot/1.0)" }
      });
      if (!res.ok) {
        console.error(`Feed returned ${res.status}: ${feedUrl}`);
        continue;
      }
      const xml = await res.text();
      const parsed = xmlParser.parse(xml);
      const channel = parsed?.rss?.channel;
      if (!channel) continue;

      const sourceName = stripHtml(channel.title) || new URL(feedUrl).hostname;
      const rawItems = Array.isArray(channel.item) ? channel.item : channel.item ? [channel.item] : [];

      for (const item of rawItems.slice(0, 10)) {
        items.push({
          headline: stripHtml(item.title),
          source: sourceName,
          description: stripHtml(item.description),
          url: typeof item.link === "string" ? item.link : item.link?.["#text"] ?? item.link,
          publishedAt: item.pubDate ? toISOStringNoMillis(new Date(item.pubDate)) : toISOStringNoMillis(new Date())
        });
      }
    } catch (err) {
      console.error(`Failed to fetch/parse ${feedUrl}:`, err.message);
    }
  }

  items.sort((a, b) => new Date(b.publishedAt) - new Date(a.publishedAt));
  return items.slice(0, 12);
}

/** Step 2: Claude picks the best 2 stories, writes neutral summaries, and matches a verse. */
async function curateSection(topicId, rawHeadlines) {
  const topicName = TOPIC_NAMES[topicId] ?? topicId;
  const prompt = `You are curating a section of a Christian morning news app called NewsU.

Topic: ${topicName}

Here are today's raw headlines gathered from real news outlets' RSS feeds (JSON):
${JSON.stringify(rawHeadlines, null, 2)}

Do the following:
1. Choose the 2 most significant, newsworthy stories. If the same story
   appears from more than one outlet, treat that as corroboration and prefer it.
2. For each, write a neutral, factual 2-3 sentence summary in your own words —
   no editorializing, no loaded language, attribute claims to their source.
   Base this only on the headline/description given; don't invent details.
3. Write a one-line "trustNote" describing how corroborated the story is
   (e.g. "Corroborated by 2 outlets", "Single source: BBC News").
4. Choose ONE Bible verse that thoughtfully relates to the emotional or moral
   weight of this topic today — comfort for hard news, gratitude for good news,
   wisdom for complex news. Avoid trite or forced pairings. Include a short
   (1-2 sentence) reflection connecting the verse to today's news, written with
   pastoral warmth, not preachiness.
5. Use the real "url" and "source" fields from the matching input item for
   each article you choose — don't fabricate a URL.

Respond with ONLY valid JSON matching this shape:
{
  "articles": [
    { "headline": "", "source": "", "summary": "", "url": "", "trustNote": "" }
  ],
  "verse": { "reference": "", "text": "", "reflection": "" }
}`;

  const message = await anthropic.messages.create({
    model: "claude-sonnet-5",
    max_tokens: 2048,
    messages: [{ role: "user", content: prompt }]
  });

  return extractJSON(message);
}

/** Step 3: one short opening prayer that reads the room on today's news as a whole. */
async function writeOpeningPrayer(sectionSummaries) {
  const prompt = `You are writing the opening prayer for a Christian morning news app called NewsU.
It appears before the user reads any news, to center their heart in peace regardless
of what the headlines hold today.

Here is a brief summary of today's sections:
${sectionSummaries.map((s) => `- ${s.topic}: ${s.articles.map((a) => a.headline).join("; ")}`).join("\n")}

Write a short prayer (60-90 words) with a short title (2-4 words). It should be warm,
grounded in Scripture-consistent theology, not tied to any one denomination, and should
NOT mention specific headlines by name — it should speak to the posture of the heart
before reading news in general, gently informed by whether today's news skews heavy or hopeful.

Respond with ONLY valid JSON: { "title": "", "body": "" }`;

  const message = await anthropic.messages.create({
    model: "claude-sonnet-5",
    max_tokens: 500,
    messages: [{ role: "user", content: prompt }]
  });

  return extractJSON(message);
}

export async function buildTodaysBrief(topicIds = Object.keys(FEEDS_BY_TOPIC)) {
  const sections = [];

  for (const topicId of topicIds) {
    const raw = await fetchHeadlinesForTopic(topicId);
    if (raw.length === 0) {
      console.error(`No headlines fetched for topic "${topicId}" — skipping.`);
      continue;
    }
    const curated = await curateSection(topicId, raw);
    sections.push({
      topicId,
      articles: curated.articles.map((a, i) => ({
        id: `${topicId}-${i}`,
        publishedAt: toISOStringNoMillis(new Date()),
        ...a
      })),
      verse: curated.verse
    });
  }

  const openingPrayer = await writeOpeningPrayer(
    sections.map((s) => ({ topic: s.topicId, articles: s.articles }))
  );

  return {
    date: toISOStringNoMillis(new Date()),
    greeting: "Good morning, friend",
    openingPrayer,
    sections,
    closingBlessing:
      "Whatever today holds, go into it steady — you've already been reminded who's holding it. — Numbers 6:24-26"
  };
}

// Entry point — the GitHub Actions workflow runs this and captures stdout.
// Compared via pathToFileURL (not a raw string template) because a plain
// `file://${process.argv[1]}` breaks whenever the path contains spaces or
// other characters that get percent-encoded in a real file:// URL.
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const topicIds = Object.keys(FEEDS_BY_TOPIC);
  buildTodaysBrief(topicIds)
    .then((brief) => console.log(JSON.stringify(brief, null, 2)))
    .catch((err) => {
      console.error(err);
      process.exit(1);
    });
}
