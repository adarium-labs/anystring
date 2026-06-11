#!/usr/bin/env bash
# Builds anystrings_cmdline_demo for each backend and verifies that argv with
# non-ASCII UTF-8 input round-trips correctly to stdout as UTF-8 bytes.
#
# Exit code: 0 if all backends produce correct UTF-8 output bytes; 1 otherwise.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BACKENDS=("standard" "wide_string" "wide_wide_string" "uxstring" "vss")

# Fixed UTF-8 test arguments:
#   héllo  →  68 c3 a9 6c 6c 6f  (é = c3 a9)
#   café   →  63 61 66 c3 a9     (é = c3 a9)
ARG1="héllo"
ARG2="café"

EXPECTED_E_COUNT=2

all_pass=true
tmpout=$(mktemp)
build_log=$(mktemp)

cleanup() { rm -f "$tmpout" "$build_log"; }
trap cleanup EXIT

for BACKEND in "${BACKENDS[@]}"; do
    printf '=== Backend: %s ===\n' "$BACKEND"

    if ! ( cd "$SCRIPT_DIR" && STRING_TYPE="$BACKEND" alr build >"$build_log" 2>&1 ); then
        echo "  [BUILD FAILED]"
        sed 's/^/    /' "$build_log"
        all_pass=false
        printf '\n'
        continue
    fi

    # Locate binary — handles both:
    #   bin/<backend>/anystrings_cmdline_demo          (standard, uxstring, vss)
    #   bin/<backend>/<encoding>/anystrings_cmdline_demo  (wide_string, wide_wide_string)
    BIN=$(find "$SCRIPT_DIR/bin/$BACKEND" -name "anystrings_cmdline_demo" -type f 2>/dev/null | head -1)
    if [ -z "$BIN" ]; then
        printf '  [BINARY NOT FOUND under %s/bin/%s/]\n' "$SCRIPT_DIR" "$BACKEND"
        all_pass=false
        printf '\n'
        continue
    fi

    "$BIN" "$ARG1" "$ARG2" >"$tmpout" 2>&1 || true

    # grep -c returns exit 1 (non-zero) when there are no matches, hence the fallback.
    e_count=$(grep -c $'\xc3\xa9' "$tmpout" 2>/dev/null) || e_count=0

    argv_hex=$(grep "argv" "$tmpout" | od -A n -t x1 | tr -d ' \n')

    if [ "$e_count" -ge "$EXPECTED_E_COUNT" ]; then
        printf '  PASS  (found %d line(s) with UTF-8 é = c3a9)\n' "$e_count"
    else
        printf '  FAIL  (expected >= %d lines with UTF-8 é, got %d)\n' \
            "$EXPECTED_E_COUNT" "$e_count"
        all_pass=false
    fi
    printf '  argv hex: %s\n\n' "$argv_hex"
done

if $all_pass; then
    echo "ALL-BACKENDS-PASS"
    exit 0
else
    echo "FAIL: one or more backends did not produce correct UTF-8 output"
    exit 1
fi
