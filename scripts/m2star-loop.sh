#!/bin/bash
# M2* Autonomous Experiment Loop
# Runs claude -p in a loop, enabling overnight autonomous iterations.
#
# Usage:
#   ./m2star-loop.sh [max-iterations] [chain-name] [working-dir]
#
# Examples:
#   ./m2star-loop.sh 20 experiment ~/Projects/my-app
#   ./m2star-loop.sh 5 build-test-ship
#   ./m2star-loop.sh         # defaults: 10 iterations, experiment chain, cwd

set -euo pipefail

MAX_ITER=${1:-10}
CHAIN=${2:-experiment}
WORK_DIR=${3:-$(pwd)}
LOG="$HOME/.claude/projects/m2star-loop.log"
RESULTS="$WORK_DIR/results.tsv"

# Ensure claude CLI is available
if ! command -v claude &>/dev/null; then
  echo "ERROR: 'claude' CLI not found. Install Claude Code first." >&2
  exit 1
fi

mkdir -p "$(dirname "$LOG")"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] M2* Loop starting" | tee -a "$LOG"
echo "  Chain:      /chain $CHAIN" | tee -a "$LOG"
echo "  Directory:  $WORK_DIR" | tee -a "$LOG"
echo "  Max iters:  $MAX_ITER" | tee -a "$LOG"
echo "  Log:        $LOG" | tee -a "$LOG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG"

cd "$WORK_DIR"

COMPLETED=0
for i in $(seq 1 "$MAX_ITER"); do
  echo "" | tee -a "$LOG"
  echo "── Iteration $i/$MAX_ITER ──────────────────────" | tee -a "$LOG"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting iteration $i" | tee -a "$LOG"

  # Run claude non-interactively with the chain
  # --output-format text: plain text output (no TUI)
  # --max-turns 50: prevent runaway loops within a single claude invocation
  if claude -p "/chain $CHAIN" \
      --output-format text \
      --max-turns 50 \
      2>&1 | tee -a "$LOG"; then
    COMPLETED=$((COMPLETED + 1))
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Iteration $i completed successfully" | tee -a "$LOG"
  else
    EXIT_CODE=$?
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Iteration $i exited with code $EXIT_CODE" | tee -a "$LOG"
    # Non-zero exit from claude — stop the loop
    echo "Claude exited with error — stopping loop." | tee -a "$LOG"
    break
  fi

  # Show current results if they exist
  if [ -f "$RESULTS" ]; then
    echo "" | tee -a "$LOG"
    echo "── results.tsv (current state) ──" | tee -a "$LOG"
    cat "$RESULTS" | tee -a "$LOG"
  fi
done

echo "" | tee -a "$LOG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Loop complete" | tee -a "$LOG"
echo "  Completed:  $COMPLETED / $MAX_ITER iterations" | tee -a "$LOG"

if [ -f "$RESULTS" ]; then
  echo "" | tee -a "$LOG"
  echo "── Final results.tsv ──" | tee -a "$LOG"
  cat "$RESULTS" | tee -a "$LOG"
  BEST=$(awk -F'\t' 'NR>1 && $3=="keep"' "$RESULTS" | tail -1)
  [ -n "$BEST" ] && echo "  Best kept:  $BEST" | tee -a "$LOG"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG"
