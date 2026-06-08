#!/usr/bin/env bash
###############################################################################
#  tests/run_all_backends.sh
#
#  Run the anystrings UTF-8 test suite against every available backend and
#  report PASS / FAIL per backend.
#
#  Usage:
#    cd tests
#    ./run_all_backends.sh
#
#  Exit code: 0 if all backends pass, 1 if any backend fails or errors.
###############################################################################
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

#  All backends supported by anystrings. Every one has its dependency
#  declared in the parent's alire.toml (anystrings transitively pulls
#  uxstrings and vss_text), so we attempt all of them and let the build
#  step decide whether the backend is actually usable.
BACKENDS=("standard" "wide_string" "wide_wide_string" "uxstring" "vss")

PASS_COLOR='\033[0;32m'
FAIL_COLOR='\033[0;31m'
INFO_COLOR='\033[0;36m'
RESET_COLOR='\033[0m'

overall_status=0

#  Compute the executable path for a given backend. The wide_string and
#  wide_wide_string backends append an encoding suffix selected at build
#  time via ANYSTRING_WIDE_ENV_ENCODING (defaults to utf_8 in the GPR).
binary_path() {
    local backend="$1"
    case "${backend}" in
        wide_string|wide_wide_string)
            local enc="${ANYSTRING_WIDE_ENV_ENCODING:-utf_8}"
            echo "${SCRIPT_DIR}/bin/${backend}/${enc}/anystrings_test_runner"
            ;;
        *)
            echo "${SCRIPT_DIR}/bin/${backend}/anystrings_test_runner"
            ;;
    esac
}

run_backend() {
    local backend="$1"
    echo ""
    echo -e "${INFO_COLOR}=== Testing backend: ${backend} ===${RESET_COLOR}"

    if ! STRING_TYPE="${backend}" alr build 2>&1; then
        echo -e "${FAIL_COLOR}FAIL [${backend}]: build failed${RESET_COLOR}"
        overall_status=1
        return
    fi

    local binary
    binary="$(binary_path "${backend}")"

    if [ ! -x "${binary}" ]; then
        echo -e "${FAIL_COLOR}FAIL [${backend}]: binary not found at ${binary}${RESET_COLOR}"
        overall_status=1
        return
    fi

    if STRING_TYPE="${backend}" "${binary}"; then
        echo -e "${PASS_COLOR}PASS [${backend}]${RESET_COLOR}"
    else
        echo -e "${FAIL_COLOR}FAIL [${backend}]: test run reported failures${RESET_COLOR}"
        overall_status=1
    fi
}

echo "Anystrings UTF-8 Boundary API — Cross-Backend Test Run"
echo "======================================================="
echo "Working directory: ${SCRIPT_DIR}"

for backend in "${BACKENDS[@]}"; do
    run_backend "${backend}"
done

echo ""
echo "======================================================="
if [ "${overall_status}" -eq 0 ]; then
    echo -e "${PASS_COLOR}ALL BACKENDS: PASS${RESET_COLOR}"
else
    echo -e "${FAIL_COLOR}SOME BACKENDS: FAIL (see above)${RESET_COLOR}"
fi
echo "======================================================="

exit "${overall_status}"
