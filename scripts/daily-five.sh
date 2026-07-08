#!/bin/zsh
# Daily Five — every morning, surface 5 things from the vault into Daily/YYYY-MM-DD.md
#
# Configure via env vars (or edit the defaults below):
#   VAULT_GARDENER_VAULT_PATH   - path to your Obsidian vault (required)
#   VAULT_GARDENER_STATE_DIR    - where to keep logs/state (default: ~/.claude/vault-gardener)
#   VAULT_GARDENER_CLAUDE_BIN   - path to the claude binary (default: `which claude`)

VAULT="${VAULT_GARDENER_VAULT_PATH:?set VAULT_GARDENER_VAULT_PATH to your vault path}"
DIR="${VAULT_GARDENER_STATE_DIR:-$HOME/.claude/vault-gardener}"
CLAUDE_BIN="${VAULT_GARDENER_CLAUDE_BIN:-$(command -v claude)}"
LOG="$DIR/daily5.log"
mkdir -p "$DIR"

# A stale exported ANTHROPIC_API_KEY overrides your claude.ai login — drop it
unset ANTHROPIC_API_KEY

# Skip if today's note already exists
[ -f "$VAULT/Daily/$(date '+%Y-%m-%d').md" ] && exit 0

echo "=== daily five $(date '+%Y-%m-%d %H:%M') ===" >> "$LOG"
cd "$VAULT" || exit 1
"$CLAUDE_BIN" -p \
  "You are the Daily Five agent. Read Meta/Daily-Five.md and produce today's note now, following it exactly. Today is $(date '+%Y-%m-%d')." \
  --permission-mode acceptEdits \
  >> "$LOG" 2>&1
STATUS=$?
echo "--- exit $STATUS ---" >> "$LOG"
exit $STATUS
