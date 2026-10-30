#!/usr/bin/env bash
# Replaces this game's studio files with the latest ones from the studio template.
# It copies files only: no merge, no commit, and none of the template's history.
# The changes are left staged so you can review them and commit them yourself.
# Usage, from anywhere inside a game repo: bash .claude/scripts/studio-update.sh
set -euo pipefail

STUDIO_URL="${STUDIO_URL:-https://github.com/omzi/claude-code-game-studios.git}"
STUDIO_BRANCH="main"

cd "$(git rev-parse --show-toplevel)"

if ! git remote get-url studio >/dev/null 2>&1; then
  git remote add studio "$STUDIO_URL"
fi
# Never push a game to the template by accident.
git remote set-url --push studio no-push

git fetch --quiet --depth 1 --no-tags studio "$STUDIO_BRANCH"
SOURCE="$(git rev-parse FETCH_HEAD)"

git show "$SOURCE:.claude/studio-paths.txt" | tr -d '\r' | while IFS= read -r path; do
  case "$path" in ''|'#'*) continue ;; esac
  if ! git cat-file -e "$SOURCE:${path%/}" 2>/dev/null; then
    echo "skipped (not in the template): $path"
    continue
  fi
  # Remove the old copy first so files deleted in the template are deleted here too.
  git rm -r -q --cached --ignore-unmatch -- "$path"
  rm -r -- "${path%/}" 2>/dev/null || true
  git checkout "$SOURCE" -- "${path%/}"
  echo "updated: $path"
done

echo
echo "Studio files updated to template commit ${SOURCE:0:7}. Nothing was committed."
git status --short
