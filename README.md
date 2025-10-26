# CC Marketplace for Claude Code

[日本語版はこちら](README.ja.md)

This repository provides a Claude Code marketplace bundle (cc-marketplace).

Included plugins:
- `gh`: Intelligent PR creation tool that analyzes your changes and creates well-structured pull requests automatically.
- `statusline`: Installs a shell status line for Claude Code showing branch, model, cost, duration, diff lines, and a quote.

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
- [Claude Code](https://claude.ai/download) installed and running
- `git` installed and available in `PATH`
- [GitHub CLI (`gh`)](https://cli.github.com/) installed and authenticated
- A git repository with changes to create a PR from

### For statusline Plugin
- [Claude Code](https://claude.ai/download) installed and running
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

### From Local Directory

```bash
cd /path/to/cc-marketplace
/plugin install .
```

---

## gh Plugin

### Usage

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

### Advanced Options

```bash
# Create a draft PR
/create-pr --draft

# Specify a different base branch
/create-pr --base develop

# Add reviewers
/create-pr --reviewer username1 --reviewer username2

# Skip automatic push (if branch is already pushed)
/create-pr --no-push

# Assign the PR to yourself when permitted
/create-pr --assign-me
```

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

### Troubleshooting

#### Command Not Found

If the `/create-pr` command is not recognized:
1. Verify the plugin is installed: `/plugin list`
2. Reinstall if needed: `/plugin install gh@cc-marketplace`
3. Restart Claude Code

#### GitHub CLI Not Found

Install the GitHub CLI:
- macOS: `brew install gh`
- Linux: See [GitHub CLI installation](https://github.com/cli/cli#installation)
- Windows: `winget install --id GitHub.cli`

Then authenticate: `gh auth login`

#### Branch Not Pushed

The plugin automatically pushes your branch. If it fails:
1. Check your git remote configuration
2. Verify you have push access to the repository
3. Resolve any merge conflicts
4. Try pushing manually: `git push -u origin <branch-name>`

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
```
🌿 main | 🤖 Sonnet 4.5 (claude-sonnet-4-5-20250929) | 💰 $0.0123 | ⏱️ 1m49s | 📝 +10/-2 | 💬 "Code is poetry" - Anonymous
```

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

#### Step 3: Configure Claude Code

Add the status line to your Claude Code configuration by editing `~/.config/claude/config.json`:

```json
{
  "statusline": {
    "command": "~/.claude/scripts/statusline.sh"
  }
}
```

Or use the Claude Code settings UI to set the statusline command path.

### Usage

#### Install or Update

```bash
# First-time installation
/statusline:install-statusline

# Force reinstall (overwrites existing script)
/statusline:install-statusline --force
```

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

### Troubleshooting

#### jq Not Found

If you see "jq is required but not installed":

1. Install jq:
   - macOS: `brew install jq`
   - Ubuntu/Debian: `sudo apt-get install jq`
   - Fedora/RHEL: `sudo yum install jq`
2. Verify installation: `which jq`
3. Restart Claude Code

#### Script Not Executing

If the status line doesn't appear:

1. Verify the script exists: `ls -l ~/.claude/scripts/statusline.sh`
2. Check it's executable: `chmod +x ~/.claude/scripts/statusline.sh`
3. Test manually: `/statusline:preview-statusline`
4. Verify Claude Code config points to the correct path
5. Restart Claude Code

#### No Quotes Appearing

If quotes aren't showing:

1. Check internet connection (quotes are fetched from zenquotes.io)
2. The script will cache quotes for 5 minutes and fall back to defaults offline
3. Test curl: `curl -s "https://zenquotes.io/api/random"`
4. If curl is not installed, quotes will use fallback values

#### Colors Not Showing

If colors don't appear correctly:

1. Ensure your terminal supports ANSI colors
2. Check terminal color settings
3. Some terminals may require 256-color support

### Customization

To customize the status line, edit `~/.claude/scripts/statusline.sh`:

- Modify the `printf` format string at the end to change layout
- Adjust color codes (e.g., `\033[1;92m` for bright green)
- Change emojis or remove them
- Modify quote sources or disable quote fetching

After editing, test with `/statusline:preview-statusline`.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License - see [LICENSE](LICENSE) file for details
