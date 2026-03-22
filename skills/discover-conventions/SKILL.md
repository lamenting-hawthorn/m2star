---
name: discover-conventions
version: 1.0.0
description: |
  Proactively discover and learn codebase conventions, patterns, and architecture.
  Scans the project for naming, structure, testing, error handling, and component
  patterns, then saves them to memory and CLAUDE.md.
  Use when asked to "learn this codebase", "discover conventions", "analyze patterns",
  or when starting work in an unfamiliar project.
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - Write
  - Edit
  - AskUserQuestion
---

# /discover-conventions — Codebase Pattern Discovery

You are the convention-learning engine of the M2* system. Your job is to deeply
read a codebase and extract patterns that will help future sessions write
consistent, idiomatic code.

## Protocol

### Step 1: Identify the Project

```bash
pwd
ls -la
cat package.json 2>/dev/null || cat pyproject.toml 2>/dev/null || cat Cargo.toml 2>/dev/null
```

Determine: language, framework, package manager, project type.

### Step 2: Structural Patterns

Discover how the project is organized:

```bash
# Directory structure (top 3 levels, excluding noise)
find . -type d -maxdepth 3 \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' \
  -not -path '*/dist/*' \
  -not -path '*/__pycache__/*' \
  -not -path '*/.next/*' \
  | head -50
```

Look for:
- **File naming**: kebab-case vs camelCase vs PascalCase
- **Directory purpose**: Is there a `lib/` vs `src/` vs `app/` convention?
- **Co-location**: Are tests next to source or in a separate tree?
- **Index files**: barrel exports or direct imports?

### Step 3: Code Patterns

Sample 5-10 representative files and look for:

**Naming:**
- Variable/function naming convention
- Component naming (if React/Vue)
- Constants: SCREAMING_SNAKE vs PascalCase

**Imports:**
- Absolute vs relative imports
- Import ordering (stdlib → third-party → local)
- Aliased imports (@/ paths)

**Error Handling:**
- try/catch vs Result types vs error returns
- Custom error classes
- Error logging patterns

**State Management (if frontend):**
- State library (Redux, Zustand, Jotai, etc.)
- Data fetching pattern (React Query, SWR, fetch)
- Form handling approach

**API Patterns (if backend):**
- Route organization
- Middleware usage
- Request/response patterns
- Validation approach

### Step 4: Testing Patterns

```bash
# Find test files
find . -name "*.test.*" -o -name "*.spec.*" -o -name "test_*.py" | head -20
```

Read 2-3 test files and extract:
- Test framework and assertion style
- Mocking approach (real DB vs mocks)
- Test file naming and organization
- Setup/teardown patterns
- Common test utilities

### Step 5: Configuration & Tooling

Read config files for enforced standards:
- ESLint/Prettier rules (what's strict?)
- TypeScript strictness level
- CI pipeline requirements
- Pre-commit hooks

### Step 6: Save Findings

For each significant pattern discovered:

1. Check if a memory already exists for this pattern
2. If new, create a `project` type memory file
3. If the project has a CLAUDE.md, suggest additions (don't auto-modify without asking)

**Memory format:**
```markdown
---
name: conventions_<project>_<aspect>
description: <project> uses <pattern> for <aspect>
type: project
---

<Pattern description>

**Why:** <inferred or discovered rationale>
**How to apply:** <specific guidance for writing consistent code>
```

### Step 7: Summary Report

Output:
1. **Project profile**: language, framework, maturity level
2. **Key conventions**: the 5-10 most important patterns
3. **Anti-patterns**: things this project specifically avoids
4. **Memories saved**: list of new memory files created
5. **CLAUDE.md suggestions**: proposed additions (if applicable)

## Rules

- Read actual code, don't guess from file names
- Only save patterns that appear consistently (3+ occurrences)
- Don't save language-default conventions
- Focus on what's unique or non-obvious about THIS project
- If you can't determine a pattern confidently, note it as uncertain
