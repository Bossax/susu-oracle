Below is a ready-to-paste instruction set you can give to a Roo Code agent in VS Code (Git Bash terminal). It implements Option 2 by patching `recap-rich.ts` to support `psi` as a fallback for `ψ`, fixes the “latest retrospective” selection, and avoids UTC month issues. It also defines a stable structure and update rules for `focus-agent-main.md` so `/recap` reads it correctly.

---

## Instructions for AI agent

You are operating in VS Code on Windows. All shell commands must run in the VS Code integrated terminal using Git Bash (not cmd/PowerShell). Work only in the current workspace and `~/.roo/skills` as needed. Do not delete or modify the `psi/` memory content except for adding the focus file and folders if missing. After changes, validate by running `/recap`.

### Objective

1. Patch `recap-rich.ts` so it can read from either `ψ/...` or `psi/...` paths (prefer `ψ` if present, otherwise fall back to `psi`).
2. Make “LAST SESSION” reliably pick the most recent retrospective markdown file by sorting filenames.
3. Use local time for month/day folder selection (avoid UTC `toISOString()` month drift).
4. Define and implement a `focus-agent-main.md` file format and ensure it is created/updated under `psi/inbox/` so recap can show it.

---

## Step A — Locate the recap script and back it up

In Git Bash, locate `recap-rich.ts` used by Roo:

```bash
ls -la ~/.roo/skills/recap/recap-rich.ts
```

Back it up:

```bash
cp ~/.roo/skills/recap/recap-rich.ts ~/.roo/skills/recap/recap-rich.ts.bak_$(date +%Y%m%d_%H%M)
```

Open the file in VS Code editor.

---

## Step B — Implement a root-path resolver (ψ → psi fallback)

In `recap-rich.ts`, implement a helper that resolves any path of the form `ψ/...` to `psi/...` if the ψ path does not exist.

Add near the top (after imports):

```ts
import { existsSync } from "fs";
import { join } from "path";

function resolvePsiPath(ROOT: string, psiStylePath: string) {
  // psiStylePath should start with "ψ/" (or "ψ\")
  const pPsi = join(ROOT, psiStylePath);
  if (existsSync(pPsi)) return pPsi;

  const pAscii = join(ROOT, psiStylePath.replace(/^ψ[\\/]/, "psi/"));
  if (existsSync(pAscii)) return pAscii;

  // Return the ASCII candidate even if it doesn't exist, so caller can handle "missing file"
  return pAscii;
}
```

Then replace every `join(ROOT, "ψ/...")` that references memory/state files with `resolvePsiPath(ROOT, "ψ/...")`.

At minimum, update:

* focus file path: `ψ/inbox/focus-agent-main.md`
* retrospectives root: `ψ/memory/retrospectives/...`
* any tracks/schedule/handoff paths if present

Example replacement:

```ts
const focusFile = resolvePsiPath(ROOT, "ψ/inbox/focus-agent-main.md");
```

Do not change logic elsewhere yet.

---

## Step C — Fix month/day derivation to use local time

Find any code that derives month/day using `toISOString()` such as:

```ts
const month = now.toISOString().slice(0, 7);
const day = now.toISOString().slice(8, 10);
```

Replace with local-time equivalents:

```ts
const month = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}`;
const day = String(now.getDate()).padStart(2, "0");
```

If the script uses a date to find “last session day”, compute that day using local time as well (not UTC).

---

## Step D — Make LAST SESSION choose the latest retrospective deterministically

Where the script loads retrospective files for a given day folder, it currently does something like:

* `readdirSync(...)`
* `filter(...)`
* chooses `files[0]` without sorting

Change this so it sorts by filename and selects the latest. Your retrospective filenames start with `HH.MM_...`, so lexicographic sorting works.

Implement:

```ts
const files = readdirSync(dayDir)
  .filter((f) => f.endsWith(".md") && !f.includes("CLAUDE"))
  .sort(); // ascending

const latest = files.length ? files[files.length - 1] : null;
```

If the script selects among multiple days, also sort the day folder names and take the latest day first:

```ts
const days = readdirSync(retroMonthDir)
  .filter((d) => /^\d{2}$/.test(d))
  .sort();

const latestDay = days.length ? days[days.length - 1] : null;
```

Then inside that day, select the latest file as above.

This ensures Windows directory ordering cannot break “latest session”.

---

## Step E — Define and implement the focus file format

### Required location

Recap reads focus from:

`ψ/inbox/focus-agent-main.md`

After Step B, recap will also accept:

`psi/inbox/focus-agent-main.md` (fallback)

So we will store focus under `psi/inbox/focus-agent-main.md` in your workspace. The helper ensures recap reads it.

### Required structure

The file must contain at least these keys as single-line fields:

* `STATE:` one of `active`, `paused`, `idle`
* `TASK:` a single-line description of what you are working on

Optional but recommended keys:

* `UPDATED:` ISO-8601 local timestamp with `+07:00` offset
* `NEXT:` 1–3 short bullet-like items in one line separated by `;`
* `CONTEXT:` one line, what matters right now
* `BLOCKERS:` one line, `none` if empty

Example file:

```md
STATE: active
TASK: Improve /recap to read retrospectives and align pulse context
UPDATED: 2026-02-12T15:05:00+07:00
NEXT: Validate focus parsing; Validate last-session selection; Push fixes
CONTEXT: Roo Code runs in Git Bash; psi is ASCII; avoid ψ paths
BLOCKERS: none
```

### Update rules

Whenever a new session starts (when you run `/recap` at the start of work), update:

* `UPDATED:` set to current local time
* `STATE:` set appropriately
* `TASK:` set to the single most important target for this session
* Keep `NEXT/CONTEXT/BLOCKERS` aligned, but do not let the file become long

No multi-paragraph text. Keep to short lines so parsing is stable.

---

## Step F — Ensure the focus file exists and recap can read it

In Git Bash, from the workspace root that contains `psi/`, create folder and file:

```bash
mkdir -p psi/inbox
cat > psi/inbox/focus-agent-main.md <<'EOF'
STATE: active
TASK: Establish stable recap reading (focus + last session)
UPDATED: 2026-02-12T00:00:00+07:00
NEXT: Run /recap; Verify focus is shown; Verify last session shows retrospective summary
CONTEXT: Use psi (ASCII) paths; Roo executes Git Bash in VS Code
BLOCKERS: none
EOF
```

Then edit the `UPDATED:` line manually once (or leave it; recap only needs STATE/TASK).

---

## Step G — Validate behavior end-to-end

1. Run `/recap` and confirm:

* FOCUS is no longer “No focus file”
* LAST SESSION shows the retrospective content (or at least references it) based on the latest file in the correct day folder

2. If LAST SESSION is still empty, add temporary debug prints inside `recap-rich.ts` (only while diagnosing) to print the resolved retrospective directory and selected file, then rerun `/recap`.

3. After validation, remove debug prints.

---

## Step H — Make focus updates part of your routine

At the start of each session:

* Update `psi/inbox/focus-agent-main.md` with current `TASK` and `UPDATED`
* Run `/recap`

At the end of each session:

* Run `/rrr`
* Run `bash tools/pulse.sh` (if not already inside `/rrr`)
* Optionally update `NEXT:` for tomorrow

---

If you want, I can also provide a tiny `tools/focus.sh` helper that updates `TASK` and `UPDATED` in place from Git Bash (so you can do `focus "…"`), but the structure above is enough for recap to read reliably.

