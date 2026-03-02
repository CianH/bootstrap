## Environment
- Windows symlinks/junctions must be created from Windows, not WSL. WSL symlinks appear valid but Windows apps cannot follow them. <!-- added:2026-01-30 cited:2 source:explicit -->


## Git
- Amend only the HEAD commit, and only when fixing a mistake introduced in that same commit. Never amend older commits or unrelated commits — make a new commit instead. Exception: PR review feedback (from reviewers or linters) should be separate commits so iterations are visible. <!-- added:2026-02-02 cited:3 source:explicit -->
- Never use `git add -A` — always stage specific files explicitly. <!-- added:2026-02-02 cited:2 source:explicit -->
- Use conventional commits (https://www.conventionalcommits.org). SKILL.md files are code changes — NEVER use `docs:` or `chore:`. Use `feat:` for new skills, `fix:` for updates/improvements to existing skills, `refactor:` for restructuring. Examples: ✅ `feat: add trakt skill`, ✅ `feat: add --file-ids flag to sonarr update-files`, ✅ `fix: update diary skill template`, ❌ `chore: update diary skill`, ❌ `docs: update diary skill`. Adding new flags/commands/capabilities to a skill's backing code is ALWAYS `feat:`, never `fix:`. Actual documentation (READMEs, notes, non-skill markdown) uses `docs:` normally. <!-- added:2026-02-06 cited:4 source:explicit -->
- Make logical commits — group by theme/change, not by file type or "everything at once". <!-- added:2026-02-06 cited:1 source:explicit -->

## Quality
- Don't over-engineer evolving systems. AI tooling changes weekly—keep friction low or the system won't get used. <!-- added:2026-02-06 cited:1 source:explicit -->
- Challenge your own work before presenting it. Ask: "Would a staff engineer approve this?" <!-- added:2026-02-06 cited:1 -->
- Verify before claiming done — run the command, read the output, then report the result. Never say "should work" or "seems to" without evidence. If you didn't run it, say so. <!-- added:2026-02-06 cited:2 -->
- When verifying work, compare against the original request — not your own code. Re-read the user's ask, then check if the output matches. "Looks right to me" after reading your own code is not verification. <!-- added:2026-02-19 cited:0 source:x-bookmarks-2026-02-19/harness-engineering -->
- When a user states a constraint (e.g. "you can't run sudo"), internalize it fully. Do not attempt the prohibited action on the next turn. <!-- added:2026-02-14 cited:0 source:explicit -->
- Find root causes. No temporary fixes or band-aids — apply senior developer standards. <!-- added:2026-02-06 cited:1 -->
- Question the problem framing before implementing — a tracking document, issue description, or user request may mischaracterize the root cause. Verify the *why*, not just the *what*. <!-- added:2026-02-12 cited:0 source:explicit -->
- Never invent numbers or statistics — say "this needs to be measured" instead of guessing. Benchmark, don't estimate. Same applies to vague quantifiers: "most", "many", "few" are claims requiring evidence — say "5 of 60" not "most". <!-- added:2026-02-08 cited:2 -->
- Never answer data questions from memory or reasoning alone — always re-read the actual output. If the data was from a previous command and is no longer in context, re-run it. <!-- added:2026-02-08 cited:1 -->
- If a fix feels hacky, pause and ask: "Knowing everything I know now, is there a cleaner solution?" Skip this for simple, obvious fixes. <!-- added:2026-02-09 cited:0 -->
- No user data in persistent artifacts. Commit messages, docs, notes, skill files, and examples must use generic placeholders — never specific show names, filenames, paths, IPs, or other identifying data. The constraint applies everywhere, not just file contents. <!-- added:2026-02-15 cited:0 source:explicit -->

## Workflow
- Notes are stored at `$PWD/docs/notes/`. <!-- added:2026-02-15 cited:0 source:explicit -->
- Never "remember" or "note" something without writing it to a persistent file. If a correction, preference, or learning comes up, it must be persisted immediately to the appropriate place (copilot-instructions.md, a SKILL.md, or docs/notes/) — not just acknowledged in conversation. Saying "noted" or "I'll keep that in mind" is not acceptable; the LLM has no memory between sessions. After being corrected on a mistake, proactively suggest persisting the lesson — don't wait for the user to ask. <!-- added:2026-02-02 cited:3 source:explicit -->
- For multi-step or research-heavy tasks, prefer delegating to sub-agents over doing everything inline — this preserves main context and enables parallelism. Keep each sub-agent's task focused and specific; broad multi-step prompts with fallback strategies cause silent failures. Break complex work into multiple small agents rather than one ambitious one. <!-- added:2026-02-09 cited:1 -->
- If something goes sideways, stop and re-plan immediately — don't keep pushing on a broken approach. <!-- added:2026-02-09 cited:1 -->
- Archive or delete stale docs — don't let them rot with outdated information. <!-- added:2026-02-06 cited:1 -->

## Communication
- Explain technical reasoning — don't hand-wave. User wants to understand *why*, not just *what*. <!-- added:2026-02-06 cited:2 -->
- When user says "I don't need X", delete X entirely — don't repackage or reword it. <!-- added:2026-02-12 cited:0 source:explicit -->
- When user corrects you, apply it fully and immediately — don't half-apply. <!-- added:2026-02-12 cited:0 source:explicit -->
- Don't add features the user didn't ask for. <!-- added:2026-02-12 cited:0 source:explicit -->
- When user says "show me a draft" or similar, do NOT create files, directories, or make changes until explicitly told to proceed. Present the draft as text in conversation only. <!-- added:2026-02-13 cited:0 source:explicit -->
- Never ask a question and then act on the answer in the same turn. If you ask, wait for the response. <!-- added:2026-02-14 cited:0 source:explicit -->

## Output
- **Single items**: prose, not tables <!-- added:2026-02-08 cited:1 source:explicit -->
- **Lists/rankings**: numbered with key stats (`1. **Item** - 500 plays`) <!-- added:2026-02-08 cited:1 source:explicit -->
- **Yes/no questions**: answer directly first, then details <!-- added:2026-02-08 cited:1 source:explicit -->
- **Gap/missing analysis**: summary first, then list <!-- added:2026-02-08 cited:1 source:explicit -->
- **Tables**: only for complex multi-column comparisons <!-- added:2026-02-08 cited:1 source:explicit -->
- "Give me a CSV" means inline comma-separated values (e.g. `val1,val2,val3`), not a table, not newline-separated, not a file. <!-- added:2026-02-08 cited:1 source:explicit -->

## Tools
- When writing skills, see `scripts/ai/skills/AUTHORING.md`. <!-- added:2026-02-02 cited:3 -->
- When `web_fetch` truncates content (hits `max_length`) or loses fidelity (strips code blocks, images, structure), fall back to `curl` with `-H "Accept: text/markdown"`. Cloudflare-fronted sites will return clean server-converted markdown with ~80-94% fewer tokens than raw HTML. The response includes an `x-markdown-tokens` header for token budgeting before reading the body. <!-- added:2026-02-14 cited:0 source:explicit -->
- Before calling any skill CLI, read its SKILL.md to confirm the exact command name and arguments. Never guess CLI syntax — the SKILL.md exists precisely to prevent that. If a command fails, re-read SKILL.md before retrying. <!-- added:2026-03-01 cited:0 source:explicit -->

## Session Reflection

At end of significant sessions, consider:
1. What patterns emerged that should become instructions?
2. What notes should be written to docs/notes/?
3. What existing docs need updates?

See docs/notes/ai-memory-workflow.md for the full workflow.

