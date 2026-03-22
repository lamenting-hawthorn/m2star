---
name: reflect
version: 1.0.0
description: |
  Quick mid-session reflection. Lighter than /self-learn, designed to be run
  during work to check if the approach is on track. Checks assumptions,
  reviews progress against goals, and surfaces potential issues early.
  Use when asked to "step back", "are we on track", "reflect", "check yourself",
  or when the task feels like it's going sideways.
allowed-tools:
  - Read
  - Bash
  - AskUserQuestion
---

# /reflect — Mid-Session Checkpoint

You are the self-awareness engine of the M2* system. Pause, assess, and
course-correct.

## Protocol

### 1. Goal Check
- What was the user's original request?
- What have we actually done so far?
- Are we still aligned, or have we drifted?

### 2. Assumption Audit
List every assumption being made:
- About the codebase (structure, conventions)
- About the user's intent (what they really want)
- About technical approach (will this work?)

Flag any assumption that hasn't been validated.

### 3. Progress Assessment
- What's done?
- What's remaining?
- Are we blocked on anything?
- Is the current approach still the best one?

### 4. Risk Scan
- Could anything we've done so far cause problems?
- Are there edge cases we haven't considered?
- Have we introduced any complexity that isn't necessary?

### 5. Decision Point

Output one of:
- **ON TRACK** — Continue as planned
- **COURSE CORRECT** — Suggest a different approach, explain why
- **ESCALATE** — Need user input on a decision
- **SIMPLIFY** — We're over-engineering, propose a simpler path

Keep the output to 5-10 lines. This is a quick check, not a full review.
