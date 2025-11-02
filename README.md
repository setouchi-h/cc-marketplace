# CC Marketplace for Claude Code

[日本語版はこちら](README.ja.md)

Claude Code marketplace bundle with essential development plugins.

## Plugins

- **statusline**: Rich status line showing branch, model, cost, duration, and changes
- **gh**: Automated PR creation with intelligent analysis
- **git**: Git-flow workflow automation (branch creation, conventional commits)

## Installation

```bash
/plugin marketplace add setouchi-h/cc-marketplace
/plugin install statusline@cc-marketplace
/plugin install gh@cc-marketplace
/plugin install git@cc-marketplace
```

## Usage

### statusline
```bash
/statusline:install-statusline        # Install status line
/statusline:preview-statusline        # Preview status line
```

### gh
```bash
/gh:create-pr                         # Create PR from current branch
/gh:create-pr -d -b develop          # Draft PR against develop
```

### git
```bash
/git:create-branch "task description" # Create git-flow branch
/git:commit                           # Conventional commit with auto-detection
```

## License

MIT
