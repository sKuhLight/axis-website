# axis-website — Claude Code Context

Everything served at **axisapp.live**: a Cloudflare **Worker** (`worker.js`) with
**Static Assets** (`wrangler.jsonc`, `assets.directory: ./public`). It hosts the
Axis remote web app (a static SPA) plus a few hand-maintained legal/landing pages.
There is no build step, no `package.json`, and no runtime dependencies — wrangler
runs via `npx`.

## Architecture

- **`worker.js`** — the Worker entry point. It is intentionally minimal: `fetch`
  delegates to the Static Assets binding (`env.ASSETS.fetch(request)`). A pure
  static-assets Worker could omit it, but a real entry point is the most
  compatible with the git-connected Workers Builds flow. Any request routing,
  redirects, or header logic added later lives here.
- **`wrangler.jsonc`** — Worker config. `name` MUST match the Worker's name in the
  Cloudflare dashboard or the git build fails. `main: worker.js`,
  `assets.directory: ./public`, `assets.binding: ASSETS`, and
  `not_found_handling: single-page-application` so any unmatched path falls back to
  the SPA `index.html`. Real files (legal pages, `_app` assets) are matched first,
  so the SPA fallback only catches genuine misses; clean URLs work
  (`/imprint` → `public/imprint.html`).
- **`public/_headers`** — Cloudflare static-asset headers: `X-Content-Type-Options`,
  `X-Frame-Options`, `Referrer-Policy`, and `Permissions-Policy: midi=(self),
  serial=(self)` (the web app needs Web MIDI / Web Serial).

### GENERATED vs. hand-owned (critical)

The `public/` tree is split. Get this wrong and your edits are silently lost.

- **GENERATED — never hand-edit here.** Built in the **Axis** repo
  (`VITE_AXIS_REMOTE=1 npm run build`) and committed here by Axis's `deploy-remote`
  GitHub Action:
  - `public/index.html`
  - `public/_app/**` (the whole SPA bundle)
  - `public/service-worker.js`, `public/manifest.webmanifest`
  - `public/icon.svg`, `public/icon-192.png`, `public/icon-512.png`,
    `public/apple-touch-icon.png`, `public/favicon.png`
  - `public/version.json` (and `public/_app/version.json`)

  To change any of these, change the Axis source and re-run its deploy-remote
  Action — do NOT edit the output here. Edits to these are blocked by the deny-list
  in `.claude/settings.json` and the `guard-generated.sh` hook.
- **Hand-owned — edit here.** `worker.js`, `wrangler.jsonc`,
  `public/welcome.html`, `public/imprint.html`, `public/privacy.html`,
  `public/terms.html`, `public/style.css`, `public/_headers`.

## Commands

- **Local serving:** `npx --yes wrangler@4 dev`
- **Validation gate (mirror of CI — run before pushing).** Two checks:
  1. **SPA present:** `public/index.html` and `public/welcome.html` exist and
     `public/_app/` is non-empty. If missing, a bad deploy commit clobbered the
     SPA — re-run Axis's deploy-remote Action; never hand-create files in `public/`.
  2. **Wrangler config validates:**
     `WRANGLER_SEND_METRICS=false npx --yes wrangler@4 deploy --dry-run`
     (compiles the Worker + validates `wrangler.jsonc`, no Cloudflare auth). The
     first run may download wrangler via npx — expected.

  The `test-runner` agent runs both and reports only failures. CI lives on
  `master` (`.github/workflows/validate.yml`) and reaches branches via rebase.

## Deploy & drift discipline

- **`git push` here IS a production deploy** — the Worker is wired to Cloudflare's
  git integration, so every push auto-deploys axisapp.live. There is no separate
  deploy step. `wrangler deploy` (non-dry-run) is blocked by `guard-bash.sh`.
- This repo is **stage 4** (the end) of the product release chain — the site is a
  **release channel**, serving the last PUBLISHED Axis release at its tag, not
  HEAD. Canonical release doc: the Axis repo's `docs/RELEASING.md`.
- Content arrives two ways: **bot commits** from Axis's `deploy-remote` Action (the
  SPA, pushed to `master` frequently) and **hand edits** to the legal/landing pages
  + `worker.js`/`wrangler.jsonc` (on short-lived branches rebased onto `origin/master`).
- **Pre-flight:** `git fetch origin` before starting — the deploy bot pushes to
  `master` often, so local checkouts drift fast. Rebase hand-edit branches onto
  `origin/master` before pushing.
- If CI fails after a deploy commit, the SPA was clobbered — **re-run Axis's
  deploy-remote Action; never hand-fix `public/`.**

## Coding standards

- Vanilla JS in `worker.js` (no framework, no bundler, no build step); plain
  HTML/CSS for the legal/landing pages. Match the existing style of the file you
  are touching.
- **No new dependencies, no `package.json`, no frameworks.** wrangler stays an
  `npx` invocation.
- No AI/Claude attribution anywhere (code, comments, commits).

## Pitfalls

- Editing anything in the GENERATED set (above) — it is overwritten on the next
  deploy commit and your change vanishes.
- Forgetting to `git fetch` / rebase onto `origin/master` before pushing — you can
  clobber bot deploy commits.
- Changing `wrangler.jsonc` `name` so it no longer matches the Cloudflare Worker →
  git build fails.
- Weakening `public/_headers` (dropping `Permissions-Policy` breaks Web MIDI/Serial
  in the web app).
- Leaving `[PLACEHOLDER]` fields in the legal pages, or letting operator/contact
  details drift out of sync across imprint/privacy/terms.

## Git and commits

- Commit as `sKuhLight <sKuhLight@users.noreply.github.com>`.
- Message format: `<scope>: <imperative>`. No AI attribution.
- Commit/push **only when explicitly asked** — and **push is doubly gated because
  push = production deploy.** Confirm the branch is rebased onto `origin/master`
  and CI-clean before any push.
- Never commit `CLAUDE.local.md`, `.mcp.json`, capture methods, or private URLs.

## Task tracking (Plane — MANDATORY)

Plane is the **single source of truth for active and planned tasks** across the
FractalAudio repos: search the right project for an existing item first, create one
if missing (imperative title; goal + why + acceptance criteria), move it to
**In Progress** at start, and comment + set **Done** on completion. The Plane
project/workspace coordinates and the full workspace-private policy live in
`CLAUDE.local.md` (gitignored) — never put project UUIDs, the Plane server URL, or
other private coordinates in this committable file.
