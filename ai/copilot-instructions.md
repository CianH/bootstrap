# Learnings (Confirmed)
<!-- 3+ weighted occurrences, actively useful -->

- Windows symlinks/junctions must be created from Windows, not WSL. WSL symlinks appear valid but Windows apps cannot follow them. <!-- added:2026-01-15 cited:2 -->
- When writing skills, see `scripts/ai/skills/AUTHORING.md`. <!-- added:2026-02-04 cited:2 -->
- Don't over-engineer evolving systems. AI tooling changes weekly—keep friction low or the system won't get used. <!-- added:2026-02-05 cited:4 -->

# Learnings (Tentative)
<!-- 2+ weighted occurrences, monitoring for confirmation -->

- Use local `date` command for timestamps in diary entries, not the UTC `current_datetime` from system prompt. <!-- added:2026-02-06 cited:2 source:diary-2026-02-02-s2,diary-2026-02-03-s1 -->
- Archive or delete stale docs — don't let them rot with outdated information. <!-- added:2026-02-06 cited:3 source:diary-2026-02-04-s1,diary-2026-02-05-s2,decisions -->


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

# Machine-Specific

- **Disk space:** This Mac has limited space. Check `df -h ~` before large operations. Plex transcoding often fills disk.
