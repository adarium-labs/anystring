#!/usr/bin/env bash
#  tools/verify_wws_boundary.sh
#  One-shot verification for the Wide_Wide_String boundary work-plan: builds
#  the library and the test suite under each supported backend, runs the
#  test suite, and reports PASS / FAIL per backend.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${ROOT}"

BACKENDS=("standard" "wide_string" "wide_wide_string" "uxstring" "vss")
overall=0

#  When ANYSTRING_WITH_WIDTH=false (the default) the GPR builds
#  `anystrings_test_runner_no_width` as the main. The wide_* backends also
#  append an encoding suffix to the bin/ subdirectory.
binary_path() {
    local backend="$1"
    local exe="anystrings_test_runner_no_width"
    if [ "${ANYSTRING_WITH_WIDTH:-false}" = "true" ]; then
        exe="anystrings_test_runner"
    fi
    case "${backend}" in
        wide_string|wide_wide_string)
            echo "${ROOT}/tests/bin/${backend}/utf_8/${exe}"
            ;;
        *)
            echo "${ROOT}/tests/bin/${backend}/${exe}"
            ;;
    esac
}

for backend in "${BACKENDS[@]}"; do
    echo ""
    echo "=== BACKEND: ${backend} ==="

    rm -rf "${ROOT}/obj" "${ROOT}/lib"
    if ! STRING_TYPE="${backend}" alr build > "/tmp/build_${backend}.log" 2>&1; then
        echo "BUILD: FAIL ${backend}"
        tail -30 "/tmp/build_${backend}.log"
        overall=1
        continue
    fi
    echo "BUILD: PASS ${backend}"

    rm -rf "${ROOT}/tests/obj" "${ROOT}/tests/bin"
    pushd "${ROOT}/tests" > /dev/null
    if ! STRING_TYPE="${backend}" alr build > "/tmp/testbuild_${backend}.log" 2>&1; then
        echo "TEST-BUILD: FAIL ${backend}"
        tail -30 "/tmp/testbuild_${backend}.log"
        overall=1
        popd > /dev/null
        continue
    fi
    echo "TEST-BUILD: PASS ${backend}"
    popd > /dev/null

    binary="$(binary_path "${backend}")"
    if [ ! -x "${binary}" ]; then
        echo "TEST-RUN: FAIL ${backend} (binary not found at ${binary})"
        overall=1
        continue
    fi

    if STRING_TYPE="${backend}" "${binary}" > "/tmp/testrun_${backend}.log" 2>&1; then
        echo "TEST-RUN: PASS ${backend}"
        grep -E '^RESULT' "/tmp/testrun_${backend}.log" || true
    else
        echo "TEST-RUN: FAIL ${backend}"
        tail -60 "/tmp/testrun_${backend}.log"
        overall=1
    fi
done

echo ""
if [ "${overall}" -eq 0 ]; then
    echo "=== OVERALL: PASS ==="
else
    echo "=== OVERALL: FAIL ==="
fi
exit "${overall}"
