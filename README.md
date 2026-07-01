# axis-website

Static site for **axisapp.live** — landing page + legal documents (Privacy, Terms, Imprint) for [Axis](https://github.com/sKuhLight/Axis).

Plain static HTML/CSS, **no build step**.

## Deploy (Cloudflare Pages)
1. Cloudflare dashboard → **Workers & Pages → Create → Pages → Connect to Git** → pick this repo.
2. Build settings: **Framework preset: None**, **Build command: (empty)**, **Build output directory: `/`** (root).
3. Deploy. Then **Custom domains → add `axisapp.live`** and follow the DNS step.

Clean URLs work automatically — Cloudflare serves `imprint.html` at `/imprint`, etc.

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
