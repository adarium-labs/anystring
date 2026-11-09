#!/usr/bin/env bash
###############################################################################
#  tools/prove.sh
#
#  Run GNATprove for the backend selected by STRING_TYPE and fail on any
#  unproved check or SPARK legality error. Two projects are proved:
#    1. anystrings.gpr      - the library (String_Types facade and its bodies)
#    2. proof/prove_client.gpr - a proof-only SPARK client that relies on the
#                                length contracts and nothing else
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
#  Scope: --no-subprojects analyzes only the root project of each run.
#  Dependency crates are never analyzed. Units of this crate that are not
#  part of the String_Types length surface are SPARK_Mode => Off; see
#  docs/proof-boundaries.md.
#
#  Exit code: 0 if every check of both projects is proved and there are no
#  SPARK errors, 1 otherwise.
###############################################################################
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

export STRING_TYPE="${STRING_TYPE:-standard}"
GNATPROVE="${GNATPROVE:-${HOME}/.local/share/alire/releases/gnatprove_15.1.0_aad9a73f/bin/gnatprove}"

LOG_DIR="${REPO_ROOT}/obj/prove"
mkdir -p "${LOG_DIR}"

# prove <label> <project.gpr>
# Runs gnatprove on one project and returns non-zero on any failure.
prove() {
    local label="$1" project="$2"
    local log_file="${LOG_DIR}/${STRING_TYPE}_${label}.log"
    local status=0

    echo "=== GNATprove: ${label} (${project}), backend ${STRING_TYPE} ==="

    alr exec -- "${GNATPROVE}" \
        -P "${project}" \
        --no-subprojects \
        --mode=all \
        --level=2 \
        -j0 \
        --checks-as-errors=on \
        --report=all > "${log_file}" 2>&1 || status=$?

    if [ "${status}" -ne 0 ]; then
        echo "FAIL [${STRING_TYPE}/${label}]: gnatprove exited with ${status} (log: ${log_file})"
        grep -E ': (error|high|medium|low): ' "${log_file}" | sort -u | head -50 || true
        return 1
    fi

    if grep -q ': error: ' "${log_file}"; then
        echo "FAIL [${STRING_TYPE}/${label}]: SPARK legality errors (log: ${log_file})"
        grep ': error: ' "${log_file}" | sort -u | head -50
        return 1
    fi

    echo "PASS [${STRING_TYPE}/${label}]: all checks proved (log: ${log_file})"
}

status=0
prove library anystrings.gpr || status=1
prove client proof/prove_client.gpr || status=1

exit "${status}"
