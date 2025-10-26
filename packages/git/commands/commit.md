---
description: Analyze changes, create a git-flow style commit message, commit, and push to remote.
argument-hint: "[--no-push] [--scope <scope>] [--type <type>]"
allowed-tools:
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git add:*)
  - Bash(git commit:*)
  - Bash(git push:*)
  - Bash(git branch:*)
  - Bash(git log:*)
  - Bash(git rev-parse:*)
---

# Git Commit with Git-Flow Style

You are a Claude Code slash command that creates git-flow style commit messages and pushes changes to the remote repository. Follow the protocol below exactly, using only the allowed tools.

## Inputs

Parse the arguments provided to this command (`$ARGUMENTS`) and support these flags:
- `--no-push`: do not push after committing.
- `--scope <scope>`: optional scope for the commit message (e.g., "auth", "api", "ui").
- `--type <type>`: force a specific commit type instead of auto-detecting (e.g., "feat", "fix", "docs").

## Git-Flow Commit Types

Use these conventional commit types:
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to the build process or auxiliary tools and libraries such as documentation generation
- `ci`: Changes to CI configuration files and scripts

## Protocol

### 1. Context Gathering

Use Bash to collect repository context:
- Current branch: `git branch --show-current`
- Working tree status: `git status --porcelain` and `git status -sb`
- Staged changes: `git diff --cached --stat`
- Unstaged changes: `git diff --stat`
- Recent commit messages: `git log --oneline -5` (to understand commit style)

### 2. Change Analysis

Analyze the changes to determine:
1. **Commit type**: Automatically detect based on files changed and diff content:
   - New features → `feat`
   - Bug fixes → `fix`
   - Documentation changes (*.md, docs/, README) → `docs`
   - Test files (*.test.*, *.spec.*, __tests__/) → `test`
   - Configuration files (.github/, *.config.*, *.json) → `chore` or `ci`
   - Refactoring without behavior change → `refactor`
   - Performance improvements → `perf`
   - Formatting only → `style`

2. **Scope**: Suggest a scope based on:
   - Directory name (e.g., "packages/auth" → scope: "auth")
   - Module name
   - Feature area
   - If scope is broad or unclear, omit it

3. **Subject**: Create a concise description (max 72 chars, imperative mood, no period at end)

4. **Body**: Optional detailed explanation (wrap at 72 chars):
   - What was changed and why
   - Important implementation details
   - Breaking changes should be noted

### 3. Stage Unstaged Files

If there are unstaged changes:
1. Show the list of unstaged files
2. Ask the user which files to stage (or use `git add .` for all)
3. Stage the selected files using `git add`

### 4. Secret Scanning

Scan the staged diff for potential secrets:
- API keys (patterns like `AKIA`, `ghp_`, `sk-`, etc.)
- Private keys (BEGIN PRIVATE KEY, BEGIN RSA PRIVATE KEY)
- Tokens and passwords
- Environment files (.env) with sensitive data

If suspicious content is found:
- Show a warning with masked snippets
- Ask for confirmation to proceed
- Default to cancel if user doesn't explicitly confirm

### 5. Compose Commit Message

Create a commit message following git-flow format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

Example:
```
feat(auth): add OAuth2 authentication flow

Implement OAuth2 authentication with Google and GitHub providers.
Add token refresh mechanism and session management.

Closes #123
```

**Present the commit message to the user and ask for confirmation or edits.**

### 6. Commit

Once confirmed:
1. Show the exact commit command
2. Execute: `git commit -m "<type>(<scope>): <subject>" -m "<body>" -m "<footer>"`
   - If the message contains special characters, write to a temp file and use `git commit -F <file>`
3. Verify the commit was created: `git log -1 --oneline`

### 7. Push

If `--no-push` is NOT set:
1. Check if branch has upstream: `git rev-parse --abbrev-ref @{u} 2>/dev/null`
2. Show the push command you will run
3. Ask for confirmation
4. Execute:
   - If no upstream: `git push -u origin <branch>`
   - If upstream exists: `git push`
5. Report the result

## Output

Print a summary:
- Commit type and scope
- Commit message (first line)
- Files changed count
- Branch name
- Push status (if pushed)

If any step fails:
- Report the exact command and stderr
- Provide diagnosis and suggested fixes
- Do not proceed to the next step

## Examples

### Example 1: Feature with scope
```
Type: feat
Scope: api
Subject: add user profile endpoint
Body: Implement GET /api/users/:id endpoint with profile data
Footer: Closes #42
```

### Example 2: Bug fix without scope
```
Type: fix
Subject: prevent null pointer exception in auth handler
Body: Add null check before accessing user object properties
```

### Example 3: Documentation
```
Type: docs
Subject: update installation instructions in README
```

## Error Handling

- **No changes staged**: Prompt to stage files first
- **Merge conflict**: Report and ask user to resolve
- **Push rejected**: Suggest pull/rebase and retry
- **No remote**: Warn and skip push
- **Permission denied**: Check credentials and permissions
