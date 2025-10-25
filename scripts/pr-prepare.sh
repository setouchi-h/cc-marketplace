#!/usr/bin/env bash
set -euo pipefail

# Error handler
die() { echo "Error: $*" >&2; exit 1; }

# Ensure git is available
command -v git >/dev/null 2>&1 || die "git is not installed or not in PATH."

# Ensure we are inside a git repository
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "This command must be run inside a Git repository."

# Check current branch and status
git status >/dev/null 2>&1 || die "Failed to run 'git status'. Is the repo in a valid state?"

# Get the current branch name
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || true)
[ -n "$CURRENT_BRANCH" ] || die "Could not determine the current branch. Create/checkout a branch and try again."
echo "Current branch: $CURRENT_BRANCH"

# Check if the branch has a remote tracking branch
if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
  echo "No upstream branch"
fi

# Determine the base branch
# Priority: (1) --base flag exported as BASE_BRANCH, (2) origin/HEAD, (3) git remote show, (4) GitHub default_branch
if [ -z "${BASE_BRANCH:-}" ]; then
  DEFAULT_BRANCH=""

  # Ensure 'origin' exists before attempting origin-based detection
  if git remote | grep -qx "origin"; then
    # Use git ls-remote to get the actual remote HEAD (requires network but always accurate)
    head_ref=$(git ls-remote --symref origin HEAD 2>/dev/null | sed -n 's|^ref: refs/heads/\(.*\)\tHEAD$|\1|p' | head -n1)
    if [ -n "$head_ref" ]; then
      DEFAULT_BRANCH="$head_ref"
      echo "Detected default branch from remote: $DEFAULT_BRANCH"
    else
      echo "Warning: Could not detect default branch from 'git ls-remote'." >&2

      # Fallback: Try local origin/HEAD ref (no network)
      ref=$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null || true)
      if [ -n "$ref" ]; then
        DEFAULT_BRANCH="${ref#origin/}"
        echo "Detected default branch from local origin/HEAD: $DEFAULT_BRANCH"
      else
        echo "Warning: origin/HEAD not set locally." >&2
      fi
    fi
  else
    echo "Warning: remote 'origin' not found; skipping origin-based detection." >&2
  fi

  # Ask GitHub if gh is available and still unknown
  if [ -z "$DEFAULT_BRANCH" ]; then
    if command -v gh >/dev/null 2>&1; then
      if gh auth status >/dev/null 2>&1; then
        DEFAULT_BRANCH=$(gh api repos/:owner/:repo --jq .default_branch 2>/dev/null || true)
        if [ -n "$DEFAULT_BRANCH" ]; then
          echo "Detected default branch from GitHub API: $DEFAULT_BRANCH"
        else
          echo "Warning: GitHub API did not return default_branch; check repo access or connectivity." >&2
        fi
      else
        echo "Warning: 'gh' CLI not authenticated; skipping GitHub API lookup." >&2
      fi
    else
      echo "Warning: 'gh' CLI not installed; skipping GitHub API lookup." >&2
    fi
  fi

  # Final validation and guidance
  if [ -z "$DEFAULT_BRANCH" ]; then
    die "Could not determine the repository's default branch. Pass --base <branch> or export BASE_BRANCH. Hints: ensure remote 'origin' exists, set its HEAD via 'git remote set-head origin -a', and/or authenticate GitHub CLI with 'gh auth login'."
  fi
  BASE_BRANCH="$DEFAULT_BRANCH"
fi

echo "Using base branch: ${BASE_BRANCH}"

# Export for use by Claude
export BASE_BRANCH
export CURRENT_BRANCH

# Show recent commits on this branch (not in base branch)
echo -e "\n=== Recent commits on this branch ==="
git log --oneline --no-merges "origin/${BASE_BRANCH}"..HEAD 2>/dev/null || git log --oneline -10

# Show diff summary
echo -e "\n=== Changes summary ==="
git diff --stat "origin/${BASE_BRANCH}"...HEAD 2>/dev/null || git diff --stat HEAD~5...HEAD
