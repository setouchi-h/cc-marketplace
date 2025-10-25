---
name: create-pr
description: Analyze local git changes and create a structured GitHub pull request.
usage: /create-pr [-d|--draft] [-b|--base <branch>] [-r|--reviewer <user> ...] [--no-push]
arguments: []
flags:
  - name: --draft
    alias: -d
    type: boolean
    description: Create the pull request as a draft.
  - name: --base
    alias: -b
    type: string
    description: Specify the base branch; required if default cannot be detected.
  - name: --reviewer
    alias: -r
    type: string
    repeatable: true
    description: Add a GitHub username as a reviewer. Provide the flag multiple times to add more than one reviewer.
  - name: --no-push
    type: boolean
    description: Skip pushing the current branch before creating the pull request.
permissions:
  - command: git
  - command: gh
---

# Create Pull Request

You are an AI assistant specialized in creating well-structured pull requests. Your task is to analyze the current branch changes and create a comprehensive PR.

## Instructions

Follow these steps carefully:

### 1. Analyze Current State

First, gather information about the current branch and changes:

```bash
# --- Preflight & graceful error handling ---
die() { echo "Error: $*" >&2; exit 1; }

# Ensure git is available
command -v git >/dev/null 2>&1 || die "git is not installed or not in PATH."

# Ensure we are inside a git repository
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "This command must be run inside a Git repository."

# Check current branch and status (fail clearly if either breaks)
if ! git status >/dev/null 2>&1; then
  die "Failed to run 'git status'. Is the repo in a valid state?"
fi

# Get the current branch name
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || true)
[ -n "$CURRENT_BRANCH" ] || die "Could not determine the current branch. Create/checkout a branch and try again."
echo "Current branch: $CURRENT_BRANCH"

# Check if the branch has a remote tracking branch
git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1 || echo "No upstream branch"

# Determine the base branch
# Priority: (1) --base flag exported as BASE_BRANCH, (2) origin/HEAD, (3) GitHub default_branch; otherwise fail and require explicit --base
# Note: If your tooling exports the --base flag differently, set BASE_BRANCH before running.
if [ -z "${BASE_BRANCH:-}" ]; then
  DEFAULT_BRANCH=""
  # Try local origin/HEAD ref (no network)
  ref=$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null || true)
  if [ -n "$ref" ]; then
    DEFAULT_BRANCH="${ref#origin/}"
  fi
  # Parse from `git remote show origin` if still empty
  if [ -z "$DEFAULT_BRANCH" ]; then
    DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p' | head -n1)
  fi
  # Ask GitHub if gh is available and still unknown
  if [ -z "$DEFAULT_BRANCH" ] && command -v gh >/dev/null 2>&1; then
    DEFAULT_BRANCH=$(gh api repos/:owner/:repo --jq .default_branch 2>/dev/null || true)
  fi
  if [ -z "$DEFAULT_BRANCH" ]; then
    die "Could not determine the repository's default branch. Pass --base <branch> or export BASE_BRANCH."
  fi
  BASE_BRANCH="$DEFAULT_BRANCH"
fi
echo "Using base branch: ${BASE_BRANCH}"

# Get recent commits on this branch (not in base branch)
git log --oneline --no-merges "origin/${BASE_BRANCH}"..HEAD 2>/dev/null || git log --oneline -10

# Get the diff summary
git diff --stat "origin/${BASE_BRANCH}"...HEAD 2>/dev/null || git diff --stat HEAD~5...HEAD
```

### 2. Analyze Changes in Detail

Get a detailed view of the changes:

```bash
# Get the detailed diff
git diff "origin/${BASE_BRANCH}"...HEAD 2>/dev/null || git diff HEAD~5...HEAD
```

### 3. Check for Sensitive Data

**IMPORTANT**: Before creating the PR, analyze the diff for potential secrets or sensitive data.

Check for common secret patterns in the changes:

- **API Keys**: AWS keys (AKIA*, AWS_*), Google API keys, Azure keys, etc.
- **Tokens**: GitHub tokens (ghp_*, gho_*, ghs_*), OAuth tokens, JWT tokens
- **Credentials**: Passwords, authentication strings, database credentials
- **Private Keys**: RSA private keys (-----BEGIN PRIVATE KEY-----)
- **Certificates**: SSL/TLS certificates and keys
- **Environment Variables**: Hardcoded values for `PASSWORD`, `SECRET`, `TOKEN`, `API_KEY`, etc.
- **Connection Strings**: Database URLs with embedded credentials
- **Other Sensitive Data**: Social Security Numbers, credit card numbers, internal URLs

**If potential secrets are detected**:

1. **Stop the PR creation process immediately**
2. **Warn the user clearly** with:
   - The type of potential secret found
   - The file(s) and approximate location
   - A snippet showing the concerning pattern (masked if possible)
3. **Ask for explicit confirmation** before proceeding:
   - "I've detected what appears to be [SECRET_TYPE] in [FILE_PATH]. This could expose sensitive credentials if merged. Would you like to:"
     - "Remove the sensitive data and try again"
     - "Proceed anyway (NOT recommended)"
     - "Cancel the PR creation"

**Only proceed with PR creation if**:
- No secrets are detected, OR
- The user explicitly confirms to proceed after being warned

This security check helps prevent accidental credential exposure in pull requests.

### 4. Generate PR Content

Based on the analysis:

