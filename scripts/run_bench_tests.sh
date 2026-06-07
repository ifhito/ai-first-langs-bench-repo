#!/usr/bin/env bash
# Re-run the generated parser test harnesses for whatever results exist.
#
# This reproduces the GRADING step of the benchmark (running the 22 test cases
# against already-generated parsers). The GENERATION step is driven by an AI
# agent and is not reproduced here — see AGENT_INSTRUCTIONS.md.
#
# Usage:  scripts/run_bench_tests.sh [problem-dir]
#   default problem-dir = problem1-json-parser
set -u
PROBLEM="${1:-problem1-json-parser}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESULTS="${ROOT}/${PROBLEM}/results"

if [ ! -d "${RESULTS}" ]; then
  echo "no results dir: ${RESULTS}" >&2; exit 1
fi

echo "=== Running benchmark test harnesses in ${PROBLEM}/results ==="
status=0
for langdir in "${RESULTS}"/*/; do
  lang="$(basename "${langdir}")"
  echo
  echo "--- ${lang} ---"
  if   [ -f "${langdir}run_tests.js" ]; then
    ( cd "${langdir}" && node run_tests.js ) || status=1
  elif [ -f "${langdir}run_tests.py" ]; then
    ( cd "${langdir}" && python3 run_tests.py ) || status=1
  elif ls "${langdir}"*.0 >/dev/null 2>&1; then
    # Zero: try the project/file test runner if present
    ( cd "${langdir}" && zero test . ) || echo "(Zero: adjust the command for this layout)"
  else
    echo "no recognized test harness in ${langdir}"
  fi
done
echo
echo "=== done (exit ${status}) ==="
exit "${status}"
