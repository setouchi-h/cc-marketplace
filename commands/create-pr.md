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
    description: Use an alternate base branch instead of the repository default.
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
# Check current branch and status
git status

# Get the current branch name
git branch --show-current

# Check if the branch has a remote tracking branch
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "No upstream branch"

# Determine the base branch
# Priority: (1) --base flag exported as BASE_BRANCH, (2) origin/HEAD, (3) GitHub default_branch, (4) fallback to main
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
  BASE_BRANCH=${DEFAULT_BRANCH:-main}
fi
echo "Using base branch: ${BASE_BRANCH}"

# Get recent commits on this branch (not in main/master)
git log --oneline --no-merges "origin/${BASE_BRANCH}"..HEAD 2>/dev/null || git log --oneline -10

# Get the diff summary
git diff --stat "origin/${BASE_BRANCH}"...HEAD 2>/dev/null || git diff --stat HEAD~5..HEAD
```

### 2. Analyze Changes in Detail

Get a detailed view of the changes:

```bash
# Get the detailed diff
git diff "origin/${BASE_BRANCH}"...HEAD 2>/dev/null || git diff HEAD~5..HEAD
```

### 3. Generate PR Content

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

### 4. Ensure Branch is Pushed

Before creating the PR, make sure your branch is on the remote. Skip this step entirely if `--no-push` was provided.

```bash
# Skip if --no-push was provided (set NO_PUSH=true in scripts)
if [ "${NO_PUSH:-false}" = "true" ]; then
  echo "Skipping push due to --no-push."
else
  CURRENT_BRANCH=$(git branch --show-current)
  # If no upstream is set, push and set upstream
  if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
    git push -u origin "$CURRENT_BRANCH"
  else
    # If local branch is ahead, push; otherwise do nothing
    if [ -n "$(git log --oneline @{u}..HEAD)" ]; then
      git push
    else
      echo "No new commits to push."
    fi
  fi
fi
```

If the push fails, report the error and ask the user to resolve conflicts or authentication issues. If `--no-push` was used but no upstream exists, clearly surface that the PR cannot be created until the branch is available on the remote (push manually or rerun without `--no-push`).

### 5. Create the Pull Request

Use the GitHub CLI to create the PR:

```bash
gh pr create --base "${BASE_BRANCH}" --title "PR_TITLE" --body "$(cat <<'EOF'
PR_DESCRIPTION_HERE
EOF
)"
```

Important notes:

- Replace `PR_TITLE` with the generated title
- Replace `PR_DESCRIPTION_HERE` with the full PR description
- Use a HEREDOC to ensure proper formatting of the description
- The PR will be created against the detected base branch (`${BASE_BRANCH}`), or the one provided via `--base`.

### 6. Handle the Result

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
- `-b, --base <branch>`: Specify the base branch
- `-r, --reviewer <users>`: Add reviewers
- `--no-push`: Skip pushing the branch (assume it's already pushed)

When these options are provided, incorporate them into the gh pr create command appropriately.
