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
    # FUNC-FACADE-004 dependency-isolation check: a 'with String_Types;'-only
    # program must NOT pull Ada.Command_Line, Ada.Environment_Variables,
    # Ada.Directories, or any Ada.*Text_IO into its closure.  .ali files
    # live in examples/obj/<backend>/[<enc>/]<profile>/.
    iso_ali=$(find "$SCRIPT_DIR/obj/$BACKEND" -name "anystrings_facade_isolation.ali" -type f 2>/dev/null | head -1)
    if [ -z "$iso_ali" ]; then
        printf '  FACADE-ISOLATION  [SKIP] anystrings_facade_isolation.ali not found under %s/obj/%s/\n' "$SCRIPT_DIR" "$BACKEND"
    elif grep -qiE 'ada\.command_line|a-comlin|ada\.environment_variables|a-envvar|ada\.directories|a-direct|ada\.text_io|a-textio|ada\.wide_text_io|a-witeio|ada\.wide_wide_text_io|a-ztexio|(^|[^a-z0-9_])umwi([^a-z0-9_.]|$)|(^|[^a-z0-9_])umwi\.' "$iso_ali"; then
        printf '  FACADE-ISOLATION  FAIL  forbidden OS unit (cmdline/env/dirs/text_io) leaked into closure of with-String_Types-only program\n'
        all_pass=false
    else
        printf '  FACADE-ISOLATION  PASS  (no forbidden OS unit in .ali for facade-isolation program)\n'
    fi

    printf '  argv hex: %s\n\n' "$argv_hex"

    # ---- Width demo (ANYSTRING_WITH_WIDTH=true) — NFR-WIDTH-001, FUNC-WIDTH-002 ----
    if ( cd "$SCRIPT_DIR" && STRING_TYPE="$BACKEND" ANYSTRING_WITH_WIDTH=true alr build >"$build_log" 2>&1 ); then
        WIDTH_BIN=$(find "$SCRIPT_DIR/bin/$BACKEND" -name "anystrings_width_demo" -type f 2>/dev/null | head -1)
        if [ -z "$WIDTH_BIN" ]; then
            printf '  WIDTH-DEMO  [SKIP] binary not found under %s/bin/%s/\n\n' "$SCRIPT_DIR" "$BACKEND"
        else
            width_out=$(mktemp)
            "$WIDTH_BIN" >"$width_out" 2>&1 || true
            if grep -q "anystrings_width_demo: ALL-OK" "$width_out"; then
                printf '  WIDTH-DEMO  PASS\n\n'
            else
                printf '  WIDTH-DEMO  FAIL  (ALL-OK sentinel not found in output)\n\n'
                all_pass=false
            fi
            rm -f "$width_out"
        fi
    else
        printf '  WIDTH-DEMO  [BUILD FAILED with ANYSTRING_WITH_WIDTH=true]\n\n'
        sed 's/^/    /' "$build_log"
        all_pass=false
    fi
done

if $all_pass; then
    echo "ALL-BACKENDS-PASS"
    exit 0
else
    echo "FAIL: one or more backends did not produce correct UTF-8 output"
    exit 1
fi
