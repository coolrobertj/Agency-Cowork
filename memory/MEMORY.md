# Agent Memory

Personal context, preferences, and working notes.
Last reviewed: 2026-05-22

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
| QMD (text search) | Installed (v2.1.0) | 4 collections, 38 docs indexed (re-indexed 2026-05-13). memory-flush.ps1 failed on Windows due to /bin/sh invocation; fallback executed on 2026-05-13: `npx qmd update --no-install` updated the text index and `python skills/qmd-memory/scripts/azure-embed.py` refreshed embeddings. Embeddings saved to `skills/qmd-memory/cache/embeddings`. Consider fixing memory-flush.ps1 for Windows. |
| Embeddings (BAAI/bge-small-en-v1.5) | Refreshed (2026-05-13) | 384-dim. 39 chunks embedded across 38 documents; embeddings saved to `skills/qmd-memory/cache/embeddings` (refreshed via fallback on 2026-05-13). |
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

