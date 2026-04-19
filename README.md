# claudes

Run multiple **Claude Code** sessions side-by-side in a tmux grid, each in its own isolated **git worktree** so they never stomp on each other's changes.

Inspired by the 2×2 terminal layout where one "integrator" pane watches the main repo while N workers crunch separate branches in parallel.

```
┌───────────────────────┬───────────────────────┐
│ claude-1 (claude/1)   │ claude-2 (claude/2)   │
│                       │                       │
├───────────────────────┼───────────────────────┤
│ claude-3 (claude/3)   │ integrator (main)     │
│                       │                       │
└───────────────────────┴───────────────────────┘
```

## Requirements

- macOS or Linux (bash, git, tmux)
- [Claude Code](https://www.npmjs.com/package/@anthropic-ai/claude-code): `npm i -g @anthropic-ai/claude-code`
- `tmux`: `brew install tmux` on macOS

Check everything at once: `claudes doctor`.

## Install

Clone and install the script to `~/.local/bin`:

```bash
git clone https://github.com/<your-user>/claudes.git
cd claudes
./install.sh
```

Or install to a different location:

```bash
CLAUDES_INSTALL_DIR=/usr/local/bin ./install.sh
```

Make sure `~/.local/bin` is on your `PATH` (the installer prints the line to add if it isn't).

Optional: merge the tmux tweaks into your config.

```bash
cat tmux/claudes.tmux.conf >> ~/.tmux.conf
```

## Quick start

From inside any git repo:

```bash
claudes doctor        # verify tmux/git/claude are installed
claudes init -n 3     # create 3 worktrees branched off main
claudes start         # launch tmux grid: 3 workers + integrator pane
```

iTerm2 users — this is the nicer mode, uses native iTerm panes with real scrollback:

```bash
claudes start --cc
```

When you're done:

```bash
claudes stop          # close the tmux session
claudes clean         # remove worktrees and their branches
```

## Commands

| Command | What it does |
|---|---|
| `claudes init [-n N] [-b BRANCH]` | Create `N` worktrees branched off `BRANCH` (defaults: 3, main) |
| `claudes start [--cc]` | Launch tmux session with Claude running in each pane |
| `claudes attach [--cc]` | Re-attach to a running session |
| `claudes stop` | Kill the tmux session (worktrees left intact) |
| `claudes clean [--force]` | Remove all claudes worktrees **and** their branches |
| `claudes list` | Show active claudes worktrees |
| `claudes doctor` | Check dependencies |

## Config

Drop a `.claudesrc` at your repo root for per-project defaults:

```bash
CLAUDES_WORKERS=4
CLAUDES_BASE=develop
CLAUDES_PREFIX=claude
```

Or set env vars globally in your shell profile:

| Variable | Default | Purpose |
|---|---|---|
| `CLAUDES_SESSION` | `claudes` | tmux session name |
| `CLAUDES_WORKERS` | `3` | default worker count for `init` |
| `CLAUDES_BASE` | `main` | default base branch for `init` |
| `CLAUDES_PREFIX` | `claude` | branch/folder prefix (`claude/1`, `claude-1`, …) |
| `CLAUDES_CLAUDE_CMD` | `claude` | command used to launch Claude in each pane |

## tmux survival kit

Default prefix is `Ctrl+b`. Press it, release, then the next key.

| Keys | Action |
|---|---|
| `Ctrl+b` → arrow keys | move between panes |
| `Ctrl+b` → `z` | zoom current pane fullscreen (same to unzoom) |
| `Ctrl+b` → `d` | detach (session keeps running, reattach with `claudes attach`) |
| `Ctrl+b` → `[` | scroll mode (arrow keys, `q` to exit) |
| `Ctrl+b` → `x` | kill current pane |

With the included tmux config you also get: `prefix + |` and `prefix + -` for splits, `prefix + h/j/k/l` for vim-style navigation, and mouse support.

## How it works

- `init` creates sibling folders at `../<repo>-worktrees/claude-1`, `claude-2`, … each on its own branch (`claude/1`, `claude/2`, …). Git shares the `.git` directory, so no duplicate clones.
- `start` opens a tmux session named `claudes`, one pane per worktree, plus a final "integrator" pane rooted at the main repo on its current branch. Each pane runs `claude`.
- `clean` removes the worktrees and deletes the short-lived branches.

Because each worker is a real checkout on a real branch, you can `cd` into one, run tests, push a PR, or `git diff` between workers at any time.

## Tips

- Want N workers but only use a few? Just ignore the extra panes — `Ctrl+b z` to zoom the one you're focused on.
- Running on a VPS and want sessions to survive SSH drops? That's built in — tmux keeps them alive. Reconnect with `claudes attach`.
- Hook conflicts between workers can happen if they edit the same files. The worktree-per-branch model prevents file-level stomping but you'll still get merge conflicts when you integrate. Plan work so each worker owns a distinct module.

## License

MIT — see [LICENSE](./LICENSE).