1. **Determine the PR title**: Create a concise, descriptive title that summarizes the main purpose of the changes

   - Use imperative mood (e.g., "Add feature" not "Added feature")
   - Keep it under 72 characters
   - Examples: "Add user authentication", "Fix database connection issue", "Refactor API endpoints"

2. **Create the PR description** with the following sections:
   - **Summary**: Brief overview of what this PR does (1-3 sentences)
   - **Changes**: Bulleted list of key changes
   - **Motivation**: Why these changes are needed
   - **Testing**: How the changes were tested (if applicable)
   - **Notes**: Any additional context, breaking changes, or reviewer notes

### 5. Ensure Branch is Pushed

Before creating the PR, make sure your branch is on the remote. Skip this step entirely if `--no-push` was provided.

```bash
# Skip if --no-push was provided (set NO_PUSH=true in scripts)
if [ "${NO_PUSH:-false}" = "true" ]; then
  echo "Skipping push due to --no-push."
else
  die() { echo "Error: $*" >&2; exit 1; }
  # Ensure we're in a git repo (user may call this step independently)
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "Not a Git repository; cannot push."

  CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || true)
  [ -n "$CURRENT_BRANCH" ] || die "Could not determine the current branch; create/checkout a branch and try again."

  # If no upstream is set, push and set upstream
  if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
    if ! git push -u origin "$CURRENT_BRANCH"; then
      die "Failed to push and set upstream. Check your remote 'origin', auth, and branch permissions."
    fi
  else
    # Upstream exists; rely on git to be no-op if nothing to push
    if ! git push; then
      die "Failed to push to upstream. Resolve conflicts or authentication issues and retry."
    fi
  fi
fi
```

If the push fails, report the error and ask the user to resolve conflicts or authentication issues. If `--no-push` was used but no upstream exists, clearly surface that the PR cannot be created until the branch is available on the remote (push manually or rerun without `--no-push`).

### 6. Create the Pull Request

Use the GitHub CLI to create the PR safely using temporary files to prevent command injection:

```bash
# Create temporary files for PR title and body
TITLE_FILE=$(mktemp "${TMPDIR:-/tmp}/pr-title.XXXXXX")
BODY_FILE=$(mktemp "${TMPDIR:-/tmp}/pr-body.XXXXXX")
# Ensure temporary files are deleted when the script exits (success or failure)
trap 'rm -f "$TITLE_FILE" "$BODY_FILE"' EXIT

# Write the generated title to the temporary file
cat > "$TITLE_FILE" <<'EOF'
PR_TITLE_HERE
EOF

# Write the generated PR description to the temporary file
cat > "$BODY_FILE" <<'EOF'
PR_DESCRIPTION_HERE
EOF

# Build the gh pr create command with conditional flags (array-based for security)
GH_CMD=(gh pr create --base "${BASE_BRANCH}" --title "$(cat "$TITLE_FILE")" --body-file "$BODY_FILE")

# Add --draft flag if DRAFT_MODE is set
if [ "${DRAFT_MODE:-false}" = "true" ]; then
  GH_CMD+=(--draft)
fi

# Add reviewers if REVIEWERS is set (comma or space-separated list)
if [ -n "${REVIEWERS:-}" ]; then
  for reviewer in ${REVIEWERS//,/ }; do
    reviewer=$(echo "$reviewer" | xargs)  # Trim whitespace
    if [ -n "$reviewer" ]; then
      GH_CMD+=(--reviewer "$reviewer")
    fi
  done
fi

# Execute the command
"${GH_CMD[@]}"
```

Important notes:

- Replace `PR_TITLE_HERE` with the generated title
- Replace `PR_DESCRIPTION_HERE` with the full PR description
- Temporary files are used to prevent command injection vulnerabilities from commit messages
- The `trap` command ensures temporary files are cleaned up even if the command fails
- The PR will be created against the detected base branch (`${BASE_BRANCH}`), or the one provided via `--base`
- Set `DRAFT_MODE=true` if the `--draft` flag is provided
- Set `REVIEWERS` as a comma or space-separated list if `--reviewer` flags are provided (e.g., `REVIEWERS="user1 user2"` or `REVIEWERS="user1,user2"`)
- If the default base branch cannot be detected via `origin/HEAD` or the GitHub API, the command fails with an error; pass `--base <branch>` or export `BASE_BRANCH` explicitly.

### 7. Handle the Result

After creating the PR:

- Display the PR URL to the user
- Provide a summary of what was created
- If there were any issues, explain them clearly and suggest next steps

## Example PR Description Format

```markdown
## Summary

[Brief overview of the changes]

## Changes

- [Key change 1]
- [Key change 2]
- [Key change 3]

## Motivation

[Why these changes were needed]

## Testing

- [How changes were tested]
- [Test results or validation steps]

## Notes

[Any additional context, breaking changes, or reviewer notes]
```

## Error Handling

If any step fails:

1. Explain what went wrong
2. Provide the exact error message
3. Suggest actionable solutions
4. Ask the user if they want to try an alternative approach

## Additional Options

The user may provide additional arguments:

- `-d, --draft`: Create as a draft PR
- `-b, --base <branch>`: Specify the base branch (required if default cannot be detected)
- `-r, --reviewer <users>`: Add reviewers
- `--no-push`: Skip pushing the branch (assume it's already pushed)

When these options are provided, incorporate them into the gh pr create command appropriately.
