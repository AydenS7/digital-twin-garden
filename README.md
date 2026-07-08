# digital-twin-garden

A self-organizing second brain: an Obsidian vault that [Claude Code](https://claude.com/claude-code) , and CODEX read, maintain, and grow for you — on a schedule, with no human in the loop for the maintenance itself. The vault becomes a living digital twin of how you think and what you're working on.

## The idea

Claude Code is, per Claude Code's own developers, "the smartest person you've ever worked with... who wakes up every morning with total amnesia." 

Chat-based prompting fights that amnesia every session. This framework fixes it structurally instead: keep a plain-Markdown vault as durable, evolving context, and run three small scheduled agents against it so it never rots into a junk drawer.

**Context beats prompting.** A well-organized vault Claude can read is worth more than a clever prompt — it turns Claude from a stranger who needs re-onboarding into something closer to a teammate who already knows what you're doing.

The three agents:

| Agent | Cadence | Job |
|---|---|---|
| **Gardener** | hourly | Empties the Inbox, rebalances the note tree, compacts stale/contradicted claims, fixes dead links. Never deletes — supersedes with a dated line. |
| **Daily Five** | daily (morning) | Reads the whole vault and hands you exactly 5 things worth your attention today: an idea, a dangling thread, a pattern, an old note worth re-reading, a recall quiz. |
| **Sower** | daily | Reads *everything* (including your private "how I think" notes, if you keep one) and looks for connections across projects, unstated knowledge gaps, and where you should grow next. Writes a short daily digest to its own tree, `Frontier/`. |

Think of it like an actual garden: the **Gardener** tends what's already planted (weeds, structure, dead branches). The **Sower** walks the unplanted ground looking for where the next thing should grow. **Daily Five** is the part that talks back to you every morning.

None of these agents delete your work. All of them cite their sources. All of them are just a Markdown file (their "manual") plus a cron-like scheduler calling `claude -p` with `--permission-mode acceptEdits`.

## Vault structure

```
your-vault/
├── CLAUDE.md          # orientation file, auto-loaded by Claude Code every session
├── Inbox/             # quick captures — the default drop zone for anything unsorted
├── Projects/          # active, time-bound work
├── Areas/             # ongoing responsibilities (health, career, finances...)
├── Resources/         # evergreen reference material
├── Archive/           # completed/dead projects, compacted notes
├── Daily/             # written by Daily Five — one dated note per day
├── Frontier/          # written by Sower — one dated digest per day + a promoted "live seeds" list
└── Meta/
    ├── Vault-Map.md       # orientation: what's where
    ├── Gardener.md        # the Gardener's manual
    ├── Daily-Five.md      # the Daily Five's manual
    ├── Sower.md           # the Sower's manual
    ├── Note-Template.md
    └── Project-Template.md
```

Every folder has an `_index.md` — that's the only "retrieval system" here. There are no embeddings. The whole design bet is: plain Markdown + an agent that actually reads it beats a vector database, because the agent can catch *contradictions*, not just similarity.

## How to think about the tree

- **Inbox is a mailbox, not storage.** Nothing should live there longer than one Gardener pass.
- **Notes are supersede-don't-delete.** A wrong or outdated claim gets struck through with a dated pointer to what replaced it (`~~old claim~~ → superseded 2026-07-08 by [[new-note]]`), or the whole note moves to `Archive/` with a one-line tombstone left behind. History stays findable; the live view stays clean.
- **Hub notes emerge, they aren't planned.** When a person, system, or theme shows up across 3+ notes, that's the Gardener's cue to build it a hub page.
- **`Frontier/` is disposable by default.** Most daily seeds are just noticed-and-discarded. A seed only gets promoted to the vault's permanent "live seeds" list if it survives resurfacing — that's the filter against noise.
- **Ownership is exclusive per folder.** The Gardener never touches `Daily/` or `Frontier/`; Daily Five and Sower never touch each other's folder or edit existing notes. Clean boundaries mean the agents can't fight each other or duplicate work.

## Setup

1. **Prerequisites:** [Claude Code](https://claude.com/claude-code) installed and logged in (`claude` on your `$PATH`), and an Obsidian vault (or any folder of Markdown files — Obsidian isn't required, just nice for browsing/graph view).

2. **Copy the vault scaffolding** into your vault:
   ```bash
   cp -r Meta Frontier /path/to/your-vault/
   mkdir -p /path/to/your-vault/{Inbox,Projects,Areas,Resources,Archive,Daily}
   ```

3. **Fill in `CLAUDE.md.template`** with who you are and what you're working on, then drop it at your vault's root as `CLAUDE.md`. Claude Code auto-loads this every time you work in that directory.

4. *(Optional)* Merge `global-CLAUDE.md.snippet` into `~/.claude/CLAUDE.md` so the three capture rules (inbox everything, log every project session, link liberally) apply across *all* your projects, not just this vault.

5. **Wire up the scripts.** Each script in `scripts/` takes its vault path from an env var — no hardcoded personal paths:
   ```bash
   export VAULT_GARDENER_VAULT_PATH=/path/to/your-vault
   ./scripts/gardener.sh      # test a manual pass
   ./scripts/daily-five.sh
   ./scripts/sower.sh
   ```

6. **Schedule them.** On macOS, copy the `launchd/*.plist.template` files, fill in the `{{...}}` placeholders (script path, vault path, a log directory), rename to drop `.template`, and load:
   ```bash
   cp launchd/com.you.vault-gardener.plist.template ~/Library/LaunchAgents/com.you.vault-gardener.plist
   # edit the placeholders, then:
   launchctl load ~/Library/LaunchAgents/com.you.vault-gardener.plist
   ```
   On Linux, use `cron` or a `systemd --user` timer instead — the scripts themselves are plain zsh/bash and don't depend on launchd.

7. **Read `Frontier/YYYY-MM-DD.md` and `Daily/YYYY-MM-DD.md` each morning.** That's the whole payoff: the vault talks back to you instead of just sitting there.

## Why this works better than plain chat

- **No re-onboarding.** Every session starts with a vault Claude already understands, instead of a blank slate.
- **Compounding, not just storage.** The Gardener actively looks for contradictions and connections a plain filesystem or note-taking app never surfaces on its own.
- **You don't have to remember to maintain it.** The whole point of running these on a schedule is that upkeep doesn't compete with your attention — the vault stays useful without you doing the janitorial work.

## License

MIT — take it, fork it, rename the agents, make it yours.
