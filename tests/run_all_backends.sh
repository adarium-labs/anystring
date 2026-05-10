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
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

# Backends to test (uxstring is conditionally run if crate is available)
STANDARD_BACKENDS=("standard" "wide_string" "wide_wide_string")
OPTIONAL_BACKENDS=("uxstring")

PASS_COLOR='\033[0;32m'
FAIL_COLOR='\033[0;31m'
INFO_COLOR='\033[0;36m'
RESET_COLOR='\033[0m'

overall_status=0

run_backend() {
    local backend="$1"
    echo ""
    echo -e "${INFO_COLOR}=== Testing backend: ${backend} ===${RESET_COLOR}"

    # Build
    if ! STRING_TYPE="${backend}" alr build 2>&1; then
        echo -e "${FAIL_COLOR}FAIL [${backend}]: build failed${RESET_COLOR}"
        overall_status=1
        return
    fi

    # Run
    if STRING_TYPE="${backend}" alr run 2>&1; then
        echo -e "${PASS_COLOR}PASS [${backend}]${RESET_COLOR}"
    else
        echo -e "${FAIL_COLOR}FAIL [${backend}]: test run reported failures${RESET_COLOR}"
        overall_status=1
    fi
}

echo "Anystrings UTF-8 Boundary API — Cross-Backend Test Run"
echo "======================================================="
echo "Working directory: ${SCRIPT_DIR}"
echo ""

# Run standard backends unconditionally
for backend in "${STANDARD_BACKENDS[@]}"; do
    run_backend "${backend}"
done

# Run optional backends only if their crate is available
for backend in "${OPTIONAL_BACKENDS[@]}"; do
    if alr show "${backend}" > /dev/null 2>&1; then
        run_backend "${backend}"
    else
        echo ""
        echo -e "${INFO_COLOR}SKIP [${backend}]: crate not found in Alire index${RESET_COLOR}"
    fi
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
