---
name: build-loop
description: "Execute GSD project phases sequentially using claude -p headless sessions. Use this skill whenever the user wants to run all phases, execute a build loop, automate GSD phase execution, or says things like \"run build loop\", \"execute all phases\", \"start the loop\", \"continue from where we left off\", or mentions overnight/autonomous execution. Also use when the user has a .planning/phases/ directory and wants to execute phases without manual intervention."
metadata:
  author: pallidev
  version: "1.0.0"
---

# Build Loop

Execute GSD phases one by one in headless Claude sessions. Each phase runs in a fresh context window, so the orchestrator session stays lean (~10% context usage) while all the heavy lifting happens in the background.

The reason this matters: when you feed an entire project spec into a single Claude session, accuracy degrades past ~50% context window usage ("context rot"). Build Loop avoids this by running each phase as an independent session, reading only its own plan file. State persists on disk, so if the session dies, you can pick up where you left off.

## Prerequisites

This skill expects a `.planning/phases/` directory created by GSD (Get Shit Done). Each phase folder contains a plan file that tells the headless session what to do:

```
.planning/
├── PROJECT.md
├── phases/
│   ├── 01-project-setup/
│   │   ├── 01-CONTEXT.md
│   │   └── 01-01-PLAN.md
│   ├── 02-crud-api/
│   │   └── 02-01-PLAN.md
│   └── ...
└── build-loop-state.json   ← created by this skill
```

If there's no `.planning/phases/` directory, tell the user to set up GSD first: `npx get-shit-done-cc@latest`

## How It Works

The orchestrator (this session) never writes code itself. It only:
1. Reads the plan file for the next incomplete phase
2. Spawns a headless Claude session via `claude -p`
3. Records the result in a state file
4. Moves to the next phase

Each headless session is completely independent — fresh context, no carryover. That's why context rot doesn't accumulate.

## Step 1: Initialize or Resume State

Check for `.planning/build-loop-state.json`.

**If it exists:** read it and resume from the first incomplete phase. This handles the case where a previous run was interrupted — you don't start over.

**If it doesn't exist:** scan `.planning/phases/` and create the initial state file:

```json
{
  "project": "<from PROJECT.md>",
  "startedAt": "<ISO 8601>",
  "updatedAt": "<ISO 8601>",
  "phases": [
    {
      "id": "01-project-setup",
      "name": "<human-readable name>",
      "status": "pending",
      "startedAt": null,
      "completedAt": null
    }
  ]
}
```

Phase statuses cycle through: `pending` → `in_progress` → `complete`.

## Step 2: Execute the Next Phase

Find the phase with the lowest number where status is `pending` or `in_progress`.

Read its plan file (the `*PLAN.md` in that phase's directory). Then tell the user which phase is about to run, and execute it:

```bash
claude -p "$(cat .planning/phases/01-project-setup/01-01-PLAN.md)"
```

The headless session will read the plan, execute it (code, tests, commits), and return a summary. The orchestrator context stays small because all the work happened in a separate process.

## Step 3: Update State

After the phase completes:

1. Set the phase's `status` to `"complete"`
2. Record `completedAt` with the current timestamp
3. Set the next phase's `status` to `"in_progress"` (if there is one)
4. Update `updatedAt`

Write the updated state file immediately — don't batch. This way, if the orchestrator session crashes mid-loop, you can resume cleanly.

## Step 4: Loop or Finish

- If incomplete phases remain, go back to Step 2
- If all phases are complete, print a summary:
  - Total phases completed
  - Total elapsed time (from `startedAt` to now)
  - List of completed phase names

## Handling Failures

When a phase fails (non-zero exit, error output, or timeout):

1. Tell the user what went wrong — include the error output
2. Ask: retry this phase, skip to the next, or stop entirely?
3. If retrying, run the same `claude -p` command again
4. If skipping, mark the phase as `"skipped"` in the state file and move on

## Key Constraints

- **Always tell the user before executing a phase** — no silent execution
- **Update the state file after every phase** — don't wait until the end
- **Keep the orchestrator context small** — only store phase summaries, not full outputs
- **State file is the source of truth** — if the session restarts, read the state file, not conversation history
