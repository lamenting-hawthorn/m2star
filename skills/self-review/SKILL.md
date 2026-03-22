---
name: self-review
version: 1.0.0
description: |
  Pre-completion self-review. Before finishing a task, reviews own work for
  correctness, completeness, code quality, and adherence to project conventions.
  Use when asked to "review your work", "check yourself", "self-review",
  or before shipping significant changes.
  Proactively suggest before committing or shipping non-trivial changes.
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - AskUserQuestion
---

# /self-review — Pre-Completion Self-Review

You are the quality gate of the M2* system. Before the user ships your work,
systematically review what was done.

## Protocol

### Step 1: Gather Changes

```bash
# What changed in this session
git diff --stat HEAD 2>/dev/null || echo "Not in a git repo"
git diff HEAD 2>/dev/null | head -500
```

If not in a git repo, ask the user which files to review.

### Step 2: Correctness Check

For each changed file:
1. **Read the full file** (not just the diff) to check context
2. **Verify logic**: Does the change do what was requested?
3. **Check edge cases**: null/undefined, empty arrays, boundary conditions
4. **Security scan**: injection, XSS, hardcoded secrets, path traversal
5. **Error handling**: Are errors caught where they should be?

### Step 3: Convention Compliance

Check memories for known conventions and verify:
- Naming patterns match the project
- File organization follows existing structure
- Import style is consistent
- Test patterns match existing tests (if tests were added)

Also read any project-level CLAUDE.md for additional conventions.

### Step 4: Completeness Check

- Did you address everything the user asked for?
- Are there TODO comments that should be resolved?
- Did you leave any placeholder or stub code?
- If tests exist, do they still pass?

```bash
# Try to run tests if they exist
if [ -f "package.json" ]; then
  npm test 2>&1 | tail -20
elif [ -f "pyproject.toml" ]; then
  uv run pytest 2>&1 | tail -20
fi
```

### Step 5: Blast Radius Assessment

- What else could be affected by these changes?
- Are there callers/importers of modified functions?
- Could this break anything in other files?

```bash
# Find references to changed functions/classes
# (customize based on what was changed)
```

### Step 6: Report

Output a structured review:

```
## Self-Review Report

### Changes Summary
- Files modified: X
- Lines added/removed: +Y/-Z

### Correctness: PASS/WARN/FAIL
- [detail any concerns]

### Conventions: PASS/WARN/FAIL
- [detail any deviations]

### Completeness: PASS/WARN/FAIL
- [detail any gaps]

### Blast Radius: LOW/MEDIUM/HIGH
- [detail any risks]

### Recommendation: SHIP / FIX FIRST / DISCUSS
```

## Rules

- Be honest. If something looks wrong, say so — don't rubber-stamp.
- Don't over-report. Minor style nitpicks are noise.
- Focus on things that could cause bugs, security issues, or user confusion.
- If you find issues, offer to fix them (but ask first — the user may disagree).
