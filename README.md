# CC Marketplace for Claude Code

[日本語版はこちら](README.ja.md)

This repository provides a Claude Code marketplace bundle (cc-marketplace).

Included plugins:

- [`gh`](#gh-plugin): Intelligent PR creation tool that analyzes your changes and creates well-structured pull requests automatically.
- [`statusline`](#statusline-plugin): Installs a shell status line for Claude Code showing branch, model, cost, duration, diff lines, and a quote.

## Features

### gh Plugin

- **Intelligent Analysis**: Automatically analyzes your git changes, commits, and diffs
- **Smart PR Generation**: Creates comprehensive PR descriptions with proper formatting
- **Flexible Options**: Supports draft PRs, custom base branches, and reviewer assignments
- **Error Handling**: Provides clear error messages and actionable solutions
- **GitHub Integration**: Seamlessly integrates with GitHub CLI (`gh`)

### statusline Plugin

- **Rich Session Info**: Displays branch, model, cost, duration, and line changes
- **Real-time Updates**: Updates as you work in your Claude Code session
- **Inspiring Quotes**: Shows a new programming quote every 5 minutes (cached)
- **Color-Coded Display**: Uses emojis and colors for easy visual parsing
- **Offline Support**: Gracefully falls back when offline

## Prerequisites

### For gh Plugin

- [Claude Code](https://claude.ai/download) installed
- `git` installed and available in `PATH`
- [GitHub CLI (`gh`)](https://cli.github.com/) installed and authenticated
- A git repository with changes to create a PR from

### For statusline Plugin

- [Claude Code](https://claude.ai/download) installed
- `jq` installed and available in `PATH` (for JSON parsing)
- `curl` installed (for fetching quotes, optional)
- A git repository (optional, for branch display)

## Installation

### From GitHub (Recommended)

```bash
/plugin marketplace add setouchi-h/cc-marketplace
# Install gh plugin
/plugin install gh@cc-marketplace
# Install statusline plugin
/plugin install statusline@cc-marketplace
```

---

## gh Plugin

### Basic Usage

Simply run the command in Claude Code:

```bash
/gh:create-pr
```

The plugin will:

1. Analyze your current branch and changes
2. Generate a comprehensive PR title and description
3. Push your branch if needed
4. Create the pull request on GitHub
5. Display the PR URL

### Flags

- `-d, --draft`: Create as a draft PR
- `-b, --base <branch>`: Use an alternate base branch. Defaults to the repository's default branch (commonly `main` or `master`).
- `-r, --reviewer <user>`: Add a GitHub username as a reviewer. Repeat the flag to add multiple reviewers.
- `--no-push`: Skip pushing the current branch before creating the PR.
- `--assign-me`: Attempt to assign the PR to the authenticated user (`@me`). Assignment happens after the PR is created; if assignment isn’t permitted, a warning is shown and PR creation still succeeds.

Examples with short flags:

```bash
# Draft PR against a custom base with two reviewers
/create-pr -d -b develop -r alice -r bob
```

### How It Works

1. **Branch Analysis**: Checks your current branch status and remote tracking
2. **Change Detection**: Analyzes commits and diffs since the base branch
3. **Content Generation**: Creates a PR with:
   - Concise, descriptive title (imperative mood, <72 chars)
   - Comprehensive description including:
     - Summary of changes
     - Detailed change list
     - Motivation and context
     - Testing information
     - Additional notes
4. **PR Creation**: Uses `gh pr create` to create the pull request
5. **Result Display**: Shows the PR URL and summary

### Permissions

This plugin invokes the following local commands:

- `git` — to inspect status, branches, commits, and diffs
- `gh` — to create the pull request via GitHub CLI

It relies on your existing `gh auth login` session and does not store credentials itself.

### Example PR Description

The plugin generates PRs with this structure:

```markdown
## Summary

Brief overview of what this PR accomplishes

## Changes

- Key change or feature 1
- Key change or feature 2
- Key change or feature 3

## Motivation

Explanation of why these changes were needed

## Testing

- How the changes were tested
- Test results or validation steps

## Notes

Any additional context, breaking changes, or reviewer notes
```

---

## statusline Plugin

### Overview

The statusline plugin installs a customizable status line script that displays rich information about your Claude Code session. It shows the current git branch, AI model, session cost, duration, changed lines, and an inspiring programming quote.

### What It Displays

The status line shows:

- 🌿 **Current Branch**: Git branch name (e.g., `main`, `feature/new-ui`)
- 🤖 **Model**: AI model name and ID (e.g., `Sonnet 4.5`)
- 💰 **Cost**: Total session cost in USD (e.g., `$0.0123`)
- ⏱️ **Duration**: Session duration in minutes/seconds (e.g., `1m49s`)
- 📝 **Changes**: Lines added/removed (e.g., `+10/-2`)
- 💬 **Quote**: Random programming quote (refreshed every 5 minutes)

Example output:

![Statusline Example](assets/statusline.png)

### Installation

#### Step 1: Install the Plugin

```bash
/plugin marketplace add setouchi-h/cc-marketplace
/plugin install statusline@cc-marketplace
```

#### Step 2: Run the Install Command

```bash
/statusline:install-statusline
```

This command:

- Checks if `jq` is installed (required for JSON parsing)
- Creates `~/.claude/scripts/` directory if it doesn't exist
- Writes the status line script to `~/.claude/scripts/statusline.sh`
- Makes the script executable
- Automatically configures `~/.claude/settings.json` to enable the status line

#### Preview the Status Line

Test the status line without starting a full session:

```bash
/statusline:preview-statusline
```

This renders a sample status line using mock data to verify colors and layout.

### How It Works

1. **JSON Input**: Claude Code passes session data as JSON to the script via stdin
2. **Data Extraction**: The script uses `jq` to parse:
   - Session cost and duration
   - Lines added/removed
   - Model name and ID
   - Workspace directory
3. **Git Branch**: Detects the current git branch from the workspace
4. **Quote Fetching**:
   - Fetches a random quote from [ZenQuotes API](https://zenquotes.io/)
   - Caches quotes for 5 minutes to reduce API calls
   - Falls back to cached or default quotes when offline
5. **Formatting**: Outputs a single line with emojis and ANSI color codes

### Requirements

- **jq**: Required for JSON parsing
  - macOS: `brew install jq`
  - Linux: `sudo apt-get install jq` or `sudo yum install jq`
  - Windows: Download from [jqlang.github.io](https://jqlang.github.io/jq/download/)
- **curl**: Optional, for fetching quotes (degrades gracefully if unavailable)
- **git**: Optional, for displaying branch name

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License - see [LICENSE](LICENSE) file for details
