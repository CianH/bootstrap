# AGENTS.md

Project instructions for the bootstrap repository.

## What this repo is

Personal dotfiles and machine configuration for Windows, macOS, and Linux. Files in this repo are committed publicly on GitHub. Anyone can read them.

## Path resolution: never hardcode filesystem paths into committed files

Every file committed to this repo could be read by the public. Hardcoding a local filesystem path into a committed file leaks information about the machine layout (where the user's repos live, their home directory structure, anything else in their dev tree).

The bootstrap pattern that solves this: `setup.sh` resolves absolute paths dynamically at install time using `SCRIPT_DIR="${0:A:h}"` and writes machine-specific values into per-machine, gitignored files like `~/.gitconfig.local` or `~/.copilot/`. The shared, committed configs (`.gitconfig`, `.zshrc`, `aliases.zsh`, etc.) stay portable: zero references to specific filesystem locations.

When adding a new piece of configuration that needs an absolute path:

1. Resolve the path in `setup.sh` from `SCRIPT_DIR` (the actual cloned location, not an assumed one)
2. Write it into a per-machine file that is either gitignored (`.gitconfig.local`) or outside the repo (`~/.copilot/`, `~/.zsh/`)
3. Never put the resolved path in a file that gets committed to this repo

If a config format requires an absolute path inline (e.g. `core.hooksPath` in gitconfig), put it in the per-machine override file (`~/.gitconfig.local`), not the shared one (`.gitconfig`). The shared `.gitconfig` already includes `~/.gitconfig.local`, so settings there override silently.

Examples already following this pattern: user.email and credential helpers (migrated by `setup.sh` into `~/.gitconfig.local` from the previous gitconfig); Copilot CLI memory directory (symlinked from `~/.copilot/memory` into `~/dev/docs/memory`, with `setup.sh` resolving the actual path).

## Commit messages

Same rule as commit message bodies in general (see the global commit-msg hook installed by `setup.sh`): no manual line wrapping at 72 characters. Write naturally flowing sentences. Line breaks are for paragraph breaks, lists, and trailers only.

Additionally, the same path-leak rule applies to commit messages: never reference specific local filesystem paths in commit messages. Use generic descriptions ("the per-machine gitconfig override file") instead of literal paths ("~/dev/bootstrap/...").

## Setup script changes

`setup.sh` is idempotent and safe to re-run. Any addition must preserve this: check current state before making changes, and exit cleanly if already configured. Use the existing `link_file` helper for symlinks (it backs up existing files to `.old` before replacing).
