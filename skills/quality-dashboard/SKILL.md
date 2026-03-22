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

Read quality signals from:
```bash
# Quality log
cat ~/.claude/projects/-Users-raghav/memory/quality-log.md 2>/dev/null

# Feedback memories (corrections = things to improve)
ls ~/.claude/projects/*/memory/feedback_*.md 2>/dev/null

# Skill usage analytics
cat ~/.gstack/analytics/skill-usage.jsonl 2>/dev/null | tail -50
```

### Step 2: Compute Metrics

From the quality log, calculate:
- **Success rate**: completed / total sessions
- **Test pass rate**: passed / (passed + failed)
- **Correction rate**: sessions with corrections / total
- **Most common corrections**: group feedback memories by theme

From skill usage:
- **Most used skills**: frequency count
- **Skill chains**: common sequences

### Step 3: Trend Analysis

Compare recent sessions (last 5) vs. older sessions:
- Is success rate improving?
- Are the same corrections recurring? (regression)
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
