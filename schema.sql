-- ─────────────────────────────────────────────────────────────
-- buildbyte.buzz — D1 schema
-- Apply with:  wrangler d1 execute buildbyte --file=./schema.sql
-- ─────────────────────────────────────────────────────────────

-- Subscribers captured by the "Notify me" form on the landing page.
CREATE TABLE IF NOT EXISTS subscribers (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  email       TEXT NOT NULL UNIQUE,
  ip          TEXT,
  ua          TEXT,
  source      TEXT DEFAULT 'landing',
  created_at  TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Editable site content (key/value) managed from /db dashboard.
-- Default rows are seeded below so the site renders out of the box.
CREATE TABLE IF NOT EXISTS content (
  key         TEXT PRIMARY KEY,
  value       TEXT NOT NULL,
  updated_at  TEXT NOT NULL DEFAULT (datetime('now'))
);

-- ── Seed content ──────────────────────────────────────────────
INSERT OR IGNORE INTO content (key, value) VALUES
  ('hero_title',       'Build & Deploy Websites with AI — Free.'),
  ('hero_subtitle',    'buildbyte.buzz turns a single prompt into a production-ready website, deployed to the edge in seconds. No code. No servers. No cost.'),
  ('hero_badge',       'Coming soon · January 13'),
  ('cta_placeholder',  'you@domain.com'),
  ('cta_button',       'Notify me at launch'),

  ('feature_1_title',  'AI-Powered Build'),
  ('feature_1_desc',   'Describe what you want in plain language. The agent designs, writes, and assembles every section.'),
  ('feature_2_title',  '1-Click Deploy'),
  ('feature_2_desc',   'Ship to Cloudflare''s global edge network in a single tap. No DevOps, no config files.'),
  ('feature_3_title',  'Free Custom Domain'),
  ('feature_3_desc',   'Bring your own domain or use a buildbyte.buzz subdomain — SSL and CDN included, forever free.'),
  ('feature_4_title',  'No-Code Editor'),
  ('feature_4_desc',   'Tweak copy, layout, and palette visually. Changes go live the instant you save.'),

  ('step_1_title',     'Describe'),
  ('step_1_desc',      'Tell buildbyte what you''re building — a portfolio, a store, a launch page.'),
  ('step_2_title',     'AI Builds'),
  ('step_2_desc',      'The agent drafts layout, copy, images, and SEO in seconds. Preview it instantly.'),
  ('step_3_title',     'Deploy'),
  ('step_3_desc',      'Hit publish. Your site is live on the edge with a free domain and SSL.'),

  ('faq_1_q',          'Is buildbyte really free?'),
  ('faq_1_a',          'Yes. Building, deploying, and hosting on a buildbyte.buzz subdomain is free forever. Custom domains are free during the launch period.'),
  ('faq_2_q',          'Do I need to know how to code?'),
  ('faq_2_a',          'No. Describe your site in plain language and the AI handles the rest. A visual editor lets you refine anything afterward.'),
  ('faq_3_q',          'Where is my site hosted?'),
  ('faq_3_a',          'On Cloudflare''s global edge network — 300+ cities, automatic SSL, sub-50ms TTFB almost everywhere.'),
  ('faq_4_q',          'Can I export my code?'),
  ('faq_4_a',          'Yes. Every site is standard HTML, CSS, and TypeScript. Export the full source anytime.'),

  ('footer_tagline',   'Made with AI on Cloudflare.'),
  ('footer_twitter',   'https://twitter.com/buildbyte'),
  ('footer_github',    'https://github.com/buildbyte'),
  ('footer_discord',   'https://discord.gg/buildbyte'),
  ('footer_copyright', 'buildbyte.buzz');

-- ── Helpful index ─────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_subscribers_created ON subscribers(created_at);
