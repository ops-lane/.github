#!/usr/bin/env bash
# Create or update the standard ops-lane labels in a repository.
# Usage: ./scripts/setup-labels.sh ops-lane/<repository>
# Requires the GitHub CLI (gh) and an authenticated session (gh auth login).
set -euo pipefail

repo="${1:?Usage: $0 <owner>/<repository>}"

labels=(
  "bug|d73a4a|Something is not working"
  "enhancement|a2eeef|New feature or request"
  "tech-debt|fbca04|Refactoring, cleanup or upgrades"
  "security|b60205|Security issue or hardening task"
)

for entry in "${labels[@]}"; do
  IFS='|' read -r name color description <<< "$entry"
  gh label create "$name" --repo "$repo" --color "$color" --description "$description" --force
done

echo "Labels are up to date in $repo"
