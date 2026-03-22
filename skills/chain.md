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
The M2* experiment loop (from the diagram):
1. **EXP-PLAN** — Design experiment (human + AI)
2. **EXP-DEV-RUN** — Develop and run experiment (autonomous)
3. **ANALYZE-REPORT** — Analyze results, generate report (autonomous)
4. **GATE: human-review** — Review results, decide next steps
5. **ITERATE** — Loop back to step 1 if needed

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
