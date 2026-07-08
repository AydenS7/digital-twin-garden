#!/bin/zsh
# Hourly vault gardener — sorts Inbox, rebalances the tree, compacts stale notes.
# Skips the run entirely if nothing in the vault changed since the last pass.
#
# Configure via env vars (or edit the defaults below):
#   VAULT_GARDENER_VAULT_PATH   - path to your Obsidian vault (required)
#   VAULT_GARDENER_STATE_DIR    - where to keep logs/state (default: ~/.claude/vault-gardener)
#   VAULT_GARDENER_CLAUDE_BIN   - path to the claude binary (default: `which claude`)

VAULT="${VAULT_GARDENER_VAULT_PATH:?set VAULT_GARDENER_VAULT_PATH to your vault path}"
DIR="${VAULT_GARDENER_STATE_DIR:-$HOME/.claude/vault-gardener}"
CLAUDE_BIN="${VAULT_GARDENER_CLAUDE_BIN:-$(command -v claude)}"
STAMP="$DIR/last-run"
LOG="$DIR/run.log"
mkdir -p "$DIR"

# Nothing new since last pass (ignoring the gardener's own outputs)? Skip.
if [ -f "$STAMP" ] && [ -z "$(find "$VAULT" -name '*.md' -newer "$STAMP" \
      ! -name 'Gardener-Log.md' ! -name 'Gardener.md' -print -quit)" ]; then
  exit 0
fi

# A stale exported ANTHROPIC_API_KEY overrides your claude.ai login — drop it
unset ANTHROPIC_API_KEY

echo "=== gardener pass $(date '+%Y-%m-%d %H:%M') ===" >> "$LOG"
cd "$VAULT" || exit 1
"$CLAUDE_BIN" -p \
  "You are the vault gardener. Read Meta/Gardener.md and execute one gardening pass on this vault now, following it exactly." \
  --permission-mode acceptEdits \
  --allowedTools "Bash(mv:*)" \
  >> "$LOG" 2>&1
STATUS=$?
echo "--- exit $STATUS ---" >> "$LOG"
touch "$STAMP"
exit $STATUS
