#!/usr/bin/env bash
set -euo pipefail

# Error handler
die() { echo "Error: $*" >&2; exit 1; }

# Ensure required environment variables are set
[ -n "${BASE_BRANCH:-}" ] || die "BASE_BRANCH environment variable is not set. Run pr-prepare.sh first."

# Get PR title and body from arguments
if [ $# -lt 2 ]; then
  die "Usage: $0 <title> <body>"
fi

PR_TITLE="$1"
PR_BODY="$2"

# Push branch to remote (unless --no-push was specified)
if [ "${NO_PUSH:-false}" = "false" ]; then
  echo "Pushing branch to remote..."

  CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || true)
  [ -n "$CURRENT_BRANCH" ] || die "Could not determine the current branch."

  # If no upstream is set, push and set upstream
  if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
    git push -u origin "$CURRENT_BRANCH" || die "Failed to push and set upstream."
  else
    # Upstream exists; push if there are changes
    git push || die "Failed to push to upstream."
  fi
else
  echo "Skipping push due to --no-push flag."
fi

# Create temporary files for PR title and body (to prevent command injection)
TITLE_FILE=$(mktemp "${TMPDIR:-/tmp}/pr-title.XXXXXX")
BODY_FILE=$(mktemp "${TMPDIR:-/tmp}/pr-body.XXXXXX")
trap 'rm -f "$TITLE_FILE" "$BODY_FILE"' EXIT

# Write title and body to temporary files
printf '%s' "$PR_TITLE" > "$TITLE_FILE"
printf '%s' "$PR_BODY" > "$BODY_FILE"

# Build gh pr create command
TITLE_CONTENT=$(<"$TITLE_FILE")
GH_CMD=(gh pr create --base "$BASE_BRANCH" --title "$TITLE_CONTENT" --body-file "$BODY_FILE")

# Add --draft flag if specified
if [ "${DRAFT_MODE:-false}" = "true" ]; then
  GH_CMD+=(--draft)
fi

# Add reviewers if specified
if [ -n "${REVIEWERS:-}" ]; then
  reviewers_str=${REVIEWERS//,/ }  # Normalize commas to spaces
  read -r -a _reviewers <<< "$reviewers_str"
  for reviewer in "${_reviewers[@]}"; do
    reviewer=$(printf '%s' "$reviewer" | xargs)  # Trim whitespace
    if [ -n "$reviewer" ]; then
      GH_CMD+=(--reviewer "$reviewer")
    fi
  done
fi

# Add --assignee @me if specified, with fallback if assignment fails
if [ "${ASSIGN_ME:-false}" = "true" ]; then
  echo "Creating pull request and attempting to assign to yourself..."
  # Try with --assignee @me first
  if ! "${GH_CMD[@]}" --assignee @me 2>/dev/null; then
    echo "Warning: Could not assign PR to yourself (repository may not allow it). Creating PR without assignment..." >&2
    # Retry without assignment
    "${GH_CMD[@]}"
  fi
else
  # Execute the command without assignment
  echo "Creating pull request..."
  "${GH_CMD[@]}"
fi
