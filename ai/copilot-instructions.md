# Rules

- Never "remember" or "note" something without writing it to a persistent file. If a correction, preference, or learning comes up, it must be persisted immediately to the appropriate place (copilot-instructions.md, a SKILL.md, or docs/notes/) — not just acknowledged in conversation. Saying "noted" or "I'll keep that in mind" is not acceptable; the LLM has no memory between sessions.

# Learnings (Confirmed)
<!-- 3+ weighted occurrences, actively useful -->

- Windows symlinks/junctions must be created from Windows, not WSL. WSL symlinks appear valid but Windows apps cannot follow them. <!-- added:2026-01-15 cited:2 -->
- When writing skills, see `scripts/ai/skills/AUTHORING.md`. <!-- added:2026-02-04 cited:2 -->
- Don't over-engineer evolving systems. AI tooling changes weekly—keep friction low or the system won't get used. <!-- added:2026-02-05 cited:4 -->
- "Give me a CSV" means inline comma-separated values (e.g. `val1,val2,val3`), not a table, not newline-separated, not a file. <!-- added:2026-02-08 cited:1 source:explicit -->
- Amend, don't stack fix commits. When a mistake is immediately corrected, squash into the prior commit (`git commit --amend` or `git reset --soft HEAD~N && commit`). <!-- added:2026-02-08 cited:1 source:explicit -->
- Never use `git add -A` — always stage specific files explicitly. <!-- added:2026-02-08 cited:1 source:explicit -->
- Use conventional commits (https://www.conventionalcommits.org). SKILL.md files are code changes — NEVER use `docs:` or `chore:`. Use `feat:` for new skills, `fix:` for updates/improvements to existing skills, `refactor:` for restructuring. Examples: ✅ `feat: add trakt skill`, ✅ `fix: update diary skill template`, ❌ `chore: update diary skill`, ❌ `docs: update diary skill`. <!-- added:2026-02-08 cited:3 source:explicit -->
- Make logical commits — group by theme/change, not by file type or "everything at once". <!-- added:2026-02-08 cited:1 source:explicit -->

# Learnings (Tentative)
<!-- 2+ weighted occurrences, monitoring for confirmation -->

- Use local `date` command for timestamps in diary entries, not the UTC `current_datetime` from system prompt. <!-- added:2026-02-06 cited:2 source:diary-2026-02-02-s2,diary-2026-02-03-s1 -->
- Archive or delete stale docs — don't let them rot with outdated information. <!-- added:2026-02-06 cited:3 source:diary-2026-02-04-s1,diary-2026-02-05-s2,decisions -->
- Explain technical reasoning — don't hand-wave. User wants to understand *why*, not just *what*. <!-- added:2026-02-08 cited:2 source:diary-2026-02-06-s2,diary-2026-02-07-s2 -->


# Learnings (Archived)
<!-- Moved here by prune skill, keep for reference -->

# Output Formatting

- **Single items**: prose, not tables
- **Lists/rankings**: numbered with key stats (`1. **Item** - 500 plays`)
- **Yes/no questions**: answer directly first, then details
- **Gap/missing analysis**: summary first, then list
- **Tables**: only for complex multi-column comparisons

# Session Reflection

At end of significant sessions, consider:
1. What patterns emerged that should become instructions?
2. What notes should be written to docs/notes/?
3. What existing docs need updates?

See docs/notes/ai-memory-workflow.md for the full workflow.

