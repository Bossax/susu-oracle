#!/usr/bin/env bash
set -euo pipefail

# Run from your workspace root (the directory that contains psi/)
ROOT="$(pwd)"
PULSE_DIR="$ROOT/psi/data/pulse"
PROJECT="$PULSE_DIR/project.json"
HEART="$PULSE_DIR/heartbeat.json"

mkdir -p "$PULSE_DIR"

# Initialize with a schema /rrr-style tools can read
if [ ! -f "$PROJECT" ]; then
  cat >"$PROJECT" <<'JSON'
{
  "projectName": "Knowledge_System",
  "createdAt": null,
  "totalSessions": 0,
  "avgMessagesPerSession": 0,
  "sizes": {},
  "branches": {}
}
JSON
fi

if [ ! -f "$HEART" ]; then
  cat >"$HEART" <<'JSON'
{
  "lastSession": null,
  "active": true,
  "streak": { "days": 0 },
  "weekChange": 0,
  "today": { "messages": 0 }
}
JSON
fi

python - <<'PY'
import json, datetime, pathlib, re, os

root = pathlib.Path(".").resolve()
p_project = root / "psi" / "data" / "pulse" / "project.json"
p_heart   = root / "psi" / "data" / "pulse" / "heartbeat.json"
retro_dir = root / "psi" / "memory" / "retrospectives"

# Helper to load JSON safely
def load(path):
    if not path.exists(): return {}
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except:
        return {}

proj = load(p_project)
heart = load(p_heart)

# 1. Find the latest retrospective by FILENAME timestamp (YYYY-MM/DD/HH.MM_title.md)
# This avoids OS modification time issues.
best_dt = None
best_path = None
now = datetime.datetime.now().astimezone()

# Regex to match HH.MM prefix in filename
name_pat = re.compile(r"^(\d{2})\.(\d{2})_.*\.md$")

if retro_dir.exists():
    # Walk year/month/day directories
    for m_dir in retro_dir.iterdir():
        if not m_dir.is_dir(): continue
        # Expected: YYYY-MM
        parts = m_dir.name.split('-')
        if len(parts) != 2: continue
        
        for d_dir in m_dir.iterdir():
            if not d_dir.is_dir(): continue
            # Expected: DD
            if not d_dir.name.isdigit(): continue
            
            for f in d_dir.glob("*.md"):
                m = name_pat.match(f.name)
                if m:
                    try:
                        hh, mm = int(m.group(1)), int(m.group(2))
                        year, month = int(parts[0]), int(parts[1])
                        day = int(d_dir.name)
                        
                        # Create aware datetime (assuming local system time for file names)
                        # We use 'now.tzinfo' to match the system's current timezone assumption
                        dt = datetime.datetime(year, month, day, hh, mm, 0, tzinfo=now.tzinfo)
                        
                        if best_dt is None or dt > best_dt:
                            best_dt = dt
                            best_path = f
                    except ValueError:
                        continue

# 2. Determine "Last Session" timestamp
if best_dt:
    new_last = best_dt.isoformat(timespec="seconds")
else:
    # Fallback if no retrospectives exist yet
    new_last = now.replace(second=0, microsecond=0).isoformat(timespec="seconds")

original_last = heart.get("lastSession")

# 3. Update Heartbeat
heart["lastSession"] = new_last
heart.setdefault("active", True)
heart.setdefault("weekChange", 0)
heart.setdefault("today", {"messages": 0})

# Fix streak format if broken
st = heart.get("streak")
if isinstance(st, int):
    st = {"days": st}
elif st is None:
    st = {"days": 0}
st["days"] = int(st.get("days", 0) or 0)
heart["streak"] = st

# 4. Update Project Stats
proj.setdefault("projectName", "Knowledge_System")
proj["updatedAt"] = new_last # Always update 'updatedAt' to now/latest

# Get current total safely
current_total = proj.get("totalSessions", proj.get("sessions", 0))
try:
    current_total = int(current_total or 0)
except Exception:
    current_total = 0

# KEY FIX: Only increment totalSessions if the timestamp effectively changed
if original_last != new_last:
    current_total += 1

proj["totalSessions"] = current_total

# 5. Save
with open(p_project, "w", encoding="utf-8") as f:
    json.dump(proj, f, indent=2)

with open(p_heart, "w", encoding="utf-8") as f:
    json.dump(heart, f, indent=2)

print(f"Pulse updated. Session: {new_last} (Total: {current_total})")
PY