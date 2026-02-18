#!/usr/bin/env bash
set -euo pipefail

# /rrr step 1 + 1.5 gather commands (per SKILL.md)
# Intended to be run from repo root.

date "+%H:%M %Z (%A %d %B %Y)"
echo

git log --oneline -10
echo

git diff --stat HEAD~5 2>/dev/null || echo "(git diff --stat unavailable)"
echo

# Pulse context (optional)
if [ -f psi/data/pulse/project.json ]; then
  echo "--- psi/data/pulse/project.json ---"
  cat psi/data/pulse/project.json
  echo
fi

if [ -f psi/data/pulse/heartbeat.json ]; then
  echo "--- psi/data/pulse/heartbeat.json ---"
  cat psi/data/pulse/heartbeat.json
  echo
fi

