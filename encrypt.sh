#!/usr/bin/env bash
# Encrypts all HTML files in this trips repo with StatiCrypt.
# Run this AFTER copying fresh plain HTML from trips-preview, BEFORE git push.
#
# Usage: ./encrypt.sh
# Requires: staticrypt (npm install -g staticrypt)
# Password is read from STATICRYPT_PASSWORD env (set below).

set -e

cd "$(dirname "$0")"

if ! command -v staticrypt >/dev/null 2>&1; then
  echo "❌ staticrypt not found. Run: npm install -g staticrypt"
  exit 1
fi

# Password is read from .staticrypt.password (gitignored, NEVER committed).
# To rotate: edit that file + re-run.
PWFILE="$(dirname "$0")/.staticrypt.password"
if [ ! -f "$PWFILE" ]; then
  echo "❌ Missing $PWFILE — create it with the password as its only content."
  exit 1
fi
export STATICRYPT_PASSWORD="$(cat "$PWFILE" | tr -d '\n')"

REMEMBER_DAYS=365
TITLE="Sam & Kayniss · Private Trips"
INSTRUCTIONS="Private page · enter password to view"
BUTTON="UNLOCK"
COLOR_PRIMARY="#1a1a1a"
COLOR_SECONDARY="#fafaf7"

# Find every HTML file in the repo (excluding .git), portable to macOS bash 3.2
COUNT=0
while IFS= read -r f; do
  dir=$(dirname "$f")
  echo "  → $f"
  staticrypt "$f" \
    --short \
    --remember "$REMEMBER_DAYS" \
    -d "$dir" \
    --template-title "$TITLE" \
    --template-instructions "$INSTRUCTIONS" \
    --template-button "$BUTTON" \
    --template-color-primary "$COLOR_PRIMARY" \
    --template-color-secondary "$COLOR_SECONDARY" \
    > /dev/null
  COUNT=$((COUNT + 1))
done < <(find . -type f -name "*.html" -not -path "./.git/*")

if [ $COUNT -eq 0 ]; then
  echo "ℹ️  No HTML files found."
  exit 0
fi

echo "✅ Done. Encrypted $COUNT file(s) in-place."
echo "📝 Source of truth (plain HTML): ~/Documents/trips-preview/"
echo "🌐 Next: git add . && git commit && git push"
