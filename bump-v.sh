#!/usr/bin/env bash
# bump-v.sh — auto-increment the cache-bust ?v= integer across the Fleetwood viewer
# chassis index.html + report-config.js. Run from /tmp/strategy-cadet-decks/.
#
# Usage:
#   ./bump-v.sh                 # bump v in fleetwood-viewer
#   ./bump-v.sh nothing-viewer  # bump v in a specific viewer subdir
#
# Stages the changed files via git add. Caller still runs git commit + push.

set -euo pipefail

VIEWER="${1:-fleetwood-viewer}"
CFG="$VIEWER/report-config.js"
IDX="$VIEWER/index.html"

if [[ ! -f "$CFG" || ! -f "$IDX" ]]; then
  echo "bump-v: missing $CFG or $IDX" >&2
  exit 1
fi

# Read current v from report-config.js (first match wins; all v= values are kept in sync).
CUR=$(grep -oE 'v=[0-9]+' "$CFG" | head -1 | sed 's/v=//')
if [[ -z "$CUR" ]]; then
  echo "bump-v: no v= found in $CFG" >&2
  exit 1
fi

NEXT=$((CUR + 1))
sed -i '' "s/v=$CUR/v=$NEXT/g" "$CFG" "$IDX"

# Verify replacement
COUNT_CFG=$(grep -c "v=$NEXT" "$CFG" || true)
COUNT_IDX=$(grep -c "v=$NEXT" "$IDX" || true)
echo "bump-v: $VIEWER v=$CUR -> v=$NEXT ($COUNT_CFG occurrences in config, $COUNT_IDX in index)"

git add "$CFG" "$IDX"
