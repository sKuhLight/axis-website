# axis-website

Static site for **axisapp.live** — landing page + legal documents (Privacy, Terms, Imprint) for [Axis](https://github.com/sKuhLight/Axis).

Plain static HTML/CSS in `public/`, served by a Cloudflare **Worker with Static Assets** (no build step, no server code). Config: `wrangler.jsonc` (`assets.directory: ./public`).

## Deploy (Cloudflare Workers, git-connected)
The Worker is connected to this repo, so **every push auto-deploys**. `wrangler.jsonc` tells it to serve `./public` as static assets (this replaces the default "Hello world" worker). Clean URLs work automatically — `/imprint` resolves to `public/imprint.html`.

- Custom domain `axisapp.live` is attached to this Worker in the Cloudflare dashboard (Worker → Settings → Domains & Routes).
- Local preview: `npx wrangler dev`. Manual deploy: `npx wrangler deploy`.

## Pages
- `/` — landing (`index.html`)
- `/privacy` — Privacy Policy (GDPR/DSGVO)
- `/terms` — Terms of Service
- `/imprint` — Imprint / Impressum

## ⚠ Before this is legally relied upon
The legal pages contain **`[PLACEHOLDER]`** fields. Fill them before launch:
- Real operator **name + reachable address** (Imprint — a pseudonym is not sufficient), and **contact email**.
- Confirm the **Supabase project region** (Privacy §3) and your **Landesdatenschutzbehörde** (§8).
- The **account-deletion path** (§8) and retention numbers (§7).
- Set the real **Last updated** dates.

Not legal advice — have the Terms/liability + any payment clauses reviewed by a lawyer, especially before a paid tier. Canonical source lives in the Axis repo under `legal/`.
