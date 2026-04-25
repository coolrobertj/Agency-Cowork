# Agent Memory

Personal context, preferences, and working notes.
Last reviewed: 2026-04-25

---

## User

- **Name:** Robert Jordan
- **Workspace initialized:** 2026-04-12

## Active Programs

_No active programs documented yet. Run `deep-personalization` or manually add program details here._

## Key Contacts

_No contacts documented yet. Contacts will be added as they appear in daily logs and sessions._

## Tooling & Integrations

| Tool | Status | Notes |
|------|--------|-------|
| QMD (text search) | Installed (v2.1.0) | 4 collections, 38 docs indexed (2026-04-13). CLI has Unix shebang issue on Windows — not available in scheduled tasks. |
| Embeddings (BAAI/bge-small-en-v1.5) | Operational | 384-dim, on-device. 39 chunks from 38 docs. Cache at `skills/qmd-memory/cache/embeddings`. |
| Scheduled maintenance | Active | Daily memory maintenance task configured. Runs daily. |
| OneDrive sync | Not verified | Upload path not yet used. |

## Known Issues

- **QMD CLI on Windows:** The `qmd` wrapper uses a `/bin/sh` shebang, so it fails in scheduled PowerShell tasks. Manual runs (via `npx` or direct node) work. Needs a Windows-compatible wrapper or PATH fix.

## Open Questions

_None currently tracked._

---

_Keep this file under 200 lines. Archive stale facts to `memory/Knowledgebase/Program/`._
