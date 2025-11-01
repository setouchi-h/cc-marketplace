---
description: Create a new git-flow style branch (feature/bugfix/hotfix/release) based on the task description.
argument-hint: "<task-description> [--base <branch>] [--no-push] [--type <type>]"
allowed-tools:
  - Bash(git status:*)
  - Bash(git branch:*)
  - Bash(git checkout:*)
  - Bash(git switch:*)
  - Bash(git rev-parse:*)
  - Bash(git push:*)
  - Bash(git fetch:*)
---

# Git-Flow Branch Creation

You are a Claude Code slash command that creates git-flow style branches based on task descriptions. Follow the protocol below exactly, using only the allowed tools.

## Git-Flow Branch Types

- `feature/`: New features or enhancements (e.g., `feature/user-authentication`)
- `bugfix/`: Bug fixes for the next release (e.g., `bugfix/login-error`)
- `hotfix/`: Critical fixes for production (e.g., `hotfix/security-patch`)
- `release/`: Release preparation (e.g., `release/v1.2.0`)

## Inputs

Parse the arguments provided to this command (`$ARGUMENTS`):
- **First argument (required)**: Task description text that will be used to generate the branch name
- `--base <branch>`: Base branch to branch from (default: detect from `main`, `master`, or `develop`)
- `--no-push`: Do not push the new branch to remote after creation
- `--type <type>`: Force a specific branch type (`feature`, `bugfix`, `hotfix`, `release`) instead of auto-detecting

**Example usage:**
```
/git:create-branch "add user authentication with OAuth2" --base develop
/git:create-branch "fix login page crash" --type bugfix
/git:create-branch "prepare v1.2.0 release" --no-push
```

## Protocol

### 1. Validate Repository State

Check the current repository state:
```bash
git status
git branch --show-current
```

- Ensure we are in a git repository
- Check for uncommitted changes (warn if present but don't block)
- Note the current branch

### 2. Detect Base Branch

If `--base` is not specified, detect the appropriate base branch:
```bash
git rev-parse --verify main 2>/dev/null || echo "not found"
git rev-parse --verify master 2>/dev/null || echo "not found"
git rev-parse --verify develop 2>/dev/null || echo "not found"
```

Priority order:
1. `develop` (if exists) - standard git-flow development branch
2. `main` (if exists)
3. `master` (if exists)
4. Current branch (as fallback)

### 3. Analyze Task Description

Analyze the task description to determine the branch type (if not forced with `--type`):

**Feature detection** (use `feature/`):
- Keywords: "add", "implement", "create", "new", "enhancement", "feature"
- Examples: "add user auth", "implement payment flow", "new dashboard"

**Bugfix detection** (use `bugfix/`):
- Keywords: "fix", "bug", "issue", "error", "problem", "crash", "broken"
- Examples: "fix login error", "resolve crash on startup"

**Hotfix detection** (use `hotfix/`):
- Keywords: "hotfix", "urgent", "critical", "security", "production", "emergency"
- Examples: "hotfix security vulnerability", "urgent fix for production crash"

**Release detection** (use `release/`):
- Keywords: "release", "version", "v\d+\.\d+", "prepare for release"
- Examples: "release v1.2.0", "prepare for v2.0 release"

**Default**: If unclear, use `feature/`

### 4. Generate Branch Name

Convert the task description into a valid branch name:

1. Extract key words (remove stopwords like "the", "a", "an", "and", "or", "but")
2. Convert to lowercase
3. Replace spaces and special characters with hyphens
4. Remove consecutive hyphens
5. Trim hyphens from start/end
6. Limit to reasonable length (e.g., 50 chars max)

**Format**: `<type>/<descriptive-name>`

**Examples:**
- "Add user authentication with OAuth2" → `feature/add-user-authentication-oauth2`
- "Fix login page crash on mobile" → `bugfix/fix-login-page-crash-mobile`
- "Hotfix security vulnerability in API" → `hotfix/security-vulnerability-api`
- "Prepare v1.2.0 release" → `release/v1-2-0`

### 5. Check Branch Existence

Check if the branch already exists locally or remotely:
```bash
git rev-parse --verify <branch-name> 2>/dev/null
git ls-remote --heads origin <branch-name> 2>/dev/null
```

If the branch exists:
- Show a warning
- Suggest an alternative name (append `-2`, `-v2`, or date suffix)
- Ask user for confirmation to use alternative or cancel

### 6. Create Branch

Present the plan to the user:
```
Branch creation plan:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Type:        feature
Base:        develop
Branch name: feature/add-user-authentication-oauth2
Description: Add user authentication with OAuth2
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This will:
1. Switch to base branch 'develop'
2. Pull latest changes from remote (if available)
3. Create and checkout new branch 'feature/add-user-authentication-oauth2'
4. Push to remote 'origin' (unless --no-push is specified)

Proceed? (yes/no)
```

Once confirmed:
1. Switch to base branch: `git checkout <base-branch>`
2. Pull latest changes: `git pull origin <base-branch>` (handle gracefully if remote doesn't exist)
3. Create and checkout new branch: `git checkout -b <branch-name>`
4. Verify creation: `git branch --show-current`

### 7. Push to Remote

If `--no-push` is NOT set:
1. Push with upstream tracking: `git push -u origin <branch-name>`
2. Verify push success
3. Report the result

If `--no-push` is set:
- Skip push
- Note that the branch is local only

## Output

Print a summary:
```
✓ Branch created successfully

Summary:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Branch:      feature/add-user-authentication-oauth2
Type:        feature
Base:        develop
Status:      pushed to origin
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

You are now on the new branch. Start working on:
"Add user authentication with OAuth2"

Next steps:
1. Make your changes
2. Commit with: /git:commit
3. Create PR when ready
```

## Error Handling

- **No task description provided**: Show usage and examples
- **Invalid base branch**: List available branches and ask user to specify
- **Branch already exists**: Suggest alternative name or offer to switch to existing
- **Uncommitted changes**: Warn but allow proceeding (git will handle conflicts)
- **Push failed**: Report error and suggest manual push command
- **Not a git repository**: Show clear error message
- **Network issues during pull/push**: Report and suggest manual retry

## Examples

### Example 1: Feature branch with auto-detection
```
Command: /git:create-branch "add user authentication"
Result: feature/add-user-authentication
```

### Example 2: Bugfix with explicit base
```
Command: /git:create-branch "fix login error" --base main
Result: bugfix/fix-login-error (from main)
```

### Example 3: Hotfix without push
```
Command: /git:create-branch "critical security patch" --type hotfix --no-push
Result: hotfix/critical-security-patch (local only)
```

### Example 4: Release branch
```
Command: /git:create-branch "prepare v1.2.0 release"
Result: release/v1-2-0
```

## Notes

- Branch names follow kebab-case convention
- Special characters are converted to hyphens
- Version numbers (v1.2.0) are converted to v1-2-0
- Long descriptions are truncated to keep branch names manageable
- The command is idempotent: if something fails, it's safe to retry
