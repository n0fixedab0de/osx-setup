#!/bin/zsh

ROOT="${1:-.}"

echo "Scanning Git repos under: $ROOT"
echo

for repo in "$ROOT"/*; do
  [[ -d "$repo/.git" ]] || continue

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Repo: $(basename "$repo")"
  cd "$repo" || continue

  current_branch=$(git branch --show-current)

  echo "Fetching..."
  git fetch --all --prune

  if git show-ref --verify --quiet refs/heads/main; then
    if [[ -n "$(git status --porcelain)" ]]; then
      echo "⚠️  Local changes found. Skipping pull for main."
    else
      echo "Updating main..."
      git checkout main >/dev/null 2>&1
      git pull --ff-only
      git checkout "$current_branch" >/dev/null 2>&1 || true
    fi
  else
    echo "⚠️  No local main branch found."
  fi

  stash_count=$(git stash list | wc -l | tr -d ' ')
  if [[ "$stash_count" -gt 0 ]]; then
    echo "📦 Stashes found: $stash_count"
    git stash list
  else
    echo "No stashes."
  fi

  echo
done