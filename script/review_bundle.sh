#!/usr/bin/env bash
set -euo pipefail
OUT="review_bundle.txt"

# start fresh
: > "$OUT"

find app config \
  \( -path "./node_modules" -o -path "./vendor/bundle" -o -path "./tmp" -o -path "./log" -o -path "./storage" -o -path "./.git" \) -prune -o \
  -type f \( \
      -name "*.rb" -o -name "*.erb" -o -name "*.haml" -o -name "*.slim" -o -name "*.rake" -o -name "*.ru" -o \
      -name "*.js" -o -name "*.ts" -o -name "*.tsx" -o -name "*.css" -o -name "*.scss" -o \
      -name "*.html" -o -name "*.yml" -o -name "*.yaml" -o -name "*.json" -o -name "*.sql" -o -name "*.md" -o \
      -name "*.sh" \
    \) -print0 \
| sort -z \
| while IFS= read -r -d '' f; do
    printf '\n===== BEGIN:%s =====\n' "$f" >> "$OUT"
    # normalize CRLF if present
    sed $'s/\r$//' "$f" >> "$OUT"
    printf '\n===== END:%s =====\n' "$f" >> "$OUT"
  done

printf 'Wrote %s (%s bytes)\n' "$OUT" "$(wc -c < "$OUT")"
