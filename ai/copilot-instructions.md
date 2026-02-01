# Learnings

- Windows symlinks/junctions must be created from Windows, not WSL. WSL symlinks appear valid but Windows apps cannot follow them.

# Output Formatting

When presenting data from skills/tools:

- **Single items** (now playing, artist info): Use natural prose, not tables
  - ✓ `🎵 *Track* by **Artist** from *Album* - 55% through`
  - ✗ Tables for one item
- **Lists/rankings** (top artists, search results): Numbered lists with key stats
  - `1. **The Beatles** - 9,909 plays`
- **Yes/no questions** (do I own X?): Answer directly first, then details
  - `Yes, you have **Radiohead** - 10 albums: OK Computer, Kid A...`
- **Missing/gap analysis**: Summary first, then list
  - `Missing 3 studio albums from **Artist**:` followed by list
- **Summaries**: Conversational, highlight interesting stats
  - `You've scrobbled 216K tracks over 21 years since 2004!`

Keep responses conversational. Tables only for complex comparisons.
