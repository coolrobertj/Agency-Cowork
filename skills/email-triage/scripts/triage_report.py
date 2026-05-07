"""Triage report — Teams summary formatting + Todo sync orchestration.

Generates a Teams-ready summary from triage results and optionally
creates Todo tasks for urgent/needs_response items.

Usage:
    from scripts.triage_report import post_triage_summary
    post_triage_summary(result, profile)
"""

import html
import json
import sys
from datetime import datetime, timezone

sys.path.insert(0, ".")

from scripts.triage_engine import TriageResult, format_summary


def format_teams_html(result: TriageResult) -> str:
    """Format triage results as Teams-compatible HTML."""
    html_parts = []

    # Build draft link lookup: message_id → draft deeplink
    draft_links = {}
    for d in (result.draft_results or []):
        if d.get("draft_id") and d.get("message_id") and d.get("type") != "error":
            from scripts.mail_client import build_outlook_deeplink
            draft_links[d["message_id"]] = build_outlook_deeplink(d["draft_id"])

    # Header
    ts = result.timestamp[:16].replace("T", " ")
    html_parts.append(f"<h3>📬 Email Triage — {ts} UTC</h3>")
    html_parts.append(f"<p>{result.summary_line()}</p>")

    if not result.actionable_items:
        html_parts.append("<p>✅ No urgent or action-required emails.</p>")
        return "\n".join(html_parts)

    # Urgent
    if result.urgent_items:
        html_parts.append("<h4>🔴 Urgent</h4><ul>")
        for r in result.urgent_items:
            contact = f" ({html.escape(r['contact_name'])})" if r.get("contact_name") else ""
            link = f' <a href="{html.escape(r["web_link"])}">📧</a>' if r.get("web_link") else ""
            draft_link = draft_links.get(r.get("message_id"), "")
            draft_html = f' | <a href="{html.escape(draft_link)}">📝 Draft</a>' if draft_link else ""
            html_parts.append(
                f"<li><b>{html.escape(r['sender'])}{contact}</b>: {html.escape(r['subject'])}{link}{draft_html}</li>"
            )
        html_parts.append("</ul>")

    # Needs Response
    if result.needs_response_items:
        html_parts.append("<h4>🟡 Needs Response</h4><ul>")
        for r in result.needs_response_items:
            contact = f" ({html.escape(r['contact_name'])})" if r.get("contact_name") else ""
            link = f' <a href="{html.escape(r["web_link"])}">📧</a>' if r.get("web_link") else ""
            draft_link = draft_links.get(r.get("message_id"), "")
            draft_html = f' | <a href="{html.escape(draft_link)}">📝 Draft</a>' if draft_link else ""
            html_parts.append(
                f"<li><b>{html.escape(r['sender'])}{contact}</b>: {html.escape(r['subject'])}{link}{draft_html}</li>"
            )
        html_parts.append("</ul>")

    # Stats footer
    fyi_count = result.stats.get("fyi", 0)
    noise_count = result.stats.get("noise", 0)
    archive_count = result.stats.get("archive", 0)
    draft_count = len(draft_links)
    draft_note = f", {draft_count} draft(s) ready" if draft_count else ""
    html_parts.append(
        f"<p><i>Also: {fyi_count} FYI, {noise_count} noise, "
        f"{archive_count} archived{draft_note}</i></p>"
    )

    return "\n".join(html_parts)


def format_teams_text(result: TriageResult) -> str:
    """Format triage results as plain text for Teams."""
    return format_summary(result, verbose=False)


def sync_to_todo(result: TriageResult, profile: dict) -> dict:
    """Create Todo tasks for urgent and needs_response items.

    Returns dict with created/skipped counts.
    """
    prefs = profile.get("preferences", {})
    if not prefs.get("todo_enabled", True):
        return {"created": 0, "skipped": 0, "disabled": True}

    try:
        from scripts.todo_sync import sync_batch
    except ImportError:
        print("  ⚠ todo_sync not available, skipping Todo sync")
        return {"created": 0, "skipped": 0, "error": "import_error"}

    # Build triage items for todo_sync
    items = []
    for r in result.actionable_items:
        items.append({
            "message_id": r["message_id"],
            "subject": r["subject"],
            "sender": r["sender"],
            "sender_email": r["sender_email"],
            "received": r["received"],
            "category": r["category"],
            "web_link": r.get("web_link", ""),
        })

    if not items:
        return {"created": 0, "skipped": 0}

    try:
        stats = sync_batch(items, folder_name=prefs.get("todo_folder", "Email Triage"))
        return stats
    except Exception as e:
        print(f"  ⚠ Todo sync error: {e}")
        return {"created": 0, "skipped": 0, "error": str(e)}


def generate_report(result: TriageResult, profile: dict,
                    output_format: str = "text") -> str:
    """Generate a triage report in the specified format.

    Args:
        result: TriageResult from triage engine
        profile: Triage profile
        output_format: "text", "html", or "json"

    Returns:
        Formatted report string.
    """
    if output_format == "html":
        return format_teams_html(result)
    elif output_format == "json":
        return json.dumps({
            "timestamp": result.timestamp,
            "summary": result.summary_line(),
            "stats": result.stats,
            "urgent": result.urgent_items,
            "needs_response": result.needs_response_items,
            "new_count": result.new_count,
            "skipped": result.skipped_count,
            "errors": result.error_count,
        }, indent=2, default=str)
    else:
        return format_summary(result, verbose=True)
