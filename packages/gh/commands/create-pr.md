---
description: Analyze local git changes and create a structured GitHub pull request.
argument-hint: "[-d|--draft] [-b <branch>] [-r <user> ...] [--no-push] [--no-assign]"
allowed-tools:
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git branch:*)
  - Bash(git rev-parse:*)
  - Bash(git rev-list:*)
  - Bash(gh:*)
  - Bash(git push:*)
---

# Create Pull Request

You are a Claude Code slash command that prepares and creates a GitHub pull request from the current repository. Follow the protocol below exactly, using only the allowed tools.

## Inputs

Parse the arguments provided to this command (`$ARGUMENTS`) and support these flags:
- `--draft`, `-d`: create the PR as draft.
- `--base <branch>`, `-b <branch>`: base branch. If omitted, detect the default branch.
- `--reviewer <user>`, `-r <user>`: may appear multiple times; add each as reviewer.
- `--no-push`: do not push the branch before creating the PR.
- `--no-assign`: skip assigning the PR to yourself (by default, PRs are assigned to `@me`).

## Context Gathering

Use Bash to collect repository context. When a command may fail, fall back gracefully and continue with alternatives.
- Current branch: run `git branch --show-current`.
- Default/base branch detection order:
  1) `--base` flag if provided.
  2) `git ls-remote --symref origin HEAD | awk '/^ref:/ {sub(/refs\\/heads\\//, "", $2); print $2}'` (directly queries remote HEAD).
  3) `git symbolic-ref -q --short refs/remotes/origin/HEAD | sed 's/^origin\\///'` (uses local origin/HEAD if set).
  4) `gh repo view --json defaultBranchRef -q .defaultBranchRef.name` (only if `gh` is installed and authenticated).
  If still unknown, ask the user to specify `--base <branch>` and stop.
- Working tree status: `git status --porcelain` and `git status -sb`.
- Diff summary: `git diff --stat "origin/<base>"...HEAD` (fallback: `git diff --stat HEAD~5...HEAD`).
- Staged vs unstaged changes: `git diff --staged` and `git diff`.
- Ahead/behind: `git rev-list --left-right --count origin/<base>...HEAD` if upstream exists.

## Safety Check

Scan the diff for likely secrets or credentials. Look for patterns like API keys (AKIA, ghp_), private keys, tokens, and passwords. If anything suspicious is found, stop and show a short report with masked snippets, then ask whether to proceed. Default to cancel if the user doesn’t confirm.

## Compose PR

Draft a concise title (<= 72 chars, imperative mood). Create a structured body with the following sections:

```
## Summary
<1–3 sentence overview>

## Changes
- <key change>
- <key change>

## Motivation
<why this change is needed>

## Testing
- <how you validated it>

## Risks
- <potential risks / rollbacks>
```

Confirm the title and body with the user before proceeding.

## Push (optional)

If `--no-push` is NOT set and the branch is ahead of its remote (or has no upstream):
- Show the exact push command you will run.
- Ask for confirmation.
- Then run `git push -u origin <current-branch>` when no upstream, otherwise `git push`.

## Create PR

Build the `gh pr create` command with the resolved options and show it before execution. Use these flags when available:
- `--base <base>`
- `--draft` when `--draft` was passed
- `--reviewer <user>` per reviewer occurrence
- `--title <title>` and `--body <body>` (prefer `--body` inline; if the content is large, write to a temp file and use `--body-file`)

Execute the command and capture the resulting PR URL or number. Unless `--no-assign` was provided, try `gh issue edit <number> --add-assignee @me` afterward; warn but do not fail if assignment is not permitted.

## Output

Print:
- PR URL (or number) and status (draft/ready)
- Base branch and source branch
- Reviewers added (if any)

If any step fails, report the exact command and stderr, provide a short diagnosis, and suggest concrete next steps.

