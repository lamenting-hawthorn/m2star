---
name: self-learn
version: 1.0.0
description: |
  Post-session reflection skill. Reviews the conversation for feedback,
  corrections, discovered conventions, and quality signals. Extracts
  learnings and persists them to memory for future sessions.
  Use when asked to "reflect", "what did you learn", "save learnings",
  "self-learn", or at the end of a productive session.
  Proactively suggest at the end of sessions where significant work was done.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - AskUserQuestion
---

# /self-learn — Post-Session Reflection

You are the self-learning engine of the M2* system. Your job is to extract durable
learnings from this session and persist them for future sessions.

## Protocol

Run these 5 phases in order. Be ruthless about what's worth saving — only save
things that will genuinely help future sessions. Skip phases that yield nothing.

### Phase 1: Feedback Extraction

Scan the conversation for:
- **Corrections**: "no", "don't do that", "wrong approach", "stop", rejections of tool calls
- **Confirmations**: "yes exactly", "perfect", "that's right", accepted unusual approaches
- **Preferences**: formatting, verbosity, tool usage, communication style

For each finding, save a `feedback` type memory:
```markdown
---
name: feedback_<topic>
description: <one-line description>
type: feedback
---

<The rule itself>

**Why:** <reason the user gave or context>
**How to apply:** <when/where this guidance applies>
```

### Phase 2: Convention Discovery

Review the code touched in this session:
1. Read the files that were edited or created
2. Look for patterns: naming conventions, file organization, import style,
   error handling patterns, test structure, component patterns
3. Compare against existing memory — only save if new or contradicts existing

For genuinely new conventions, save as `project` type memory.

**Do NOT save:**
- Obvious language conventions (e.g., "Python uses snake_case")
- Patterns already in CLAUDE.md
- One-off decisions that won't recur

### Phase 3: Project Context

Capture non-obvious project context learned during the session:
- Architecture decisions and their rationale
- Ongoing initiatives or migrations
- Team dynamics or ownership boundaries
- Deadlines or constraints mentioned

Save as `project` type memories. Convert relative dates to absolute.

### Phase 4: User Profile Update

If you learned something new about the user:
- Technical expertise (languages, frameworks, experience level)
- Role or responsibilities
- Working style preferences
- Domain knowledge

Check existing `user` type memories first — update rather than duplicate.

### Phase 5: Quality Signal Log

First, determine the correct memory directory for this session:

```bash
# Derive memory path from current working directory
_CWD=$(pwd)
_MEM_KEY=$(echo "$_CWD" | sed 's|/Users/||; s|/|-|g')
_MEM_DIR="$HOME/.claude/projects/-Users-${_MEM_KEY}/memory"
# Fallback to global if something goes wrong
[ -d "$HOME/.claude/projects" ] || _MEM_DIR="$HOME/.claude/projects/-Users-raghav/memory"
mkdir -p "$_MEM_DIR"
echo "Memory directory: $_MEM_DIR"
```

Use `$_MEM_DIR` as the base for ALL memory files in this session (phases 1–4 too).
This ensures conventions for `Web4/` don't bleed into `x-cli/` and vice versa.

**What goes where:**
- `feedback_*` memories → `$_MEM_DIR` (project-specific — user preferences may differ by project)
- `user_*` memories → `~/.claude/projects/-Users-raghav/memory/` (always global — user profile doesn't change per project)
- `project_*` memories → `$_MEM_DIR` (always project-specific)
- `reference_*` memories → `$_MEM_DIR` (project-specific)
- `quality-log.md` → `$_MEM_DIR`

**Write a structured TSV row** to `$_MEM_DIR/sessions.tsv` (machine-readable, used by `/quality-dashboard`):

```bash
# Create header if file doesn't exist
_TSV="$_MEM_DIR/sessions.tsv"
if [ ! -f "$_TSV" ]; then
  printf "date\ttask\toutcome\tcorrections\ttests\tskills\tkey_learning\n" > "$_TSV"
fi
# Append one row — fill in values from the session
printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
  "$(date +%Y-%m-%d)" \
  "<brief task description>" \
  "<completed|partial|blocked>" \
  "<number of corrections made>" \
  "<passed|failed|none>" \
  "<comma-separated skills used>" \
  "<one sentence key learning>" >> "$_TSV"
```

Also append human-readable prose to `$_MEM_DIR/quality-log.md`:
```markdown
## Session: <date>
- **Task**: <brief description>
- **Outcome**: <completed/partial/blocked>
- **Tests**: <passed/failed/none>
- **User satisfaction**: <accepted/corrected/rejected>
- **Skills used**: <list>
- **Key learning**: <one sentence>
```

Create both files if they don't exist.

### Phase 6: Memory Index Update

After saving any new memory files, update MEMORY.md to include pointers to them.

## Output

After completing all phases, summarize:
1. Number of new memories saved
2. Number of existing memories updated
3. Key learnings from this session
4. Suggestions for skills or automations that would help in future sessions

## Rules

- Never save ephemeral task details (which files were open, current bugs being debugged)
- Never save things derivable from `git log` or reading current code
- Never duplicate information already in CLAUDE.md files
- Always check existing memories before creating new ones
- Keep memory files focused — one concept per file
- Use descriptive filenames: `feedback_testing_style.md`, `project_auth_migration.md`
