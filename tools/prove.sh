#!/usr/bin/env bash
###############################################################################
#  tools/prove.sh
#
#  Run GNATprove on anystrings.gpr for the backend selected by STRING_TYPE
#  and fail on any unproved check or SPARK legality error.
#
#  Usage:
#    STRING_TYPE=standard tools/prove.sh
#    STRING_TYPE=wide_string GNATPROVE=/abs/path/to/gnatprove tools/prove.sh
#
#  Environment:
#    STRING_TYPE  backend to prove (default: standard)
#    GNATPROVE    gnatprove executable (default: the Alire gnatprove 15.1.0
#                 release under ~/.local/share/alire). It runs inside
#                 `alr exec` so that the dependency GPR_PROJECT_PATH resolves.
#
#  Scope: --no-subprojects analyzes only the root project. The dependency
#  crates (uxstrings, vss_text) are not SPARK-clean and are out of scope.
#  Backends whose facade depends on them therefore abort here; see
#  src/strings/AGENTS.md ("Proof boundaries").
#
#  Exit code: 0 if every check is proved and there are no SPARK errors,
#  1 otherwise.
###############################################################################
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

export STRING_TYPE="${STRING_TYPE:-standard}"
GNATPROVE="${GNATPROVE:-${HOME}/.local/share/alire/releases/gnatprove_15.1.0_aad9a73f/bin/gnatprove}"

LOG_DIR="${REPO_ROOT}/obj/prove"
mkdir -p "${LOG_DIR}"
LOG_FILE="${LOG_DIR}/${STRING_TYPE}.log"

echo "=== GNATprove: backend ${STRING_TYPE} ==="

status=0
alr exec -- "${GNATPROVE}" \
    -P anystrings.gpr \
    --no-subprojects \
    --mode=all \
    --level=2 \
    -j0 \
    --checks-as-errors=on \
    --report=all > "${LOG_FILE}" 2>&1 || status=$?

if [ "${status}" -ne 0 ]; then
    echo "FAIL [${STRING_TYPE}]: gnatprove exited with ${status} (log: ${LOG_FILE})"
    grep -E ': (error|high|medium|low): ' "${LOG_FILE}" | sort -u | head -50 || true
    exit 1
fi

if grep -q ': error: ' "${LOG_FILE}"; then
    echo "FAIL [${STRING_TYPE}]: SPARK legality errors (log: ${LOG_FILE})"
    grep ': error: ' "${LOG_FILE}" | sort -u | head -50
    exit 1
fi

echo "PASS [${STRING_TYPE}]: all checks proved (log: ${LOG_FILE})"
