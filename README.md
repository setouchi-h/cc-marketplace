# Git Tools Plugin for Claude Code

[日本語版はこちら](README.ja.md)

An intelligent Claude Code plugin that analyzes your changes and creates well-structured pull requests automatically.

## Features

- **Intelligent Analysis**: Automatically analyzes your git changes, commits, and diffs
- **Smart PR Generation**: Creates comprehensive PR descriptions with proper formatting
- **Flexible Options**: Supports draft PRs, custom base branches, and reviewer assignments
- **Error Handling**: Provides clear error messages and actionable solutions
- **GitHub Integration**: Seamlessly integrates with GitHub CLI (`gh`)

## Prerequisites

- [Claude Code](https://claude.ai/download) installed and running
- `git` installed and available in `PATH`
- [GitHub CLI (`gh`)](https://cli.github.com/) installed and authenticated
- A git repository with changes to create a PR from

## Installation

### From GitHub (Recommended)

```bash
/plugin marketplace add setouchi-h/git-tools
/plugin install gh@git-tools
```

### From Local Directory

```bash
cd /path/to/git-tools
/plugin install .
```

## Usage

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

## How It Works

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

## Example PR Description

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

## Troubleshooting

### Command Not Found

If the `/create-pr` command is not recognized:
1. Verify the plugin is installed: `/plugin list`
2. Reinstall if needed: `/plugin install gh@git-tools`
3. Restart Claude Code

### GitHub CLI Not Found

Install the GitHub CLI:
- macOS: `brew install gh`
- Linux: See [GitHub CLI installation](https://github.com/cli/cli#installation)
- Windows: `winget install --id GitHub.cli`

Then authenticate: `gh auth login`

### Branch Not Pushed

The plugin automatically pushes your branch. If it fails:
1. Check your git remote configuration
2. Verify you have push access to the repository
3. Resolve any merge conflicts
4. Try pushing manually: `git push -u origin <branch-name>`

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License - see [LICENSE](LICENSE) file for details
