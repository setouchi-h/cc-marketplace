---
description: Preview the status line by piping sample JSON into ~/.claude/scripts/statusline.sh (supports --no-quotes)
allowed-tools:
  - Bash(test:*)
  - Bash(echo:*)
  - Bash(pwd:*)
  - Bash(cat:*)
---

# Preview Statusline

Render a sample status line using the installed script and mock JSON. Useful to verify colors and layout.

## Steps

1) Ensure the script is installed:

- Run: `test -x ~/.claude/scripts/statusline.sh || (echo "Not installed. Run: /statusline.install-statusline" && exit 1)`

2) Build a small sample event JSON and pipe to the script:

- Run:

```
cat <<'JSON' | ~/.claude/scripts/statusline.sh
{
  "cost": {
    "total_cost_usd": 0.0123,
    "total_duration_ms": 6543,
    "total_lines_added": 10,
    "total_lines_removed": 2
  },
  "model": {
    "display_name": "Sonnet 4.5",
    "id": "claude-sonnet-4-5-20250929"
  },
  "workspace": {
    "project_dir": "$(pwd)"
  }
}
JSON
```

You should see a single status line printed with colored fields and a quote.

To preview without the quote section, either add the flag or prefix an env var:

```bash
# Using flag
cat <<'JSON' | ~/.claude/scripts/statusline.sh --no-quotes
{ "cost": {"total_cost_usd": 0.0123, "total_duration_ms": 6543, "total_lines_added": 10, "total_lines_removed": 2 }, "model": {"display_name": "Sonnet 4.5", "id": "claude-sonnet-4-5-20250929"}, "workspace": {"project_dir": "$(pwd)"} }
JSON

# Using environment variable
CLAUDE_STATUSLINE_NO_QUOTES=1 bash -lc 'cat <<'\''JSON'\'' | ~/.claude/scripts/statusline.sh'
{ "cost": {"total_cost_usd": 0.0123, "total_duration_ms": 6543, "total_lines_added": 10, "total_lines_removed": 2 }, "model": {"display_name": "Sonnet 4.5", "id": "claude-sonnet-4-5-20250929"}, "workspace": {"project_dir": "$(pwd)"} }
JSON
```
