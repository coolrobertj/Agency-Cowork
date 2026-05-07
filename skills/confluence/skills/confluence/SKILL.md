---
name: confluence
description: >
  Browse, search, create, and edit Confluence wiki pages.
  Connects to a Confluence Server instance via Azure AD SAML SSO.
---

# Confluence Wiki Skill

This skill integrates with a Confluence Server instance (configured via
`CONFLUENCE_BASE_URL` environment variable). It supports
browsing, reading, creating, editing, and searching wiki pages across
all accessible program spaces.

## Decision Table

| User intent | Action | Command |
|---|---|---|
| List available wiki spaces | Run `spaces` | `python -m scripts.wiki_cli spaces` |
| Browse a space's top-level pages | Run `browse --space <KEY>` | `python -m scripts.wiki_cli browse --space PROJ1` |
| Browse children of a specific page | Run `browse --page <ID>` | `python -m scripts.wiki_cli browse --page 12345678` |
| Show full page tree hierarchy | Run `tree --space <KEY>` | `python -m scripts.wiki_cli tree --space PROJ1 --depth 3` |
| Read a page (markdown output) | Run `read --id <ID>` | `python -m scripts.wiki_cli read --id 23456789` |
| Read a page (raw HTML) | Run `read --id <ID> --raw` | `python -m scripts.wiki_cli read --id 23456789 --raw` |
| Find a page by title in a space | Run `read --space <KEY> --title "..."` | `python -m scripts.wiki_cli read --space PROJ1 --title "Meeting Notes"` |
| Search pages by text | Run `search --query "..."` | `python -m scripts.wiki_cli search --query "release" --space PROJ1` |
| Search with CQL | Run `search --cql "..."` | `python -m scripts.wiki_cli search --cql 'type=page AND space=PROJ1 AND title~"Meeting"'` |
| Create a new page | Run `create` | `python -m scripts.wiki_cli create --space PROJ1 --title "New Page" --body "# Content" --parent 12345678` |
| Create page from file | Run `create --body-file` | `python -m scripts.wiki_cli create --space PROJ1 --title "Report" --body-file report.md` |
| Edit a page (replace) | Run `edit --id <ID>` | `python -m scripts.wiki_cli edit --id 23456789 --body "# Updated content"` |
| Append to a page | Run `edit --id <ID> --append` | `python -m scripts.wiki_cli edit --id 23456789 --body "## New Section" --append` |
| Create/append a table | Run `table` | `python -m scripts.wiki_cli table --id 23456789 --headers "Col1,Col2" --rows "A,B;C,D"` |
| Get JSON output | Add `--json` flag | `python -m scripts.wiki_cli --json spaces` |

**IMPORTANT**: Always `cd skills/confluence` before running commands.

## Authentication

### How it works
- Uses **Azure AD SAML SSO** via Playwright CDP (Chrome DevTools Protocol) connection
- Launches a separate Edge process with `--remote-debugging-port=9225` and standalone profile at `%LOCALAPPDATA%/AgencyCowork/confluence-browser`
- **Works even when Edge is already open** for normal use (no profile lock conflicts)
- Cookies (`seraph.confluence`, `JSESSIONID`) are cached at `%LOCALAPPDATA%/AgencyCowork/confluence-browser/cookies.json`
- PATs are **not available** on this instance (admin-disabled)
- NTLM/Negotiate returns "Anonymous" — does **not** pass tented space auth

### First-time setup
```bash
cd skills/confluence
python -m scripts.auth --interactive
# Browser opens → SAML redirects to Azure AD → SSO completes
# Press Enter after login succeeds
```

### Session verification
```bash
python -m scripts.auth --verify
```

### If session expires
```bash
python -m scripts.auth --interactive
```

The auth module automatically checks cached cookies before re-authenticating. If cookies are valid, no browser is launched.

## Known Spaces

Spaces are configured per-organization. Use `python -m scripts.wiki_cli spaces` to list
accessible spaces. Common patterns:

| Key | Name | Use |
|-----|------|-----|
| PROJ1 | Project Alpha | Project Alpha program wiki |
| PROJ2 | Project Beta | Project Beta program wiki |
| KB | Knowledge Base | General knowledge base |

> **Note:** Replace the example spaces above with your organization's actual Confluence spaces.
> An org-specific setup skill can populate these automatically.

## CQL Search Examples

| Goal | CQL |
|------|-----|
| Pages in PROJ1 with "meeting" in title | `type=page AND space=PROJ1 AND title~"meeting"` |
| Pages modified in last 7 days | `type=page AND lastModified >= now("-7d")` |
| Pages by a specific author | `type=page AND creator = "jdoe"` |
| All pages in multiple spaces | `type=page AND space IN (PROJ1, PROJ2, KB)` |
| Blog posts in PROJ1 | `type=blogpost AND space=PROJ1` |
| Pages with a label | `type=page AND label = "release"` |
| Pages under a parent | `type=page AND ancestor = 12345678` |

## Input Format

### Body content
The CLI accepts body content in two formats:

1. **HTML** (Confluence storage format) — detected if content starts with `<`
2. **Markdown** — auto-converted to Confluence storage HTML

Markdown conversion supports: headers, lists, bold, italic, code blocks (with language), paragraphs.

### Tables
Use `--headers` and `--rows` for structured table input:
- Headers: comma-separated (`"Name,Status,Owner"`)
- Rows: semicolon-separated rows, comma-separated cells (`"Item1,Done,Alice;Item2,Open,Bob"`)

## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| 401 Unauthorized | Session expired | Run `python -m scripts.auth --interactive` |
| 403 Forbidden | No access to space | Verify you have space permissions in Confluence |
| 404 Not Found | Wrong page ID or space key | Double-check the ID/key via `search` or `browse` |
| "type: anonymous" | Cookies not working | Re-authenticate: `python -m scripts.auth --interactive` |
| Connection error | VPN/network issue | Verify corp network/VPN connectivity |

## Design Notes

- **Playwright is only used for authentication** — all API calls use Python `requests` with extracted cookies for speed and reliability
- **CDP port 9225** is used for Confluence (Teams=9223, meeting-summary=9224)
- **Version auto-increment** — `update_page` automatically fetches the current version and increments it to avoid edit conflicts
- **Markdown input** — pages can be created/edited with markdown; the CLI auto-converts to Confluence storage format
- **No PAT support** — PATs are disabled on this Confluence instance; SAML cookie auth is the only path
