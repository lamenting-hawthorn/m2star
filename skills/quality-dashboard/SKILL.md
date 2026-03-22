---
name: quality-dashboard
version: 1.0.0
description: |
  View quality metrics and trends across sessions. Shows success rates,
  common corrections, skill usage, and improvement trends over time.
  Use when asked to "show quality", "how am I doing", "dashboard",
  "show metrics", or "quality report".
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - AskUserQuestion
---

# /quality-dashboard — Quality Metrics & Trends

You are the evaluation infrastructure of the M2* system. Aggregate quality
signals and present actionable insights.

## Protocol

### Step 1: Gather Data

Locate and read all `sessions.tsv` files across projects:

```bash
# Find all structured session logs
find ~/.claude/projects -name "sessions.tsv" 2>/dev/null

# Read the current project's TSV (derive from cwd)
_CWD=$(pwd)
_MEM_KEY=$(echo "$_CWD" | sed 's|/Users/||; s|/|-|g')
_TSV="$HOME/.claude/projects/-Users-${_MEM_KEY}/memory/sessions.tsv"
cat "$_TSV" 2>/dev/null

# Feedback memories (corrections = things to improve)
ls ~/.claude/projects/*/memory/feedback_*.md 2>/dev/null

# Skill usage analytics
cat ~/.gstack/analytics/skill-usage.jsonl 2>/dev/null | tail -50
```

### Step 2: Compute Metrics from TSV

Parse `sessions.tsv` with awk for real numbers (columns: date, task, outcome, corrections, tests, skills, key_learning):

```bash
# Total sessions
awk 'NR>1' "$_TSV" | wc -l

# Success rate: rows where outcome == "completed"
awk -F'\t' 'NR>1 && $3=="completed"' "$_TSV" | wc -l

# Test pass rate: rows where tests == "passed"
awk -F'\t' 'NR>1 && $5=="passed"' "$_TSV" | wc -l

# Total corrections across all sessions
awk -F'\t' 'NR>1 {sum+=$4} END {print sum}' "$_TSV"

# Sessions with corrections > 0
awk -F'\t' 'NR>1 && $4>0' "$_TSV" | wc -l

# Most used skills (flatten comma-separated skill column)
awk -F'\t' 'NR>1 {print $6}' "$_TSV" | tr ',' '\n' | sort | uniq -c | sort -rn | head -5

# Trend: compare last 5 vs previous 5 sessions (correction count delta)
awk -F'\t' 'NR>1 {print $4}' "$_TSV" | tail -5   # recent
awk -F'\t' 'NR>1 {print $4}' "$_TSV" | head -5   # older
```

### Step 3: Trend Analysis

Using the computed numbers above:
- Compare recent 5 sessions vs older 5: is correction count going down?
- Are the same corrections recurring across feedback memory files? (regression)
- Are new types of mistakes appearing?

### Step 4: Dashboard Output

```
╔══════════════════════════════════════════════╗
║         M2* Quality Dashboard               ║
╠══════════════════════════════════════════════╣
║                                              ║
║  Sessions Tracked:  XX                       ║
║  Success Rate:      XX%  [▓▓▓▓▓▓▓▓░░]       ║
║  Test Pass Rate:    XX%  [▓▓▓▓▓▓▓░░░]       ║
║  Correction Rate:   XX%  [▓▓░░░░░░░░]       ║
║                                              ║
║  Top Corrections (things to improve):        ║
║  1. <category> — <count> times               ║
║  2. <category> — <count> times               ║
║  3. <category> — <count> times               ║
║                                              ║
║  Top Skills Used:                            ║
║  1. <skill> — <count> invocations            ║
║  2. <skill> — <count> invocations            ║
║                                              ║
║  Trend: <improving/stable/declining>         ║
║  Since: <first tracked session date>         ║
║                                              ║
╚══════════════════════════════════════════════╝
```

### Step 5: Recommendations

Based on the data, suggest:
1. **Skills to adopt**: "You've been debugging manually — try /investigate"
2. **Patterns to watch**: "Same correction appeared 3 times — consider a hook"
3. **Memory gaps**: "No conventions saved for project X — run /discover-conventions"

## Rules

- If no quality data exists yet, explain how to start tracking
  (run /self-learn after sessions)
- Don't fabricate metrics — if data is sparse, say so
- Focus on actionable insights, not vanity metrics
