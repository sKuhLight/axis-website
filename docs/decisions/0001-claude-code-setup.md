# ADR-0001: Claude Code baseline setup for axis-website

- **Status:** Accepted
- **Date:** 2026-07-17
- **Owners:** axis-website maintainers

## Context

axis-website is the Cloudflare Worker that serves axisapp.live: `worker.js` +
`wrangler.jsonc` with Static Assets under `public/`. It has properties that make
unassisted automated edits risky:

- **Generated-SPA footgun.** The Axis remote web app in `public/` — `index.html`,
  `_app/**`, `service-worker.js`, `manifest.webmanifest`, the icons/favicon, and
  `version.json` — is GENERATED in the Axis repo (`VITE_AXIS_REMOTE=1 npm run
  build`) and committed here by Axis's `deploy-remote` GitHub Action. Hand-editing
  any of it is silently lost on the next deploy commit and masks the real source.
  Only a small hand-owned set is editable here (`worker.js`, `wrangler.jsonc`, the
  legal/landing HTML pages, `style.css`, `_headers`).
- **Push is a production deploy.** The Worker is wired to Cloudflare's git
  integration, so `git push` to this repo IS a live deploy of axisapp.live — there
  is no separate deploy step to gate.
- **Release-channel role.** This repo is stage 4 (the end) of the product release
  chain: the site serves the last PUBLISHED Axis release at its tag, not HEAD. The
  deploy bot pushes SPA commits to `master` frequently, and hand edits happen on
  short-lived branches that are rebased onto `origin/master` before pushing.

Separately, the project family that includes this repo adopted a single central
task tracker (Plane) so active and planned work — goals, rationale, status — is
recorded in one place rather than scattered across chat context and TODO comments.

## Decision

Adopt the family-wide Claude Code baseline for this repo:

- **Committable `CLAUDE.md` + private `CLAUDE.local.md` split.** A committable
  `CLAUDE.md` documents the repo, the generated/hand-owned split, the validation
  gate, and deploy/drift discipline. All workspace-private context — the Plane
  project/workspace identifiers and server URL, and the sibling-workspace helper
  scripts — lives only in `CLAUDE.local.md`, which stays gitignored. This keeps
  private coordinates out of a repo whose pushes deploy a public site.
- **Generated-SPA guard.** `.claude/settings.json` denies edits to
  `public/index.html` and `public/_app/**`, and a `PreToolUse` `guard-generated.sh`
  hook blocks Edit/Write to the whole generated set (also `service-worker.js`,
  `manifest.webmanifest`, icons/favicon, `version.json`). The guard's message
  points to re-running Axis's deploy-remote Action rather than hand-fixing output.
- **Push-is-deploy gating.** `git push` is set to `ask`, and `guard-bash.sh` hard-
  blocks any `wrangler deploy` that is not a `--dry-run`, plus force-push and
  redirects/`sed -i`/`tee` writes onto generated files. Only
  `wrangler deploy --dry-run` (the CI validation) runs freely.
- **Subagents.** `reviewer` (read-only diff review: worker routing, security
  headers, wrangler validity, accidental generated-file edits, legal-page
  consistency) and `test-runner` (runs the two CI checks — SPA presence and the
  wrangler dry-run — and reports only failures).
- **`/plan-feature`** slash command that plans changes without editing code and
  enforces the task-tracking step.
- **ADR log** under `docs/decisions/` (this file and the template).
- **Mandatory Plane task tracking** (see CLAUDE.md, "Task tracking"). Project
  identifiers live only in the local-only `CLAUDE.local.md`.

CI (`.github/workflows/validate.yml`) asserts the generated SPA is present and
runs the wrangler dry-run on every push and pull request.

## Alternatives

- **No tooling (status quo).** Rejected: the generated-SPA and push-is-deploy
  footguns keep recurring, with no guardrail to catch them.
- **README-only conventions.** Rejected: documented conventions are not enforced,
  so automated and human edits still violate them.
- **Keeping everything in one committable CLAUDE.md.** Rejected: this repo's pushes
  deploy a public site, so private Plane/server coordinates must not live in a
  committable file — hence the `CLAUDE.local.md` split.

## Consequences

- Agents operate with enforced guardrails (permissions plus hooks), not just
  advice, reducing generated-file mistakes and accidental production deploys.
- Contributors get the conventions written down and reviewable.
- Some files are intentionally local-only and gitignored (`CLAUDE.local.md`,
  `.mcp.json`, `.claude/settings.local.json`). They must be recreated per clone
  from the private family-wide setup guide; a fresh clone will not have
  task-tracking wiring until that is done.
