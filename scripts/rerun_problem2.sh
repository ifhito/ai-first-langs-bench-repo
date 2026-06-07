#!/usr/bin/env bash
# Re-run every problem2 condition in the fixed container (or locally for JS/Python)
# and capture COMMAND + stdout + stderr + exit code into results/<lang>/<cond>/rerun.log.
#
# These logs are *evidence*, not the verdict. The verdict comes from applying
# problem2-bank-account/RUBRIC.md to the source (see results/REGRADE.md):
# re-running an agent's own harness cannot catch a missing-rejection defect,
# because the harness only checks balances.
#
# Usage:  scripts/rerun_problem2.sh
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
P2="$REPO/problem2-bank-account"
IMG="ai-lang-bench"

# run_capture <logfile> <label> <command...>
# Runs the command, tees combined output to the log with a header and the exit code.
run_capture() {
  local log="$1"; shift
  local label="$1"; shift
  mkdir -p "$(dirname "$log")"
  {
    echo "## condition: $label"
    echo "## command: $*"
    echo "## date(host): $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "----- stdout+stderr -----"
  } > "$log"
  # Capture combined stream and the exit code faithfully.
  "$@" >> "$log" 2>&1
  local code=$?
  {
    echo "----- exit code -----"
    echo "$code"
  } >> "$log"
  echo "[$label] exit=$code -> ${log#$REPO/}"
}

# Container helper: run a bash -lc command with the repo bind-mounted, in a workdir.
indir() { # <workdir-rel-to-repo> <bash -lc string>
  docker run --rm -v "$REPO":/bench -w "/bench/$1" "$IMG" bash -lc "$2"
}

echo "repo: $REPO"
echo "image: $IMG"
echo

# --- JavaScript/A (local node) ---
run_capture "$P2/results/JavaScript/A/rerun.log" "JavaScript/A" \
  bash -lc "cd '$P2/results/JavaScript/A' && node run_tests.js"

# --- Python/A (local python3) ---
run_capture "$P2/results/Python/A/rerun.log" "Python/A" \
  bash -lc "cd '$P2/results/Python/A' && python3 run_tests.py; echo '(exit-code shown below is python3 exit)'"

# --- Zero/A & B (container) ---
run_capture "$P2/results/Zero/A/rerun.log" "Zero/A" \
  indir "problem2-bank-account/results/Zero/A" "zero run attempt_2.0"
run_capture "$P2/results/Zero/B/rerun.log" "Zero/B" \
  indir "problem2-bank-account/results/Zero/B" "zero run attempt_5.0"

# --- MoonBit/A & B (container, moon test) ---
run_capture "$P2/results/MoonBit/A/rerun.log" "MoonBit/A" \
  indir "problem2-bank-account/results/MoonBit/A/bankaccount" "moon test"
run_capture "$P2/results/MoonBit/B/rerun.log" "MoonBit/B" \
  indir "problem2-bank-account/results/MoonBit/B/bankacct" "moon test"

# --- NanoLang/A & B (container) ---
run_capture "$P2/results/NanoLang/A/rerun.log" "NanoLang/A" \
  indir "problem2-bank-account/results/NanoLang/A" "nanolang attempt_1.nano"
run_capture "$P2/results/NanoLang/B/rerun.log" "NanoLang/B" \
  indir "problem2-bank-account/results/NanoLang/B" "nanolang attempt_2.nano"

# --- Vera/A & B (container, run; B also verify) ---
run_capture "$P2/results/Vera/A/rerun.log" "Vera/A" \
  indir "problem2-bank-account/results/Vera/A" "vera run attempt_5.vera"
run_capture "$P2/results/Vera/B/rerun.log" "Vera/B" \
  indir "problem2-bank-account/results/Vera/B" "vera run attempt_2.vera && echo '--- vera verify ---' && vera verify attempt_2.vera"

echo
echo "done. logs written under results/<lang>/<cond>/rerun.log"
