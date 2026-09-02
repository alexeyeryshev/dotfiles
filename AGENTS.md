# dotfiles

Dotbot-based. `./install` is the only entry point: Homebrew, then the Brewfile,
then submodules, then `install.conf.yaml`. Re-running is safe.

Almost everything under `~` is a symlink into this repo, so edit the file here,
not the one in the home directory.

## agents/

One copy of the global instructions and each skill, symlinked into both agents:

|              | Claude Code                | Codex                      |
| ------------ | -------------------------- | -------------------------- |
| Instructions | `~/.claude/CLAUDE.md`      | `~/.codex/AGENTS.md`       |
| Skills       | `~/.claude/skills/<name>/` | `~/.agents/skills/<name>/` |

Both come from `agents/global.md` and `agents/skills/`. That file is *not*
named `AGENTS.md`, so Codex does not mistake it for project instructions when
the working directory is `agents/`.

**Your own skill:** `mkdir agents/skills/my-skill`, write `SKILL.md`, `./install`.
`skills/*` is globbed, so there is nothing else to edit.

**Somebody else's:** `agents/vendor/` holds upstream repos as submodules —
nothing is copied in, since these are "all rights reserved" and this repo is
public. [anthropics/skills](https://github.com/anthropics/skills) is already
there. Link one of its 19 by adding a pair to `install.conf.yaml`:

```yaml
- link:
    ~/.claude/skills/pdf:
      path: agents/vendor/anthropics-skills/skills/pdf
      create: true
    ~/.agents/skills/pdf:
      path: agents/vendor/anthropics-skills/skills/pdf
      create: true
```

One at a time on purpose: each linked skill costs a line in every session's
skill listing. Update with `git submodule update --remote agents/vendor/<name>`.

Gotcha: Cowork sessions in the desktop app skip a symlinked `~/.claude/CLAUDE.md`.
Terminal and ordinary desktop sessions follow it fine.
