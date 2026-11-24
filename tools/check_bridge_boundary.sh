#!/usr/bin/env bash
#  tools/check_bridge_boundary.sh
#
#  Negative-compile check for the String_Type bridge. On the backends whose
#  String_Type holds scalar values only (wide_wide_string and uxstring, see
#  docs/text-model.md section 9.6), a client must NOT be able to name the
#  bridge that turns an Ada unbounded / UXStrings value into String_Type:
#  otherwise it could store a non-scalar (U+D800, U+110000) by skipping the
#  sanitising API.
#
#  Each case compiles one small client program against the library built for
#  the backend, from a throw-away project outside the repository.
#
#  - The positive control must compile, so a broken harness cannot pass.
#  - Every negative case must fail to compile, and every compiler error it
#    reports must match the diagnostic expected for that case. A failure for
#    another reason (a typo in the probe, a broken library build) is a FAIL.
#
#  Usage:  tools/check_bridge_boundary.sh [backend ...]
#  Exit code: 0 if every case behaves as expected, 1 otherwise.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [ "$#" -gt 0 ]; then
    BACKENDS=("$@")
else
    BACKENDS=("wide_wide_string" "uxstring")
fi

WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT
overall=0

#  Expected diagnostics (ERE), matched against each ": error: " line.
DIAG_UNIT_NOT_FOUND='error: file ".*" not found$'
DIAG_NOT_VISIBLE='error: ".*" is not a visible entity of "String_Types"$'
#  The aggregate is rejected twice by GNAT: the type is private, and the
#  aggregate is not a composite view of it. Both come from the same cause.
DIAG_PRIVATE_AGGREGATE='error: (expected private type "String_Type" defined at|found a composite type)'

#  probe <backend> <case> <expect: ok|fail> <diagnostic regex|-> <main.adb body>
probe() {
    local backend="$1" name="$2" expect="$3" diag="$4" body="$5"
    local dir="${WORK}/${backend}/${name}"
    mkdir -p "${dir}"
    printf '%s\n' "${body}" > "${dir}/main.adb"
    cat > "${dir}/probe.gpr" <<EOF
with "${ROOT}/anystrings.gpr";
project Probe is
   for Source_Dirs use (".");
   for Object_Dir use "obj";
   for Main use ("main.adb");
   package Compiler is
      for Default_Switches ("Ada") use ("-gnat2022");
   end Compiler;
end Probe;
EOF
    (
        cd "${ROOT}" && STRING_TYPE="${backend}" \
            alr exec -- gprbuild -q -P "${dir}/probe.gpr" > "${dir}/build.log" 2>&1
    )
    local rc=$?

    if [ "${expect}" = "ok" ]; then
        if [ "${rc}" -eq 0 ]; then
            echo "PASS  ${backend} ${name} (compiles, as expected)"
        else
            echo "FAIL  ${backend} ${name} (positive control did not compile)"
            tail -20 "${dir}/build.log"
            overall=1
        fi
        return
    fi

    #  Negative case: every compiler error must be the expected one.
    local n_err n_match first_match
    n_err="$(grep -c ': error: ' "${dir}/build.log" || true)"
    n_match="$(grep ': error: ' "${dir}/build.log" | grep -cE "${diag}" || true)"
    first_match="$(grep ': error: ' "${dir}/build.log" | grep -E "${diag}" | head -1 || true)"

    if [ "${rc}" -eq 0 ]; then
        echo "FAIL  ${backend} ${name} (client compiled: the bridge is reachable)"
        overall=1
    elif [ "${n_err}" -eq 0 ]; then
        echo "FAIL  ${backend} ${name} (failed without a compiler error; see build log)"
        tail -20 "${dir}/build.log"
        overall=1
    elif [ "${n_match}" -ne "${n_err}" ]; then
        echo "FAIL  ${backend} ${name} (${n_err} error(s), ${n_match} as expected; unexpected:)"
        grep ': error: ' "${dir}/build.log" | grep -vE "${diag}" | head -5
        overall=1
    else
        echo "PASS  ${backend} ${name} (rejected: ${first_match})"
    fi
}

#  Positive control, common to every backend: the public API still works.
POSITIVE='with String_Types;
procedure Main is
   S : constant String_Types.String_Type := String_Types.Null_String_Value;
begin
   if String_Types.Length (S) /= 0 then
      null;
   end if;
end Main;'

for backend in "${BACKENDS[@]}"; do
    echo ""
    echo "=== BRIDGE BOUNDARY: ${backend} ==="
    probe "${backend}" positive_public_api ok - "${POSITIVE}"

    case "${backend}" in
        wide_wide_string)
            #  The bridge was Empty_String_Value.Convert.From_Unbounded: the
            #  unit must not exist as a public unit any more.
            probe "${backend}" neg_bridge_unit fail "${DIAG_UNIT_NOT_FOUND}" 'with String_Empty_Value.Convert;
procedure Main is
begin
   null;
end Main;'
            #  Naming the bridge function of String_Types (private, not exported).
            probe "${backend}" neg_wrap_function fail "${DIAG_NOT_VISIBLE}" 'with String_Types;
with Ada.Strings.Wide_Wide_Unbounded;
procedure Main is
   S : constant String_Types.String_Type :=
     String_Types.Wrap (Ada.Strings.Wide_Wide_Unbounded.Null_Unbounded_Wide_Wide_String);
begin
   null;
end Main;'
            #  Building the value by record aggregate on the private type.
            probe "${backend}" neg_aggregate fail "${DIAG_PRIVATE_AGGREGATE}" 'with String_Types;
with Ada.Strings.Wide_Wide_Unbounded;
procedure Main is
   S : constant String_Types.String_Type :=
     (Value => Ada.Strings.Wide_Wide_Unbounded.Null_Unbounded_Wide_Wide_String);
begin
   null;
end Main;'
            ;;
        uxstring)
            #  The bridge was UXString_Wrapper.Convert (public, From_UXString).
            #  The unit is gone; naming it must fail on the missing file.
            probe "${backend}" neg_bridge_unit fail "${DIAG_UNIT_NOT_FOUND}" 'with UXString_Wrapper.Convert;
procedure Main is
begin
   null;
end Main;'
            #  Naming the bridge function of String_Types (private, not exported).
            probe "${backend}" neg_wrap_function fail "${DIAG_NOT_VISIBLE}" 'with String_Types;
with UXStrings;
procedure Main is
   S : constant String_Types.String_Type :=
     String_Types.Wrap (UXStrings.Null_UXString);
begin
   null;
end Main;'
            #  Building the value by record aggregate on the private type.
            probe "${backend}" neg_aggregate fail "${DIAG_PRIVATE_AGGREGATE}" 'with String_Types;
with UXStrings;
procedure Main is
   S : constant String_Types.String_Type := (Value => UXStrings.Null_UXString);
begin
   null;
end Main;'
            ;;
        *)
            echo "SKIP  ${backend} (no bridge boundary defined for this backend)"
            ;;
    esac
done

echo ""
if [ "${overall}" -eq 0 ]; then
    echo "=== BRIDGE BOUNDARY: PASS ==="
else
    echo "=== BRIDGE BOUNDARY: FAIL ==="
fi
exit "${overall}"
