---
name: chain
version: 1.0.0
description: |
  Skill chaining engine. Runs a sequence of skills with auto-continue
  between autonomous steps and human checkpoints at defined gates.
  Use when asked to "run the chain", "chain skills", "full workflow",
  or when a multi-step workflow is needed.
  Example: /chain debug-fix-ship
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - AskUserQuestion
---

# /chain — Skill Chaining Engine

You are the orchestration engine of the M2* system. You execute multi-skill
workflows with automatic transitions and human gates.

## Usage

```
/chain <chain-name> [options]
/chain list
/chain create <name>
```

## Built-in Chains

### `debug-fix-ship`
The standard bug-fix workflow:
1. `/investigate` — Find root cause (autonomous)
2. **FIX** — Implement the fix (autonomous)
3. `/self-review` — Quality gate (autonomous)
4. **GATE: human-review** — User reviews the changes
5. `/commit` — Commit and ship (human + AI)

### `build-test-ship`
The standard feature workflow:
1. **PLAN** — Discuss approach with user (human + AI)
2. **BUILD** — Implement the feature (autonomous)
3. `/self-review` — Quality gate (autonomous)
4. **GATE: human-review** — User reviews
5. `/commit` — Commit (human + AI)
6. `/self-learn` — Extract learnings (autonomous)

### `explore-learn`
Onboard to a new codebase:
1. `/discover-conventions` — Scan codebase patterns (autonomous)
2. `/self-learn` — Save findings to memory (autonomous)
3. **GATE: human-confirm** — User validates findings

### `qa-fix-verify`
End-to-end QA loop:
1. `/qa-only` — Find bugs (autonomous)
2. **GATE: human-triage** — User selects which bugs to fix
3. **FIX** — Fix selected bugs (autonomous)
4. `/self-review` — Verify fixes (autonomous)
5. `/qa-only` — Re-verify (autonomous)
6. **GATE: human-approve** — User approves

### `experiment`
Autoresearch-style hill-climbing loop. Git HEAD = best-so-far. Each iteration
is committed, measured, and either kept or reverted. Runs autonomously between
iterations; only gates when asking to continue.

**Setup (step 1 — human + AI):**
Ask the user for:
- `hypothesis`: What change are we testing? (becomes git commit message)
- `metric`: What are we measuring? (e.g. "test pass rate", "lint errors", "response time ms")
- `direction`: Should metric go UP or DOWN to count as improvement?
- `run_command`: Shell command that produces the metric (e.g. `npm test | tail -1`)
- `metric_extract`: How to extract the scalar from output (e.g. `grep -oP '\d+ passing'`)
- `branch`: Optional experiment branch name (default: `experiment/<date>`)

Create the branch:
```bash
git checkout -b "experiment/$(date +%Y%m%d)" 2>/dev/null || git checkout -b experiment
```

Initialize `results.tsv` (untracked — add to .gitignore):
```bash
printf "commit\tmetric\tstatus\tdescription\n" > results.tsv
echo "results.tsv" >> .gitignore
```

**Each iteration (steps 2–5 — autonomous):**

**Step 2 — IMPLEMENT:** Make the change described in the hypothesis. `git add -A && git commit -m "<hypothesis>"`

**Step 3 — RUN+MEASURE:**
```bash
_OUTPUT=$(<run_command> 2>&1)
_METRIC=$(<metric_extract from _OUTPUT>)
_COMMIT=$(git rev-parse --short HEAD)
echo "Metric: $_METRIC"
```
If command fails or metric is empty → status = `crash`, revert, log, continue to gate.

**Step 4 — KEEP/REVERT:**
```bash
# Compare _METRIC to _PREV_METRIC (stored from last iteration)
# If improved (per direction): KEEP — log "keep"
# If not improved: REVERT — git reset --hard HEAD~1 — log "discard"
```

**Step 5 — LOG:**
```bash
printf "%s\t%s\t%s\t%s\n" "$_COMMIT" "$_METRIC" "<keep|discard|crash>" "<hypothesis>" >> results.tsv
```
Show the current results table:
```
commit   metric   status    description
a1b2c3d  42       keep      add caching layer
b2c3d4e  38       keep      reduce N+1 queries
c3d4e5f  45       discard   add logging (made it worse)
```

**Step 6 — GATE (iterate?):**
```
────────────────────────────────────
GATE: experiment-iterate

Best so far: <metric> = <best_value> @ <commit>
Iterations: <N>

[continue] → New hypothesis, run another iteration
[same]     → Keep same hypothesis, tweak implementation
[stop]     → End experiment, stay on best commit
[abort]    → git checkout main (discard all)
────────────────────────────────────
```

**Loop:** If [continue] or [same], go back to Step 2 with new/same hypothesis.

**End state:** Branch HEAD = best-performing commit found. `results.tsv` = full audit trail.

## Execution Protocol

When running a chain:

### For each step:

1. **Announce the step**: `## Step N: <name> [autonomous/human+AI/GATE]`

2. **If autonomous**: Execute the skill or action without interruption.
   Capture the output/result.

3. **If human + AI**: Engage the user in discussion. Wait for their input
   before proceeding.

4. **If GATE**: Stop and present:
   ```
   ────────────────────────────────────
   GATE: <gate-name>

   Summary of work so far:
   - <bullet points>

   Options:
   [continue] → Proceed to next step
   [fix]      → Go back and fix something
   [abort]    → Stop the chain
   [skip]     → Skip next step
   ────────────────────────────────────
   ```
   Wait for user input before proceeding.

5. **On failure**: If a step fails, don't silently continue.
   Present the failure and ask: continue, retry, or abort?

### Auto-continue rules:
- Between two autonomous steps: proceed immediately
- Before a gate: always stop
- After a gate: proceed based on user's choice
- On error: always stop and ask

## Custom Chains

Users can define chains in `~/.claude/projects/<project>/memory/chains/`:

```markdown
---
name: my-chain
description: My custom workflow
---

## Steps

1. [autonomous] /investigate
2. [autonomous] Fix the issue
3. [gate: review] Review changes
4. [human+ai] Discuss next steps
5. [autonomous] /self-learn
```

To create a custom chain:
```
/chain create <name>
```
This opens an interactive builder to define the steps.

## Rules

- Never skip gates unless the user explicitly says to
- Always show progress: "Step 2/5: Building feature..."
- If a skill invoked by the chain isn't available, substitute with
  the equivalent manual steps
- Track time per step and total chain duration
- At the end, offer to run `/self-learn` if it wasn't in the chain
