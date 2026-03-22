# M2* — Self-Learning Agent System for Claude Code

> **Humans steer at every layer. The agent learns at every layer.**

M2* is a skill pack for [Claude Code](https://claude.ai/code) that implements a self-improving agent loop. Instead of starting from scratch every session, Claude learns your conventions, remembers your feedback, and gets measurably better at working with your specific codebase over time.

---

## Why M2*?

Every new Claude Code session starts with zero context. You re-explain the same project conventions. You correct the same mistakes. You re-establish the same working style. M2* fixes this.

After a few sessions, Claude knows:
- Your project's naming conventions, import style, test patterns
- What you've corrected before — and won't repeat the mistake
- Your preferences for how code should be written and reviewed
- The non-obvious architectural decisions in your codebase

This is the [M2* Model Iteration System](https://github.com/lamenting-hawthorn/m2star) — adapted and implemented as a Claude Code skill pack.

---

## How It Works

```
Session 1:  You work → /self-learn saves 3 memories
Session 2:  Memories load automatically → Claude avoids past mistakes
Session 5:  Claude knows your conventions without being told
Session 10: /quality-dashboard shows correction rate dropping
Session 20: Claude feels like a teammate who knows the codebase
```

The memory system is **project-scoped** — conventions for `web-app/` don't bleed into `cli-tool/`. User preferences (your profile) are global.

---

## Skills Included

| Skill | Command | When to use |
|-------|---------|-------------|
| **Self-Learn** | `/self-learn` | End of any productive session — extracts feedback, conventions, project context |
| **Self-Review** | `/self-review` | Before shipping — checks correctness, conventions, completeness, blast radius |
| **Discover Conventions** | `/discover-conventions` | First time in a new codebase — scans patterns and saves to memory |
| **Chain** | `/chain <name>` | Multi-step workflows with auto-continue and human gates |
| **Reflect** | `/reflect` | Mid-session course check — "are we on track or drifting?" |
| **Escalate** | `/escalate` | Configure how autonomous Claude should be |
| **Quality Dashboard** | `/quality-dashboard` | View quality trends and improvement metrics over sessions |

### Built-in Chains

```bash
/chain debug-fix-ship     # Investigate → Fix → Review → Gate → Commit
/chain build-test-ship    # Plan → Build → Review → Gate → Commit → Learn
/chain explore-learn      # Discover conventions → Save to memory → Confirm
/chain qa-fix-verify      # QA → Triage gate → Fix → Review → Re-verify
/chain experiment         # Plan → Dev/Run → Analyze → Review gate → Iterate
```

---

## Installation

### Requirements
- [Claude Code](https://claude.ai/code) installed
- `jq` installed (`brew install jq` on macOS)

### One-line install

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

Add this to `~/.claude/settings.json` to get reminded to run `/self-learn` at session end:

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

### Initialize memory structure

```bash
mkdir -p ~/.claude/projects/-Users-$(whoami)/memory
```

---

## Daily Workflow

### First time in a project
```bash
cd ~/your-project
# In Claude Code:
/discover-conventions
```

### Every session
```
1. Open Claude Code in your project   # memories auto-load
2. Work normally
3. (Optional) /reflect                # if task feels off-track
4. (Optional) /self-review            # before committing
5. /self-learn                        # when done — the one habit that matters
```

### For complex tasks
```
/chain build-test-ship    # handles the whole feature workflow
/chain debug-fix-ship     # handles the whole bug-fix workflow
```

---

## Memory Architecture

```
~/.claude/projects/<project>/memory/
├── MEMORY.md                  # Index (auto-loaded each session)
├── quality-log.md             # Session outcomes and quality signals
├── feedback_*.md              # Your corrections & confirmed approaches
├── project_*.md               # Non-obvious project context
├── user_*.md                  # Your profile & preferences (global)
└── chains/                    # Custom workflow definitions
    └── my-workflow.md
```

**Scope rules:**
- `feedback_*`, `project_*`, `reference_*` → project-specific (per working directory)
- `user_*` → global (same person across all projects)

---

## The Learning Loop

```
┌─────────────────────────────────────────────────────────┐
│                    Agent Harness                         │
│                                                          │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────────┐ │
│  │ Skills   │ │ Memory   │ │Guardrails│ │ Evaluation │ │
│  │ /chain   │ │ feedback │ │/escalate │ │ /quality-  │ │
│  │ /reflect │ │ project  │ │ tiers    │ │  dashboard │ │
│  │ /self-   │ │ user     │ │ hooks    │ │ /self-     │ │
│  │  review  │ │ reference│ │          │ │  review    │ │
│  └──────────┘ └──────────┘ └──────────┘ └────────────┘ │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │              Agent (Claude Code)                  │   │
│  │  Read docs · Learn conventions · Self-review      │   │
│  │  Chain skills · Build memory · Cowork             │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

Inspired by the [M2* Model Iteration System](https://x.com) architecture — where humans steer at every layer and models build at every layer.

---

## Updating

```bash
cd ~/.claude/skills/m2star
git pull
```

---

## License

MIT — use freely, modify, share.
