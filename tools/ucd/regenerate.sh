#!/usr/bin/env bash
#
# Regenerate src/anystrings_ucd_case.ads/.adb from the vendored UCD files.
#
# Usage (from anywhere):
#   tools/ucd/regenerate.sh [VERSION]     # VERSION defaults to 15.1.0
#
# Builds the generator with gprbuild (no Alire needed) and runs it on
# tools/ucd/data/VERSION. The output is deterministic: running this on
# unchanged data leaves the generated files byte-identical.

set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
version="${1:-15.1.0}"
data="$root/tools/ucd/data/$version"

if [[ ! -f "$data/UnicodeData.txt" ]]; then
  echo "regenerate.sh: no UCD data for version $version in $data" >&2
  exit 1
fi

gprbuild -q -P "$root/tools/ucd/ucd_generator.gpr"
"$root/tools/ucd/bin/ucd_generator" "$data" "$root/src"
