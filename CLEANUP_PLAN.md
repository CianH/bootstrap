# Bootstrap Repo Cleanup Plan

**Date Started:** 2026-01-16
**Last Updated:** 2026-01-17

## Summary

Cleanup and modernization of the bootstrap repo for Windows/WSL development environment setup.

## CURRENT STATUS (2026-01-17)

**Windows cleanup COMPLETE** - Ready to push to origin.

## Completed Work

### Repository Structure Reorganization
- [x] Moved `powershell/` → `win/powershell/`
- [x] Moved registry settings → `win/regkeys/` (extracted from scripts)
- [x] Moved Windows Terminal settings → `win/terminal/`
- [x] Created `win/scripts/` for one-time setup scripts
- [x] Consolidated `.gitattributes` and `.gitignore` to repo root
- [x] Replaced `cleanup_new_machine.bat` with PowerShell equivalents
- [x] Added `ai/copilot-instructions.md` for system-wide AI learnings

### PowerShell Profile Modernization (`win/powershell/Microsoft.PowerShell_profile.ps1`)
- [x] Removed verbose startup warnings/messages (silent load)
- [x] Future-proofed VS detection (2019-2025)
- [x] Removed redundant `code` alias (already in PATH)
- [x] Added admin detection + `[ADMIN]` window title
- [x] Added navigation utilities: `..`, `...`, `mkcd`
- [x] Added hash functions: `md5`, `sha256`
- [x] Added utilities: `ll`, `flushdns`
- [x] Added PSReadLine enhancements (HistoryNoDuplicates, MenuComplete)
- [x] Added PS7+ guarded features (prediction, Ctrl shortcuts)

### CianTools Module Cleanup
- [x] Removed legacy `Invoke-Elevated`/`sudo` (Windows 11 has native sudo)
- [x] Fixed broken `sudo.ps1` script reference
- [x] Gitignore external modules (posh-git), keep only CianTools tracked
- [x] Added posh-git auto-install to `basic_machine_setup.ps1`

### Media Functions
- [x] Rewrote `Remove-MkvSubtitles` to keep English + unknown language tracks
  - Added `-RemoveUnknown` switch to optionally remove unknown tracks
  - Shows warning for unknown language tracks
- [x] Added `Export-MkvSubtitles` - extracts embedded subs to sidecar files
  - Proper naming: `Movie.en.srt`, `Movie.es.forced.srt`
  - Detects format (SRT, ASS, PGS, VobSub, WebVTT)
  - Pipeline support for batch processing

### Final Cleanup
- [x] Updated sudo references in System.ps1 to use Win11 native sudo syntax

## Current Repository Structure

```
bootstrap/
├── ai/
│   └── copilot-instructions.md  # Symlinked to ~/.copilot/
├── .bash_aliases          # Linux shell aliases (symlinked to oh-my-zsh)
├── .bashrc                # Bash config
├── .gitattributes         # Line ending normalization
├── .gitignore             # Ignore posh-git, .github, etc.
├── .inputrc               # Readline config
├── .profile               # Login shell config
├── .vimrc                 # Vim config
├── bash_setup.sh          # Linux/WSL setup script
├── LICENSE
├── README.md
└── win/
    ├── powershell/        # SYMLINKED to Documents\WindowsPowerShell & PowerShell
    │   ├── Microsoft.PowerShell_profile.ps1
    │   ├── Modules/
    │   │   └── CianTools/     # Custom module (tracked)
    │   │       ├── Functions/
    │   │       │   ├── Configuration.ps1
    │   │       │   ├── Development.ps1
    │   │       │   ├── FileSystem.ps1
    │   │       │   ├── Media.ps1
    │   │       │   ├── System.ps1
    │   │       │   └── Utilities.ps1
    │   │       ├── CianTools.psd1
    │   │       └── CianTools.psm1
    │   └── .github/           # (gitignored)
    ├── regkeys/           # Registry tweaks (.reg files)
    ├── scripts/           # One-time setup/maintenance scripts
    │   ├── basic_machine_setup.ps1
    │   ├── cleanup_shortcuts.ps1
    │   ├── disable_scheduled_tasks.ps1
    │   ├── privacy_settings.ps1
    │   └── service_cleanup.ps1
    └── terminal/          # Windows Terminal settings
        └── settings.json
```

## Pending/Future Work

### Short Term
- [ ] Review WSL-side setup (bash_setup.sh, .bashrc, etc.)
- [ ] Push to origin
- [ ] Add more comprehensive README documentation

### Potential Enhancements
- [ ] Consider oh-my-posh for fancy prompts (optional)

## WSL Symlink Fix Applied

Fixed broken symlink during session:
```
/home/cian/.oh-my-zsh/custom/aliases.zsh -> /mnt/c/Users/Cian/github/bootstrap/.bash_aliases
```
(Was incorrectly pointing to `/home/cian/github/bootstrap/.bash_aliases`)

## Key Aliases Reference

### Profile One-Liners
- `..` / `...` - Navigate up directories
- `md5` / `sha256` - File hash shortcuts
- `mkcd` - Create directory and cd into it
- `ll` - List all files including hidden
- `flushdns` - Clear DNS cache

### CianTools (type `mytools` to see all)
- `which` - Find command path
- `touch` - Create/update file
- `find` - Recursive file search
- `pro` - Edit profile
- `reload` - Reload profile
- `hosts` - Edit hosts file
- `crc32` - File checksum
- `pp` - Push to project directory
