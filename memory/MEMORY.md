# Agent Memory

Personal context, preferences, and working notes.
Last reviewed: 2026-05-24

---

## User

- **Name:** Robert Jordan
- **Workspace initialized:** 2026-04-12 (past)

## Active Programs

_No active programs documented yet. Run `deep-personalization` or manually add program details here._

## Key Contacts

_No contacts documented yet. Contacts will be added as they appear in daily logs and sessions._

## Tooling & Integrations

| Tool | Status | Notes |
|------|--------|-------|
| QMD (text search) | Installed (v2.1.0) | 4 collections, 38 docs indexed. memory-flush.ps1 fails on Windows due to /bin/sh invocation; fallback consistently successful since 2026-05-12: `npx qmd update --no-install` + `python skills/qmd-memory/scripts/azure-embed.py`. Last refreshed 2026-05-20. |
| Embeddings (BAAI/bge-small-en-v1.5) | Refreshed (2026-05-20) | 384-dim. 39 chunks embedded across 38 documents; embeddings saved to `skills/qmd-memory/cache/embeddings`. Fallback approach working reliably. |
| Scheduled maintenance | Active | Daily memory maintenance task configured. Runs daily. |
| OneDrive sync | Not verified | Upload path not yet used. |

## Known Issues

- **QMD CLI on Windows:** The `qmd` wrapper uses a `/bin/sh` shebang, so it fails in scheduled PowerShell tasks. Manual runs (via `npx` or direct node) work. Re-index attempts on 2026-05-07, 2026-05-08, 2026-05-09, and 2026-05-10 failed due to the wrapper invoking `/bin/sh` (PowerShell reported '/bin/sh.exe' not found). Fallback re-index via `npx qmd update --no-install` succeeded on 2026-05-12. Consider implementing a Windows-compatible wrapper or scheduled-task-friendly wrapper to avoid manual workarounds.

## Open Questions

_None currently tracked._

---

_Keep this file under 200 lines. Archive stale facts to `memory/Knowledgebase/Program/`._


## Maintenance review: 2026-05-14
- Reviewed daily on 2026-05-14. Minor updates applied.

## Maintenance review: 2026-05-15
- Daily memory maintenance performed: compacted logs (none to archive), ran fallback re-index (`npx qmd update --no-install`) and azure embedding refresh (`python skills/qmd-memory/scripts/azure-embed.py`); embeddings saved to `skills/qmd-memory/cache/embeddings` (39 chunks). MEMORY.md updated and changes committed.

## Maintenance review: 2026-05-16
- Daily memory maintenance completed: compacted logs (none), ran fallback QMD re-index and refreshed Azure embeddings. No Active Programs recorded this week and no new Key Contacts detected in daily logs (2026-05-10 through 2026-05-15). MEMORY.md updated and changes committed.

## Maintenance review: 2026-05-20
- Daily memory maintenance performed: compacted logs (none to archive); ran `npx qmd update --no-install` (text re-index) and `python skills/qmd-memory/scripts/azure-embed.py` (sentence_transformer provider) to refresh embeddings; embeddings saved to `skills/qmd-memory/cache/embeddings`. MEMORY.md and archive updated and changes committed.


## Maintenance review: 2026-05-22
- Daily memory maintenance performed: fallback qmd re-index and azure embedding refresh successful; embeddings saved to skills/qmd-memory/cache/embeddings. MEMORY.md last reviewed and updated.

## Maintenance review: 2026-05-23
- Weekly MEMORY.md review completed: verified Active Programs section (none documented), Key Contacts section (none new from daily logs 2026-05-19, 2026-05-20, 2026-05-22), and Tooling & Integrations (all current; QMD and embeddings last refreshed 2026-05-22). No stale facts detected. File is 58 lines (under 200-line limit). Updated "Last reviewed" date to 2026-05-23.

## Maintenance review: 2026-05-24
- Daily memory maintenance completed: compacted 6 logs (2026-05-11 through 2026-05-16) into archive; reviewed MEMORY.md — verified Active Programs (none), Key Contacts (none new), and Tooling & Integrations (QMD v2.1.0 with fallback approach working, embeddings refreshed 2026-05-22). No stale facts or outdated dates detected. Re-indexed QMD and refreshed Azure embeddings; embeddings saved to cache/embeddings. Updated "Last reviewed" date to 2026-05-24. Changes committed and pushed.

