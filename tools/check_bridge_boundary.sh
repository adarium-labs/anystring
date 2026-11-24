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
#  the backend, from a throw-away project outside the repository. The
#  positive control must compile; every negative case must FAIL to compile.
#  Without the positive control a broken harness would look like a pass.
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

#  probe <backend> <case> <expect: ok|fail> <main.adb body>
#  The main.adb body is the full file content; the project is generated.
probe() {
    local backend="$1" name="$2" expect="$3" body="$4"
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
    local first_error
    first_error="$(grep -m1 -i 'error' "${dir}/build.log" || true)"

    if [ "${expect}" = "ok" ]; then
        if [ "${rc}" -eq 0 ]; then
            echo "PASS  ${backend} ${name} (compiles, as expected)"
        else
            echo "FAIL  ${backend} ${name} (positive control did not compile)"
            tail -20 "${dir}/build.log"
            overall=1
        fi
    else
        if [ "${rc}" -ne 0 ]; then
            echo "PASS  ${backend} ${name} (rejected: ${first_error})"
        else
            echo "FAIL  ${backend} ${name} (client compiled: the bridge is reachable)"
            overall=1
        fi
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
    probe "${backend}" positive_public_api ok "${POSITIVE}"

    case "${backend}" in
        wide_wide_string)
            #  The bridge was Empty_String_Value.Convert.From_Unbounded: the
            #  unit must not exist as a public unit.
            probe "${backend}" neg_bridge_unit fail 'with String_Empty_Value.Convert;
procedure Main is
begin
   null;
end Main;'
            #  Naming the bridge functions of String_Types (private, not exported).
            probe "${backend}" neg_wrap_function fail 'with String_Types;
with Ada.Strings.Wide_Wide_Unbounded;
procedure Main is
   S : constant String_Types.String_Type :=
     String_Types.Wrap (Ada.Strings.Wide_Wide_Unbounded.Null_Unbounded_Wide_Wide_String);
begin
   null;
end Main;'
            #  Building the value by record aggregate on the private type.
            probe "${backend}" neg_aggregate fail 'with String_Types;
with Ada.Strings.Wide_Wide_Unbounded;
procedure Main is
   S : constant String_Types.String_Type :=
     (Value => Ada.Strings.Wide_Wide_Unbounded.Null_Unbounded_Wide_Wide_String);
begin
   null;
end Main;'
            ;;
        uxstring)
            #  Naming the bridge function of String_Types (private, not exported).
            probe "${backend}" neg_wrap_function fail 'with String_Types;
with UXStrings;
procedure Main is
   S : constant String_Types.String_Type :=
     String_Types.Wrap (UXStrings.Null_UXString);
begin
   null;
end Main;'
            #  Building the value by record aggregate on the private type.
            probe "${backend}" neg_aggregate fail 'with String_Types;
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
