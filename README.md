# axis-website

Everything served at **axisapp.live** for [Axis](https://github.com/sKuhLight/Axis), via a Cloudflare **Worker with Static Assets** (`wrangler.jsonc`, `assets.directory: ./public`).

## Pages
- `/` — the Axis **remote web app** (a static SPA: `public/index.html` + `public/_app/**`). **Generated** — built in the Axis repo (`VITE_AXIS_REMOTE=1 npm run build`) and published here by Axis's `deploy-remote` GitHub Action. Do **not** hand-edit `index.html` / `_app/`.
- `/welcome` — static landing/info page (`welcome.html`).
- `/privacy` · `/terms` · `/imprint` — legal documents (hand-maintained static HTML).

`not_found_handling: single-page-application` in `wrangler.jsonc` makes any unmatched path fall back to the SPA; real files (legal pages, `_app` assets) are matched first, and clean URLs still work (`/imprint` → `imprint.html`).

## Deploy (Cloudflare Workers, git-connected)
The Worker is connected to this repo, so **every push auto-deploys**.

- Custom domain `axisapp.live` is attached to this Worker in the Cloudflare dashboard (Worker → Settings → Domains & Routes).
- Local preview: `npx wrangler dev`. Manual deploy: `npx wrangler deploy`.
- The SPA is updated by the Axis `deploy-remote` Action, which since 2026-07-16 runs when an **Axis release is published**: it builds the app **at that release's tag** with the pinned sibling stack and commits the result here. A push then auto-deploys — so axisapp.live serves the last *published* Axis release, not Axis main HEAD. (Rollback: re-run deploy-remote with an earlier release tag; see `Axis/docs/RELEASING.md`.)

## ⚠ Before this is legally relied upon
The legal pages contain **`[PLACEHOLDER]`** fields. Fill them before launch:
- Real operator **name + reachable address** (Imprint — a pseudonym is not sufficient), and **contact email**.
- Confirm the **Supabase project region** (Privacy §3) and your **Landesdatenschutzbehörde** (§8).
- The **account-deletion path** (§8) and retention numbers (§7).
- Set the real **Last updated** dates.

Not legal advice — have the Terms/liability + any payment clauses reviewed by a lawyer, especially before a paid tier. Canonical source lives in the Axis repo under `legal/`.
