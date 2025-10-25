---
name: create-pr
description: Analyze local git changes and create a structured GitHub pull request.
usage: /create-pr [-d|--draft] [-b|--base <branch>] [-r|--reviewer <user> ...] [--no-push] [--assign-me]
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
  - name: --assign-me
    type: boolean
    description: Attempt to assign the PR to yourself (@me). If not permitted, PR creation still succeeds without assignment.
permissions:
  - command: git
  - command: gh
---

# Create Pull Request

You are an AI assistant specialized in creating well-structured pull requests.

## Instructions

### 1. Prepare Environment

Run the preparation script to detect the default branch and gather git information:

```bash
source ./scripts/pr-prepare.sh
```

This script exports `BASE_BRANCH` and `CURRENT_BRANCH` environment variables for use in subsequent steps.

### 2. Analyze Changes

Get the detailed diff of changes:

```bash
git diff "origin/${BASE_BRANCH}"...HEAD 2>/dev/null || git diff HEAD~5...HEAD
```

### 3. Security Check & PR Generation

**IMPORTANT**: Analyze the diff for potential secrets or sensitive data before creating the PR.

Check for these patterns:

- **API Keys**: AWS keys (AKIA*, AWS\_*), Google API keys, Azure keys
- **Tokens**: GitHub tokens (ghp*\*, gho*_, ghs\__), OAuth tokens, JWT tokens
- **Credentials**: Passwords, authentication strings, database credentials
- **Private Keys**: RSA private keys (-----BEGIN PRIVATE KEY-----)
- **Environment Variables**: Hardcoded `PASSWORD`, `SECRET`, `TOKEN`, `API_KEY`
- **Connection Strings**: Database URLs with embedded credentials

**If secrets are detected**:

1. Stop immediately and warn the user with:
   - The type of potential secret
   - File location
   - A masked snippet
2. Ask for confirmation to proceed (NOT recommended) or cancel

**If no secrets detected, create the PR**:

1. **Generate PR Title**:

   - Use imperative mood (e.g., "Add feature", not "Added feature")
   - Keep under 72 characters
   - Summarize the main purpose

2. **Generate PR Description** using this format:

```markdown
## Summary

[Brief overview in 1-3 sentences]

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

### 4. Create the Pull Request

Call the PR creation script with the generated title and body:

```bash
./scripts/pr-create.sh "$PR_TITLE" "$PR_BODY"
```

The script will:

- Push the branch to remote (unless `--no-push` was specified via `NO_PUSH=true`)
- Create the PR using `gh pr create` with the appropriate flags
- Handle `--draft` mode via `DRAFT_MODE=true`
- Add reviewers via `REVIEWERS="user1,user2"`
- Assign to yourself via `ASSIGN_ME=true` (with automatic fallback if repository doesn't allow assignment)

### 5. Report Results

After creating the PR:

- Display the PR URL
- Provide a summary of what was created
- If errors occurred, explain them clearly and suggest next steps

## Error Handling

If any step fails:

1. Explain what went wrong with the exact error message
2. Suggest actionable solutions
3. Ask if the user wants to try an alternative approach
