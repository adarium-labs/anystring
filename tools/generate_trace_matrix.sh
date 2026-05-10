#!/bin/bash
# generate_trace_matrix.sh — Generate bidirectional traceability matrix
#
# Extracts @relation(REQ-ID) annotations from Ada source and test files,
# cross-references with StrictDoc requirement UIDs, and outputs:
#   - output/traceability-matrix.md  (Markdown table)
#   - output/traceability-matrix.csv (CSV for CI/tooling)
#
# Role inference from file path:
#   libs/*/src/*.ads        → Specification
#   libs/*/src/*.adb        → Implementation
#   libs/*/tests/src/*      → Verification

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/output"

# Option: --all shows all requirements; default shows only FUNC-* requirements
SHOW_ALL=false
for arg in "$@"; do
   case "$arg" in
      --all) SHOW_ALL=true ;;
   esac
done

mkdir -p "$OUTPUT_DIR"

# Temporary work files
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

REQS_FILE="$TMP_DIR/requirements.tsv"
SPEC_FILE="$TMP_DIR/spec_relations.tsv"
IMPL_FILE="$TMP_DIR/impl_relations.tsv"
TEST_FILE="$TMP_DIR/test_relations.tsv"

# ---------------------------------------------------------------------------
# Step 1: Extract all requirement UIDs and STATUS from .sdoc files
# ---------------------------------------------------------------------------
extract_requirements() {
   # Extract UIDs from [REQUIREMENT] blocks only (skip document-level UIDs)
   local in_req=false
   local uid=""
   local status=""

   while IFS= read -r line; do
      # Any block tag: flush previous requirement, then decide if new block is a requirement
      if [[ "$line" =~ ^\[.*\]$ ]]; then
         # Flush previous requirement if we had one
         if $in_req && [[ -n "$uid" ]]; then
            [[ -z "$status" ]] && status="Draft"
            printf '%s\t%s\n' "$uid" "$status"
         fi
         # Start new state
         if [[ "$line" == "[REQUIREMENT]" ]]; then
            in_req=true
         else
            in_req=false
         fi
         uid=""
         status=""
      elif $in_req; then
         if [[ "$line" =~ ^UID:\ *(.*) ]]; then
            uid="${BASH_REMATCH[1]}"
         elif [[ "$line" =~ ^STATUS:\ *(.*) ]]; then
            status="${BASH_REMATCH[1]}"
         fi
      fi
   done < <(cat "$PROJECT_ROOT"/docs/requirements/*.sdoc)

   # Flush last requirement
   if $in_req && [[ -n "$uid" ]]; then
      [[ -z "$status" ]] && status="Draft"
      printf '%s\t%s\n' "$uid" "$status"
   fi
}

# ---------------------------------------------------------------------------
# Step 2: Extract @relation(REQ-ID) from source files
# ---------------------------------------------------------------------------
extract_relations() {
   local search_path="$1"
   local glob_pattern="$2"
   local exclude_pattern="${3:-}"  # optional path pattern to exclude

   find "$search_path" -name "$glob_pattern" -print0 2>/dev/null | while IFS= read -r -d '' file; do
      # Skip files matching exclude pattern (full path check)
      if [[ -n "$exclude_pattern" && "$file" == *"$exclude_pattern"* ]]; then
         continue
      fi
      local matches
      matches=$(grep -oE '@relation\([A-Z]+-[A-Z]*-?[0-9]+(-[A-Z]+)?\)' "$file" 2>/dev/null || true)
      [[ -z "$matches" ]] && continue
      local bname
      bname=$(basename "$file")
      echo "$matches" | while read -r match; do
         local req_id
         req_id=$(echo "$match" | sed 's/@relation(\(.*\))/\1/')
         printf '%s\t%s\n' "$req_id" "$bname"
      done
   done
}

# ---------------------------------------------------------------------------
# Step 3: Build the matrix
# ---------------------------------------------------------------------------

echo "Extracting requirements from StrictDoc files..."
if $SHOW_ALL; then
   extract_requirements | sort -u > "$REQS_FILE"
else
   extract_requirements | sort -u | grep '^FUNC-' > "$REQS_FILE"
fi

echo "Scanning .ads files (Specification)..."
extract_relations "$PROJECT_ROOT/libs" "*.ads" "tests/src/" > "$SPEC_FILE" 2>/dev/null || true

echo "Scanning .adb files (Implementation)..."
extract_relations "$PROJECT_ROOT/libs" "*.adb" "tests/src/" > "$IMPL_FILE" 2>/dev/null || true

echo "Scanning test files (Verification)..."
extract_test_relations() {
   for ext in ads adb; do
      find "$PROJECT_ROOT/libs" -path '*/tests/src/*' -name "*.$ext" -print0 2>/dev/null | while IFS= read -r -d '' file; do
         local matches
         matches=$(grep -oE '@relation\([A-Z]+-[A-Z]*-?[0-9]+(-[A-Z]+)?\)' "$file" 2>/dev/null || true)
         [[ -z "$matches" ]] && continue
         local bname
         bname=$(basename "$file")
         echo "$matches" | while read -r match; do
            local req_id
            req_id=$(echo "$match" | sed 's/@relation(\(.*\))/\1/')
            printf '%s\t%s\n' "$req_id" "$bname"
         done
      done
   done
}
extract_test_relations | sort -u > "$TEST_FILE"

# ---------------------------------------------------------------------------
# Step 4: Generate outputs
# ---------------------------------------------------------------------------

REQ_COUNT=$(wc -l < "$REQS_FILE" | tr -d ' ')
COVERED_FULL=0
COVERED_SPEC=0
COVERED_TEST=0
COVERED_NONE=0

MD_FILE="$OUTPUT_DIR/traceability-matrix.md"
CSV_FILE="$OUTPUT_DIR/traceability-matrix.csv"

{
   echo "# Traceability Matrix"
   echo ""
   echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
   echo ""
   echo "| Requirement | Status | Spec (.ads) | Impl (.adb) | Test | Coverage |"
   echo "|---|---|---|---|---|---|"
} > "$MD_FILE"

echo "requirement,status,spec_files,impl_files,test_files,coverage" > "$CSV_FILE"

while IFS=$'\t' read -r uid status; do
   # Collect spec files for this UID
   spec_files=$(awk -F'\t' -v uid="$uid" '$1 == uid { print $2 }' "$SPEC_FILE" | sort -u | paste -sd ',' - 2>/dev/null)
   [[ -z "$spec_files" ]] && spec_files="-"

   # Collect impl files for this UID
   impl_files=$(awk -F'\t' -v uid="$uid" '$1 == uid { print $2 }' "$IMPL_FILE" | sort -u | paste -sd ',' - 2>/dev/null)
   [[ -z "$impl_files" ]] && impl_files="-"

   # Collect test files for this UID
   test_files=$(awk -F'\t' -v uid="$uid" '$1 == uid { print $2 }' "$TEST_FILE" | sort -u | paste -sd ',' - 2>/dev/null)
   [[ -z "$test_files" ]] && test_files="-"

   # Determine coverage level
   has_spec=false
   has_test=false
   [[ "$spec_files" != "-" ]] && has_spec=true
   [[ "$test_files" != "-" ]] && has_test=true

   if $has_spec && $has_test; then
      coverage="Full"
      COVERED_FULL=$((COVERED_FULL + 1))
   elif $has_spec; then
      coverage="Spec only"
      COVERED_SPEC=$((COVERED_SPEC + 1))
   elif $has_test; then
      coverage="Test only"
      COVERED_TEST=$((COVERED_TEST + 1))
   else
      coverage="None"
      COVERED_NONE=$((COVERED_NONE + 1))
   fi

   # Write Markdown row
   echo "| $uid | $status | $spec_files | $impl_files | $test_files | $coverage |" >> "$MD_FILE"

   # Write CSV row (quote fields that may contain commas)
   echo "\"$uid\",\"$status\",\"$spec_files\",\"$impl_files\",\"$test_files\",\"$coverage\"" >> "$CSV_FILE"

done < "$REQS_FILE"

# Summary
{
   echo ""
   echo "## Summary"
   echo ""
   echo "| Metric | Count |"
   echo "|---|---|"
   echo "| Total requirements | $REQ_COUNT |"
   echo "| Full coverage (spec + test) | $COVERED_FULL |"
   echo "| Spec only | $COVERED_SPEC |"
   echo "| Test only | $COVERED_TEST |"
   echo "| No coverage | $COVERED_NONE |"
} >> "$MD_FILE"

echo ""
echo "Traceability matrix generated:"
echo "  Markdown: $MD_FILE"
echo "  CSV:      $CSV_FILE"
echo ""
if $SHOW_ALL; then
   echo "Summary (all): $REQ_COUNT requirements — Full: $COVERED_FULL, Spec only: $COVERED_SPEC, Test only: $COVERED_TEST, None: $COVERED_NONE"
else
   echo "Summary (FUNC-* only, use --all for all): $REQ_COUNT requirements — Full: $COVERED_FULL, Spec only: $COVERED_SPEC, Test only: $COVERED_TEST, None: $COVERED_NONE"
fi
