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
import json, datetime, pathlib, re, os, subprocess

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

# 1. Find retrospectives by FILENAME timestamp (YYYY-MM/DD/HH.MM_title.md)
# This avoids OS modification time issues.
best_dt = None
best_path = None
min_dt = None
retro_count = 0
retro_days = set()  # distinct YYYY-MM-DD values that contain >=1 retrospective
now = datetime.datetime.now().astimezone()


def current_branch() -> str:
    """Best-effort detection of the current git branch.

    This is used to populate the `branches` stats in project.json so that
    /rrr can surface per-branch activity as described in its SKILL.MD.
    Fails closed to "unknown" if git is unavailable.
    """

    try:
        out = subprocess.check_output(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            stderr=subprocess.DEVNULL,
            text=True,
        ).strip()
        return out or "unknown"
    except Exception:
        return "unknown"

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

                        # Track day-level existence (for streak computation)
                        retro_days.add(datetime.date(year, month, day))

                        # Count sessions by counting retrospective files that match the naming convention
                        retro_count += 1
                        
                        # Create aware datetime (assuming local system time for file names)
                        # We use 'now.tzinfo' to match the system's current timezone assumption
                        dt = datetime.datetime(year, month, day, hh, mm, 0, tzinfo=now.tzinfo)

                        if best_dt is None or dt > best_dt:
                            best_dt = dt
                            best_path = f

                        if min_dt is None or dt < min_dt:
                            min_dt = dt
                    except ValueError:
                        continue

# 2. Determine "Last Session" timestamp
if best_dt:
    new_last = best_dt.isoformat(timespec="seconds")
else:
    # Fallback if no retrospectives exist yet
    new_last = now.replace(second=0, microsecond=0).isoformat(timespec="seconds")

original_last = heart.get("lastSession")

# 2.5. Compute streak (consecutive days with >=1 retrospective, ending on the latest retro day)
computed_streak_days = 0
if best_dt and retro_days:
    d = best_dt.date()
    while d in retro_days:
        computed_streak_days += 1
        d = d - datetime.timedelta(days=1)

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

# Overwrite streak.days with computed value (if any retrospectives exist)
if best_dt and retro_days:
    heart["streak"]["days"] = int(computed_streak_days)

# 4. Update Project Stats
proj.setdefault("projectName", "Knowledge_System")

# Initialize schema fields expected by /rrr skill if missing
proj.setdefault("createdAt", None)
proj.setdefault("avgMessagesPerSession", 0)
proj.setdefault("sizes", {})
proj.setdefault("branches", {})

# Set createdAt on first run, keep updatedAt in sync with latest session
if proj.get("createdAt") in (None, ""):
    proj["createdAt"] = new_last

proj["updatedAt"] = new_last  # Always update 'updatedAt' to latest session

# Set totalSessions based on counted retrospectives (deterministic; no dependence on running pulse every session)
proj["totalSessions"] = int(retro_count or 0)

# createdAt should reflect earliest known retrospective when available
if min_dt:
    try:
        existing_created = proj.get("createdAt")
        # If missing OR later than earliest retro, correct it.
        if not existing_created:
            proj["createdAt"] = min_dt.isoformat(timespec="seconds")
        else:
            try:
                existing_dt = datetime.datetime.fromisoformat(str(existing_created))
                if existing_dt.tzinfo is None:
                    existing_dt = existing_dt.replace(tzinfo=now.tzinfo)
                if existing_dt > min_dt:
                    proj["createdAt"] = min_dt.isoformat(timespec="seconds")
            except Exception:
                proj["createdAt"] = min_dt.isoformat(timespec="seconds")
    except Exception:
        pass

# Branch stats: we cannot reconstruct historical branch attribution from retrospectives.
# Provide a pragmatic value so /recap and /rrr can still surface activity on the *current* branch.
branch_name = current_branch()
proj["branches"] = {branch_name: int(retro_count or 0)}

# 5. Save
with open(p_project, "w", encoding="utf-8") as f:
    json.dump(proj, f, indent=2)

with open(p_heart, "w", encoding="utf-8") as f:
    json.dump(heart, f, indent=2)

print(f"Pulse updated. Session: {new_last} (Total retros: {retro_count})")
PY
