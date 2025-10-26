---
description: Install the Claude Code status line shell script to ~/.claude/scripts/statusline.sh
argument-hint: "[--force]"
allowed-tools:
  - Bash(mkdir:*)
  - Bash(tee:*)
  - Bash(chmod:*)
  - Bash(which:*)
  - Bash(echo:*)
  - Bash(test:*)
---

# Install Statusline

This command writes a shell script to `~/.claude/scripts/statusline.sh` that renders a rich status line for Claude Code sessions (branch, model, cost, duration, lines changed, and a quote).

## Behavior

- If the target file exists and `--force` is not provided, confirm before overwriting.
- Ensures the `~/.claude/scripts` directory exists and sets the script executable.
- Verifies `jq` is available (required by the script) and warns if missing.

## Steps

1) Check for `jq` and warn if not present (continue anyway):

- Run: `which jq || echo "Warning: jq not found. Please install jq to enable the status line parser."`

2) Create the scripts directory:

- Run: `mkdir -p ~/.claude/scripts`

3) If the file exists and `--force` is not passed, prompt for confirmation. Otherwise, proceed to write the file using a here-doc with `tee` and then mark it executable.

- Run:

```
test -f ~/.claude/scripts/statusline.sh && [ "$ARGUMENTS" != "--force" ] && echo "~/.claude/scripts/statusline.sh already exists. Re-run with --force to overwrite." && exit 0 || true
tee ~/.claude/scripts/statusline.sh >/dev/null <<'EOF'
#!/usr/bin/env bash

# Status line script for Claude Code
# Displays: Branch, Model, Cost, Duration, Lines changed, and a quote

# Read JSON input from stdin
input=$(cat)

# Extract data from JSON
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
model_name=$(echo "$input" | jq -r '.model.display_name // "Sonnet 4.5"')
model_id=$(echo "$input" | jq -r '.model.id // "claude-sonnet-4-5-20250929"')
workspace_dir=$(echo "$input" | jq -r '.workspace.current_dir // .workspace.project_dir // ""')

# Get current git branch (use workspace directory if available)
if [ -n "$workspace_dir" ] && [ -d "$workspace_dir" ]; then
  branch=$(git -C "$workspace_dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "no-branch")
else
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "no-branch")
fi

# Format duration (convert milliseconds to seconds)
if [ "$duration_ms" != "0" ] && [ "$duration_ms" != "null" ]; then
  duration_seconds=$((duration_ms / 1000))
  minutes=$((duration_seconds / 60))
  seconds=$((duration_seconds % 60))
  if [ $minutes -gt 0 ]; then
    duration_str="${minutes}m${seconds}s"
  else
    duration_str="${seconds}s"
  fi
else
  duration_str="0s"
fi

# Fetch quote with 5-minute caching
get_quote() {
  local cache_file="/tmp/claude_statusline_quote.txt"
  local cache_max_age=300  # 5 minutes in seconds
  local fallback_quote="\"Code is poetry\" - Anonymous"

  # Check if cache exists and is fresh (less than 5 minutes old)
  if [ -f "$cache_file" ]; then
    local cache_age=$(( $(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || echo 0) ))

    # Use cached quote if it's less than 5 minutes old
    if [ "$cache_age" -lt "$cache_max_age" ]; then
      cat "$cache_file"
      return 0
    fi
  fi

  # Cache is stale or doesn't exist - try to fetch new quote from API
  local api_response=$(curl -s --max-time 2 "https://zenquotes.io/api/random" 2>/dev/null)
  local curl_exit_code=$?

  if [ $curl_exit_code -eq 0 ] && [ -n "$api_response" ]; then
    # Parse the JSON response (ZenQuotes returns an array, so use .[0])
    local quote_text=$(echo "$api_response" | jq -r '.[0].q // empty' 2>/dev/null)
    local quote_author=$(echo "$api_response" | jq -r '.[0].a // "Unknown"' 2>/dev/null)

    if [ -n "$quote_text" ] && [ "$quote_text" != "null" ] && [ "$quote_text" != "empty" ]; then
      # Format quote and save to cache
      local formatted_quote="\"$quote_text\" - $quote_author"
      echo "$formatted_quote" > "$cache_file"
      echo "$formatted_quote"
      return 0
    fi
  fi

  # API failed - try to use old cached quote as fallback
  if [ -f "$cache_file" ]; then
    cat "$cache_file"
    return 0
  fi

  # No cache available, use fallback
  echo "$fallback_quote"
}

quote=$(get_quote)

# Apply dim gray color to each word in the quote to ensure color persists on line wrap
# This workaround applies the color code to each word individually
apply_color_per_word() {
  local text="$1"
  local color_code="\033[2;90m"
  local reset_code="\033[0m"

  # Split the text into words and apply color to each word
  local colored_words=""
  local word

  # Read words while preserving quotes and special characters
  while IFS= read -r word || [ -n "$word" ]; do
    if [ -n "$colored_words" ]; then
      colored_words="${colored_words} ${color_code}${word}${reset_code}"
    else
      colored_words="${color_code}${word}${reset_code}"
    fi
  done < <(echo "$text" | tr ' ' '\n')

  echo -n "$colored_words"
}

colored_quote=$(apply_color_per_word "$quote")

# Build and print status line with emojis and colors
printf "🌿 \033[1;92m%s\033[0m | 🤖 \033[1;96m%s\033[0m \033[2;90m(%s)\033[0m | 💰 \033[1;93m\$%.4f\033[0m | ⏱️ \033[1;97m%s\033[0m | 📝 \033[1;92m+%s\033[0m/\033[1;91m-%s\033[0m | 💬 %b" \
  "$branch" \
  "$model_name" \
  "$model_id" \
  "$cost" \
  "$duration_str" \
  "$lines_added" \
  "$lines_removed" \
  "$colored_quote"
EOF
chmod +x ~/.claude/scripts/statusline.sh
```

4) Print success message:

- Run: `echo "Installed: ~/.claude/scripts/statusline.sh"`

## Notes

- The script expects JSON input from Claude Code and requires `jq` at runtime. Quotes are fetched via `curl` with a 5-minute cache and a graceful offline fallback.
- To test locally, see the separate "Preview Statusline" command.

