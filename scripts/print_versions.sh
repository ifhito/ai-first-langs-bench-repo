#!/usr/bin/env bash
# Print the version of every benchmark toolchain available in this image.
set -u
echo "=== AI-first language benchmark — toolchain versions ==="
probe() {
  local name="$1"; shift
  if command -v "$1" >/dev/null 2>&1; then
    printf '%-12s ' "$name"; "$@" 2>&1 | head -1
  else
    printf '%-12s MISSING (%s not on PATH)\n' "$name" "$1"
  fi
}
probe "JavaScript" node --version
probe "Python"     python3 --version
probe "Zero"       zero --version
probe "MoonBit"    moon version
probe "NanoLang"   nanolang --version
probe "Vera"       vera --version
echo "========================================================"
