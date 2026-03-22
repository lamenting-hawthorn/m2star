# M2* — Self-Learning Agent System for Claude Code

> **Humans steer at every layer. The agent learns at every layer.**

M2* is a skill pack for [Claude Code](https://claude.ai/code) that implements a self-improving agent loop. Instead of starting from scratch every session, Claude learns your conventions, remembers your feedback, and gets measurably better at working with your specific codebase over time.

Inspired by the [M2* Model Iteration System](https://github.com/lamenting-hawthorn/m2star) and [karpathy/autoresearch](https://github.com/karpathy/autoresearch) hill-climbing patterns.

---

## Why M2*?

Every new Claude Code session starts with zero context. You re-explain the same project conventions. You correct the same mistakes. You re-establish the same working style. M2* fixes this.

After a few sessions, Claude knows:
- Your project's naming conventions, import style, and test patterns
- What you've corrected before — and won't repeat it
- Your preferences for communication and code style
- The non-obvious architectural decisions in your codebase

```
Session 1:  Work → /self-learn saves learnings to memory
Session 2:  Memories load automatically → Claude avoids past mistakes
Session 5:  Claude knows your conventions without being told
Session 10: /quality-dashboard shows correction rate dropping
Session 20: Claude feels like a teammate who knows the codebase
```

---

## Skills

| Skill | Command | When to use |
|-------|---------|-------------|
| **Self-Learn** | `/self-learn` | End of session — extracts feedback, conventions, project context, writes to `sessions.tsv` |
| **Self-Review** | `/self-review` | Before shipping — checks correctness, conventions, completeness, blast radius |
| **Discover Conventions** | `/discover-conventions` | First time in a new codebase — scans patterns and saves to memory |
| **Chain** | `/chain <name>` | Multi-step workflows with auto-continue and human gates |
| **Reflect** | `/reflect` | Mid-session course check — "are we on track or drifting?" |
| **Escalate** | `/escalate` | Configure how autonomous Claude should be (conservative / balanced / aggressive) |
| **Quality Dashboard** | `/quality-dashboard` | Compute real metrics from `sessions.tsv` — success rate, correction rate, trends |

---

## Chains

### Standard workflows

```bash
/chain debug-fix-ship     # /investigate → Fix → /self-review → Gate → Commit
/chain build-test-ship    # Plan → Build → /self-review → Gate → Commit → /self-learn
/chain explore-learn      # /discover-conventions → Save to memory → Confirm
/chain qa-fix-verify      # /qa-only → Triage gate → Fix → /self-review → Re-verify
```

### Experiment chain (hill-climbing loop)

Adapted from [karpathy/autoresearch](https://github.com/karpathy/autoresearch). Runs an autonomous hypothesis-test-keep/revert loop where `git HEAD` always points to the best-performing commit found.

```bash
/chain experiment
```

**Flow:**

```
1. [human+ai]   Define hypothesis, metric, run command, direction (↑ or ↓)
2. [autonomous] Implement the change → git commit
3. [autonomous] Run the metric command → extract scalar value
4. [autonomous] Compare to previous best:
                  improved → KEEP commit, log "keep"
                  worse    → git reset --hard HEAD~1, log "discard"
                  crash    → revert, log "crash"
5. [autonomous] Append row to results.tsv
6. [gate]       Show results table → [continue / same / stop / abort]
7. [loop]       → repeat from step 2
```

**results.tsv** (untracked, stays local):
```
commit   metric   status    description
a1b2c3d  42       keep      add caching layer
b2c3d4e  38       keep      reduce N+1 queries
c3d4e5f  45       discard   add logging (made it worse)
d4e5f6a  crash    crash     syntax error in migration
```

The metric is whatever you define — test pass count, lint errors, response latency ms, bundle size bytes. Any scalar that can be extracted from a shell command.

---

## Autonomous Overnight Loop

For fully hands-off experiment iteration, use the included shell script:

```bash
# Run 20 experiment iterations while you sleep
~/.claude/skills/m2star/scripts/m2star-loop.sh 20 experiment ~/Projects/my-app
```

```bash
# Usage
m2star-loop.sh [max-iterations] [chain-name] [working-dir]

# Examples
m2star-loop.sh 20 experiment ~/Projects/my-app   # overnight experiment run
m2star-loop.sh 5  build-test-ship                 # 5 feature iterations
m2star-loop.sh                                    # defaults: 10 iter, experiment chain, cwd
```

The script runs `claude -p "/chain <name>"` in a loop, logs all output to `~/.claude/projects/m2star-loop.log`, and prints `results.tsv` after each iteration and on completion.

**Your role:** define the experiment → start the script → review `results.tsv` in the morning.

---

## Installation

### Requirements
- [Claude Code](https://claude.ai/code) installed and authenticated
- `jq` (`brew install jq` on macOS)

### Install

```bash
git clone https://github.com/lamenting-hawthorn/m2star ~/.claude/skills/m2star

cd ~/.claude/skills && \
  ln -sf m2star/skills/self-learn self-learn && \
  ln -sf m2star/skills/self-review self-review && \
  ln -sf m2star/skills/discover-conventions discover-conventions && \
  ln -sf m2star/skills/chain chain && \
  ln -sf m2star/skills/escalate escalate && \
  ln -sf m2star/skills/reflect reflect && \
  ln -sf m2star/skills/quality-dashboard quality-dashboard
```

### Add the Stop hook (auto-reminder)

Adds a reminder to run `/self-learn` every time Claude finishes responding. Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo '{\"systemMessage\": \"Run /self-learn to save learnings from this session.\"}'"
          }
        ]
      }
    ]
  }
}
```

### Initialize memory

```bash
mkdir -p ~/.claude/projects/-Users-$(whoami)/memory
```

### Make the loop script executable

```bash
chmod +x ~/.claude/skills/m2star/scripts/m2star-loop.sh
```

---

## Daily Workflow

### First time in a project
```
cd ~/your-project
/discover-conventions          # scans codebase, saves patterns to memory
```

### Every session
```
1. Open Claude Code in your project    # memories load automatically
2. Work normally
3. /reflect                            # (optional) if task feels off-track
4. /self-review                        # (optional) before committing
5. /self-learn                         # saves learnings — the one habit that matters
```

### For experiments
```
/chain experiment              # interactive setup, then autonomous iterations
# OR
m2star-loop.sh 20 experiment ~/your-project   # fully autonomous overnight
```

---

## Memory Architecture

`/self-learn` saves structured data to two formats in parallel:

**`sessions.tsv`** — machine-readable, used by `/quality-dashboard`:
```
date        task                    outcome    corrections  tests   skills       key_learning
2026-03-22  Add auth middleware      completed  1            passed  self-learn   Middleware order matters for JWT validation
2026-03-23  Optimize DB queries      completed  0            passed  chain,self-learn  N+1 was in the ORM layer not the controller
```

**`quality-log.md`** — human-readable prose companion.

**Directory layout:**
```
~/.claude/projects/<project>/memory/
├── MEMORY.md              # Index (auto-loaded each session)
├── sessions.tsv           # Structured session log
├── quality-log.md         # Prose session log
├── results.tsv            # Experiment results (per-project, untracked)
├── feedback_*.md          # Corrections & confirmed approaches
├── project_*.md           # Non-obvious project context
├── user_*.md              # Your profile & preferences (global only)
└── chains/                # Custom workflow definitions
```

**Scope rules:**
- `feedback_*`, `project_*`, `reference_*`, `sessions.tsv` → project-scoped (per working directory)
- `user_*` → global (same person, all projects)

---

## Quality Dashboard

After a few sessions of `/self-learn` runs, `/quality-dashboard` computes real metrics from `sessions.tsv`:

```
╔══════════════════════════════════════════════╗
║         M2* Quality Dashboard               ║
╠══════════════════════════════════════════════╣
║  Sessions Tracked:  12                       ║
║  Success Rate:      91%  [▓▓▓▓▓▓▓▓▓░]       ║
║  Test Pass Rate:    83%  [▓▓▓▓▓▓▓▓░░]       ║
║  Correction Rate:   17%  [▓▓░░░░░░░░]       ║
║                                              ║
║  Top Corrections:                            ║
║  1. naming conventions — 3 times            ║
║  2. import style — 2 times                  ║
║                                              ║
║  Trend: improving (corrections ↓ over time) ║
╚══════════════════════════════════════════════╝
```

---

## Repo Structure

```
m2star/
├── skills/
│   ├── self-learn/SKILL.md
│   ├── self-review/SKILL.md
│   ├── discover-conventions/SKILL.md
│   ├── chain/SKILL.md              # includes experiment hill-climbing loop
│   ├── escalate/SKILL.md
│   ├── reflect/SKILL.md
│   └── quality-dashboard/SKILL.md
├── scripts/
│   └── m2star-loop.sh              # external autonomous agent loop
├── README.md
└── LICENSE
```

---

## Updating

```bash
cd ~/.claude/skills/m2star
git pull
```

---

## License

MIT — use freely, modify, share.
