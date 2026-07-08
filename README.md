# digital-twin-garden

A plain-Markdown vault, maintained by scheduled [Claude Code](https://claude.com/claude-code) (or any coding agent you can run headlessly — Codex works too) agents instead of by hand.

## The idea

This is two things at once, and both matter:

1. **A context store any agent can dip into.** Claude Code has no memory between sessions — every chat starts from zero. Point it at a well-organized vault instead, and it reads real, current context (what you're working on, what you've decided, how you think) instead of you re-explaining it every time. This part is passive: the vault just sits there as grounding, and any session — Claude Code, Codex, whatever — can read it.
2. **An evolving digital twin.** The vault doesn't just store what's true today — it's actively kept in sync with you. Two small agents run on a schedule and change the vault itself: one keeps it organized (no rot, no dead links, no contradictions), one grows it (surfaces connections, gaps, and next steps you haven't written down yet). Over time the vault becomes less "notes about you" and more a live, self-updating model of how you think and what you're building — a twin, not an archive. 
(I took a few hours inputing "personality" into the vault so that it can think like me)

Most "AI + notes" setups only do (1) — a folder Claude can read. The agents are what make it (2) as well: something that keeps itself accurate and keeps growing without you doing the maintenance.

## The two agents

| Agent | Cadence | Job |
|---|---|---|
| **Gardener** | hourly | Empties the Inbox, rebalances the note tree, compacts stale/contradicted claims, fixes dead links. Never deletes — supersedes with a dated line. |
| **Sower** | daily | Reads the whole vault (including any private "how I think" notes you keep), finds connections nobody's drawn yet, and hands you 5 things worth your attention: a seed/cross-project connection, a dangling thread, a pattern (a habit, or a value you're not living up to), an old note worth re-reading, a recall quiz. Anything worth tracking longer than a day gets promoted into `Frontier/`'s live-seeds list. |

Think of it like an actual garden: the **Gardener** tends what's already planted — weeds, structure, dead branches. The **Sower** walks the unplanted ground looking for where the next thing should grow, and hands you what it found each morning.

Neither agent deletes your work. Both cite their sources. Both are just a Markdown file (their "manual") plus a scheduler calling `claude -p --permission-mode acceptEdits`.

## Layout

```
your-vault/
├── CLAUDE.md          # orientation, auto-loaded every session
├── Inbox/             # quick captures — the default drop zone for anything unsorted
├── Projects/          # active, time-bound work
├── Areas/             # ongoing responsibilities
├── Resources/         # evergreen reference material
├── Archive/           # completed/dead projects, compacted notes
├── Daily/             # Sower's dated notes
├── Frontier/          # Sower's "live seeds" list
└── Meta/
    ├── Vault-Map.md
    ├── Gardener.md
    ├── Sower.md
    ├── Note-Template.md
    └── Project-Template.md
```

Every folder has an `_index.md` — that's the only "retrieval system" here. No embeddings, no vector DB. The bet: plain Markdown + an agent that actually reads it beats semantic search, because the agent can catch *contradictions*, not just similarity.

Three rules that make the tree work:
- **Inbox is a mailbox, not storage** — nothing sits there past one Gardener pass.
- **Supersede, don't delete** — a wrong or outdated claim gets struck through with a dated pointer to what replaced it, or moves to `Archive/` with a tombstone. History stays findable; the live view stays clean.
- **Ownership is exclusive per folder** — the Gardener never touches `Daily/`/`Frontier/`; the Sower never edits notes outside those two. Clean boundaries mean the agents can't fight each other.

## Setup

1. Install [Claude Code](https://claude.com/claude-code) and log in. Have (or create) a folder of Markdown files — Obsidian is nice for browsing but not required.
2. Copy the scaffolding in: `cp -r Meta Frontier /path/to/your-vault/` then `mkdir -p /path/to/your-vault/{Inbox,Projects,Areas,Resources,Archive,Daily}`.
3. Fill in `CLAUDE.md.template` (who you are, what you're working on) and drop it at your vault's root as `CLAUDE.md`.
4. Optional: merge `global-CLAUDE.md.snippet` into `~/.claude/CLAUDE.md` so the capture rules (inbox everything, log every session, link liberally) apply across all your projects, not just this vault.
5. Test the scripts: `export VAULT_GARDENER_VAULT_PATH=/path/to/your-vault`, then run `./scripts/gardener.sh` and `./scripts/sower.sh`.
6. Schedule them. macOS: copy `launchd/*.plist.template`, fill in the `{{...}}` placeholders, rename to drop `.template`, `launchctl load` it. Linux: `cron` or a `systemd --user` timer — the scripts are plain zsh/bash, no launchd dependency.
7. Read `Daily/YYYY-MM-DD.md` each morning. That's the payoff: the vault talks back instead of just sitting there.

## License

MIT — take it, fork it, rename the agents, make it yours.
