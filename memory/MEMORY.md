# Agent Memory

Personal context, preferences, and working notes.
Last reviewed: 2026-05-12

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
| QMD (text search) | Installed (v2.1.0) | 4 collections, 38 docs indexed (last known 2026-04-28). memory-flush.ps1 failed on Windows due to /bin/sh invocation; fallback executed on 2026-05-12: `npx qmd update --no-install` updated the text index and `python skills/qmd-memory/scripts/azure-embed.py` refreshed embeddings. Embeddings saved to `skills/qmd-memory/cache/embeddings`. Consider fixing memory-flush.ps1 for Windows. |
| Embeddings (BAAI/bge-small-en-v1.5) | Refreshed (2026-05-12) | 384-dim. 39 chunks embedded across 38 documents; embeddings saved to `skills/qmd-memory/cache/embeddings` (refreshed via fallback on 2026-05-12). |
| Scheduled maintenance | Active | Daily memory maintenance task configured. Runs daily. |
| OneDrive sync | Not verified | Upload path not yet used. |

## Known Issues

- **QMD CLI on Windows:** The `qmd` wrapper uses a `/bin/sh` shebang, so it fails in scheduled PowerShell tasks. Manual runs (via `npx` or direct node) work. Re-index attempts on 2026-05-07, 2026-05-08, 2026-05-09, and 2026-05-10 failed due to the wrapper invoking `/bin/sh` (PowerShell reported '/bin/sh.exe' not found). Needs a Windows-compatible wrapper or PATH fix.

## Open Questions

_None currently tracked._

---

_Keep this file under 200 lines. Archive stale facts to `memory/Knowledgebase/Program/`._


