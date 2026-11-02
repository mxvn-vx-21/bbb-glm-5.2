# buildbyte.buzz — Coming Soon

A glassmorphic coming-soon landing page for **buildbyte.buzz** ("build & deploy
websites with AI, free"). Built with TypeScript + HTML + CSS, deployed on
Cloudflare Pages + Pages Functions (Workers), with D1 for storage.

## Features

- **3D honeycomb logo** — Three.js extruded hex cluster with cursor parallax and floating particle dust (on-brand for ".buzz").
- **Glass UI everywhere** — frosted panels, backdrop blur, hairline borders.
- **Custom cursor** — lime dot + trailing ring that grows on hover.
- **Click ripples** — every click spawns an expanding ring + particle burst on a canvas overlay.
- **3D tilt cards** — feature / step / countdown cards rotate in 3D toward the cursor.
- **Magnetic buttons** — CTAs gently pull toward the cursor.
- **Scroll reveal** — sections fade up via IntersectionObserver.
- **Live countdown** — counts down to **Jan 13** (configurable in `wrangler.toml`).
- **Email capture** — POSTs to `/api/subscribe`, stored in D1 `subscribers` table.
- **Dynamic content** — landing page hydrates from `/api/content`; everything is editable from the admin dashboard.
- **Admin dashboard at `/db`** — password-gated (default password **`uf1`**). Edit hero copy, features, steps, FAQ, footer, etc. Export subscribers as CSV.

## Tech stack

| Layer        | Choice                                                |
| ------------ | ----------------------------------------------------- |
| Front-end    | TypeScript, hand-written HTML/CSS, Three.js           |
| Build        | esbuild (`npm run build`) → `public/js/main.js`       |
| Hosting      | Cloudflare Pages (static) + Pages Functions (Worker)  |
| Database     | Cloudflare D1 (`subscribers`, `content` tables)       |
| Storage      | R2 bucket stub (commented in `wrangler.toml`)         |
| Auth         | SHA-256 password + signed session cookie, 7-day TTL  |

## Project layout

```
buildbyte-coming-soon/
├── public/                 # Static assets (deployed to Pages)
│   ├── index.html          # Landing page
│   ├── css/main.css        # Glassmorphism, monochrome + lime
│   └── js/main.js          # Compiled bundle (built from src/)
├── src/
│   └── main.ts             # Front-end TS (cursor, ripples, 3D, etc.)
├── functions/              # Pages Functions = Worker
│   ├── _middleware.ts      # Gate /db
│   ├── db.ts               # Admin login + dashboard + CRUD
│   └── api/
│       ├── subscribe.ts    # POST email → D1
│       └── content.ts      # GET content → JSON
├── schema.sql              # D1 schema + seed content
├── wrangler.toml           # Bindings (D1, R2, vars)
├── package.json
└── tsconfig.json
```

## Quick start (local)

```bash
# 1. Install deps
npm install

# 2. Build the front-end bundle
npm run build

# 3. Apply the D1 schema locally
npx wrangler d1 execute buildbyte --local --file=./schema.sql

# 4. Run the dev server (Pages + Worker on http://localhost:8788)
npm run dev
```

Open <http://localhost:8788/> for the landing page, or <http://localhost:8788/db>
for the admin dashboard (password: `uf1`).

## Deploy to Cloudflare

### 1. Create the D1 database

```bash
npx wrangler d1 create buildbyte
```

Paste the returned `database_id` into `wrangler.toml` (replacing
`REPLACE_WITH_YOUR_D1_ID`).

### 2. Apply the schema remotely

```bash
npx wrangler d1 execute buildbyte --remote --file=./schema.sql
```

### 3. (Optional) Rotate the admin password

The default hash in `wrangler.toml` is the SHA-256 of `uf1`. To use a stronger
password, set it as a secret:

```bash
# Compute the hash:
printf '%s' 'your-strong-password' | shasum -a 256
# Store as a Pages secret (overrides the [vars] value):
npx wrangler pages secret put ADMIN_PASS_HASH --project-name=buildbyte
# Paste the hash when prompted.
```

### 4. Create the Pages project & deploy

```bash
npx wrangler pages project create buildbyte
npm run deploy   # builds the bundle, then: wrangler pages deploy public --project-name=buildbyte
```

### 5. Connect your domain

In the Cloudflare dashboard → **Pages → buildbyte → Custom domains** → add
`buildbyte.buzz` (and `www.buildbyte.buzz` if desired). Cloudflare provisions
SSL automatically. If the domain is on a different Cloudflare account, add a
CNAME `buildbyte.buzz → buildbyte.pages.dev`.

## Admin dashboard

- **URL:** `/db`
- **Password:** `uf1` (change via the secret rotation step above)
- Edit any content key (e.g. `hero_title`, `faq_1_q`, `footer_tagline`) and
  save — changes go live within 60 seconds (the cache TTL on `/api/content`).
- Add new keys (e.g. `faq_5_q` + `faq_5_a`) — they'll automatically hydrate any
  matching `data-faq` element on the landing page.
- Export all subscribers as CSV via **Export CSV** in the dashboard header.
- Logout clears the session cookie.

## Content keys (defaults seeded in `schema.sql`)

| Prefix    | Keys                                                  |
| --------- | ----------------------------------------------------- |
| `hero_`   | `hero_title`, `hero_subtitle`, `hero_badge`           |
| `cta_`    | `cta_placeholder`, `cta_button`                       |
| `feature_`| `feature_1..4_title`, `feature_1..4_desc`             |
| `step_`   | `step_1..3_title`, `step_1..3_desc`                   |
| `faq_`    | `faq_1..4_q`, `faq_1..4_a`                            |
| `footer_` | `footer_tagline`, `footer_twitter`, `footer_github`, `footer_discord`, `footer_copyright` |

## Scripts

| Script                | Description                                            |
| --------------------- | ------------------------------------------------------ |
| `npm run build`       | Bundle `src/main.ts` → `public/js/main.js` (esbuild)  |
| `npm run dev`         | Build + run `wrangler pages dev` locally              |
| `npm run deploy`      | Build + `wrangler pages deploy` to production         |
| `npm run db:init`     | Apply `schema.sql` to the **remote** D1               |

## Notes

- The Three.js bundle is ~510 KB (minified). If you need a smaller payload,
  consider switching to `three`'s `import { WebGLRenderer, Scene, ... } from
  'three/src/Three.js'` tree-shakeable entry or to a lighter library like
  `OGL`.
- The custom cursor, magnetic buttons, and tilt cards auto-disable on
  touch devices (`@media (hover: none)`).
- `prefers-reduced-motion` disables all animations and reveals.
- All admin cookies are `HttpOnly; Secure; SameSite=Lax`.
