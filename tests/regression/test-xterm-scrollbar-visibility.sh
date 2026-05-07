#!/usr/bin/env bash
# Regression test: xterm overlay scrollbar must use visibility:hidden, NOT display:none
#
# Date: 2026-04-06
# Bug: display:none on .xterm-scrollable-element > .scrollbar kills mouse wheel and
#      text-selection-drag-to-scroll by removing the element from pointer-event dispatch.
# Root cause: xterm.js v6 routes wheel events through its pointer-event hit-testing layer.
#             display:none removes the element from layout AND pointer-events entirely.
# Fix: visibility:hidden (keeps element in layout + pointer-events; just visually hidden)
# See: architecture.md Lesson #36

set -e

PASS=0
FAIL=0

check() {
  local desc="$1"
  local result="$2"
  if [ "$result" = "0" ]; then
    echo "  PASS: $desc"
    PASS=$((PASS+1))
  else
    echo "  FAIL: $desc"
    FAIL=$((FAIL+1))
  fi
}

CSS="ui/src/index.css"
echo "=== xterm scrollbar visibility regression (index.css) ==="

# Must NOT use display:none on the xterm overlay scrollbar
grep -q "display: none" "$CSS" && \
  grep -B2 "display: none" "$CSS" | grep -q "xterm-scrollable-element" && \
  MATCH=1 || MATCH=0
check "No 'display: none' on .xterm-scrollable-element > .scrollbar" "$MATCH"

# Must use visibility:hidden to hide the xterm scrollbar
grep -q "visibility: hidden" "$CSS"
check "Uses 'visibility: hidden' to hide xterm scrollbar" "$?"

# Must NOT use display:none on .xterm-viewport
grep -q "xterm-viewport" "$CSS" && \
  grep -A5 "xterm-viewport" "$CSS" | grep -q "display: none" && \
  MATCH=1 || MATCH=0
check "No 'display: none' on .xterm-viewport" "$MATCH"

# Monitor terminal must restore scrollbar with visibility:visible (not display:block)
grep -q "visibility: visible" "$CSS"
check "Monitor terminal restores scrollbar with 'visibility: visible'" "$?"

# Must NOT use display:block to restore monitor scrollbar (old pattern)
grep -q "xterm-monitor" "$CSS" && \
  grep -A5 "xterm-monitor" "$CSS" | grep -q "display: block" && \
  MATCH=1 || MATCH=0
check "Monitor scrollbar restore does NOT use 'display: block'" "$MATCH"

echo ""
echo "=== xterm wheel debug listener cleanup (XTerminal.jsx) ==="

JSX="ui/src/XTerminal.jsx"

# Debug wheel listener must have a corresponding removeEventListener cleanup
grep -q "handleWheelDebug" "$JSX"
check "handleWheelDebug listener defined" "$?"

grep -q "removeEventListener.*handleWheelDebug" "$JSX"
check "handleWheelDebug listener cleaned up in return()" "$?"

# Debug listener must be passive (never preventDefault on debug-only handler)
grep -A3 "handleWheelDebug" "$JSX" | grep -q "passive: true"
check "handleWheelDebug registered as passive" "$?"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
