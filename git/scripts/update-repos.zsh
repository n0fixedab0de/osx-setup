#!/bin/zsh

ROOT="${1:-.}"

repos_with_stash=()
repos_with_diverged_branch=()
repos_with_local_changes=()
repos_with_no_main_or_master=()

echo "Scanning Git repos under: $ROOT"
echo

for repo in "$ROOT"/*; do
  [[ -d "$repo/.git" ]] || continue

  repo_name="$(basename "$repo")"

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Repo: $repo_name"
  cd "$repo" || continue

  current_branch=$(git branch --show-current)

  echo "Fetching..."
  git fetch --all --prune

  target_branch=""

  if git show-ref --verify --quiet refs/heads/main; then
    target_branch="main"
  elif git show-ref --verify --quiet refs/heads/master; then
    target_branch="master"
  fi

  if [[ -n "$target_branch" ]]; then
    if [[ -n "$(git status --porcelain)" ]]; then
      echo "⚠️  Local changes found. Skipping pull for $target_branch."
      repos_with_local_changes+=("$repo_name")
    else
      echo "Updating $target_branch..."
      git checkout "$target_branch" >/dev/null 2>&1

      pull_output=$(git pull --ff-only 2>&1)
      pull_exit_code=$?

      echo "$pull_output"

      if [[ $pull_exit_code -ne 0 ]]; then
        if echo "$pull_output" | grep -qi "Diverging branches can't be fast-forwarded"; then
          echo "🚨 Diverged branch detected: $target_branch"
          repos_with_diverged_branch+=("$repo_name ($target_branch)")
        else
          echo "⚠️ Pull failed for $target_branch."
        fi
      fi

      if [[ -n "$current_branch" && "$current_branch" != "$target_branch" ]]; then
        git checkout "$current_branch" >/dev/null 2>&1
      fi
    fi
  else
    echo "⚠️  No local main or master branch found."
    repos_with_no_main_or_master+=("$repo_name")
  fi

  stash_count=$(git --no-pager stash list | wc -l | tr -d ' ')

  if [[ "$stash_count" -gt 0 ]]; then
    echo "📦 Stashes found: $stash_count"
    git --no-pager stash list
    repos_with_stash+=("$repo_name")
  else
    echo "No stashes."
  fi

  echo
done


print_summary () {
  local title="$1"
  shift
  local items=("$@")

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$title"
  echo

  if [[ ${#items[@]} -eq 0 ]]; then
    echo "None 🎉"
  else
    for item in "${items[@]}"; do
      echo "- $item"
    done
  fi

  echo
}

print_summary "Repos with stashes 📦" "${repos_with_stash[@]}"
print_summary "Repos with diverged main/master branches 🚨" "${repos_with_diverged_branch[@]}"
print_summary "Repos with local uncommitted changes ⚠️" "${repos_with_local_changes[@]}"
print_summary "Repos with no main/master branch 🧭" "${repos_with_no_main_or_master[@]}"