#!/usr/bin/env bash
# PreToolUse guard for Bash: block destructive commands, production deploys, and
# writes that clobber the generated SPA. Exits 2 with a one-line reason on stderr
# to block; exits 0 otherwise.
set -euo pipefail

raw="$(cat)"

if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$raw" | jq -r '.tool_input.command // ""')"
else
  # Conservative fallback: scan the whole raw payload.
  cmd="$raw"
fi

block() { echo "guard-bash: blocked - $1" >&2; exit 2; }

# rm -rf targeting / or ~ (root or home)
if printf '%s' "$cmd" | grep -Eq 'rm[[:space:]]+(-[A-Za-z]*[[:space:]]+)*-?[A-Za-z]*[rR][A-Za-z]*f|rm[[:space:]]+-[A-Za-z]*f[A-Za-z]*[rR]'; then
  if printf '%s' "$cmd" | grep -Eq 'rm[[:space:]]+.*[[:space:]](/|~|\$HOME)([[:space:]]|/|$)'; then
    block "rm -rf targeting / or home"
  fi
fi

# git force push (--force, --force-with-lease, or short -f flag)
if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+push' \
   && printf '%s' "$cmd" | grep -Eq '(--force([[:space:]=]|$)|[[:space:]]-[A-Za-z]*f[A-Za-z]*([[:space:]]|$))'; then
  block "git push --force is not allowed"
fi

# Cloudflare deploy = production deploy (this repo has no manual deploy step;
# push is the real deploy). Block any `wrangler deploy` UNLESS it is a --dry-run.
# Matches plain `wrangler deploy` and `npx [--yes] wrangler[@ver] deploy`.
if printf '%s' "$cmd" | grep -Eq 'wrangler(@[^[:space:]]*)?[[:space:]]+deploy([[:space:]]|$)'; then
  if ! printf '%s' "$cmd" | grep -Eq -- '--dry-run'; then
    block "wrangler deploy is a production deploy - only 'wrangler deploy --dry-run' runs here"
  fi
fi

# In-place writes / redirects onto the generated SPA (owned by Axis deploy-remote)
gen='(public/_app/|public/index\.html|public/service-worker\.js|public/manifest\.webmanifest|public/icon\.svg|public/icon-192\.png|public/icon-512\.png|public/apple-touch-icon\.png|public/favicon\.png|public/version\.json)'
if printf '%s' "$cmd" | grep -Eq "(sed[[:space:]]+-i|tee)[^|]*$gen"; then
  block "in-place write to a generated SPA file - re-run Axis's deploy-remote Action instead"
fi
if printf '%s' "$cmd" | grep -Eq '(>>?)[[:space:]]*[^|&>]*'"$gen"; then
  block "redirect onto a generated SPA file - re-run Axis's deploy-remote Action instead"
fi

exit 0
