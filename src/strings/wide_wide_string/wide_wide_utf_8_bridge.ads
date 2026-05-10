-------------------------------------------------------------------------------
--  Wide_Wide_UTF_8_Bridge - From_UTF_8 wrapper for the wide_wide_string backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Thin bridge package supplying From_UTF_8_Wide_Wide for the wide_wide_string
--  backend.
--
--  @description
--  Wide_Wide_String_Operations cannot return Wide_Wide_UTF_8_Results.UTF_8_Decode_Result
--  directly because Wide_Wide_UTF_8_Results depends on Wide_Wide_String_Operations,
--  which would create a circular dependency. This bridge package breaks the cycle.
--
--  Wide_Wide_Strings passes Wide_Wide_UTF_8_Bridge.From_UTF_8_Wide_Wide as
--  the actual for the From_UTF_8 formal subprogram. String_Types renames it.
--
--  Backend-specific note (wide_wide):
--    Wide_Wide_Character can hold U+0000..U+7FFFFFFF. The UTF-8 validator
--    already excludes scalars > U+10FFFF as Code_Point_Out_Of_Range, so no
--    range-narrowing is necessary after a successful decode. Values in
--    U+D800..U+DFFF are caught by the Surrogate_Code_Point variant. Values >
--    U+10FFFF are caught by Code_Point_Out_Of_Range. On success the decoded
--    Wide_Wide_String is returned wrapped in Unbounded_Wide_Wide_String.
--    Encoder pre-substitution also covers Wide_Wide_Character values >
--    U+10FFFF (beyond Unicode scalar range) by replacing them with U+FFFD
--    before calling the runtime encoder (FUNC-UTF8-007 extended).
--
--  Responsibilities:
--    * Declare From_UTF_8_Wide_Wide returning Wide_Wide_UTF_8_Results.UTF_8_Decode_Result.
--
--  Requirements Coverage: FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010,
--                          FUNC-UTF8-011, NFR-UTF8-004, NFR-UTF8-006
--
--  External Effects: None
--  Thread Safety: Stateless; safe to call from multiple tasks simultaneously.
--  SPARK Status: Not applicable (body uses GNAT runtime).

--  @relation FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010, FUNC-UTF8-011, NFR-UTF8-004

with Wide_Wide_UTF_8_Results;

package Wide_Wide_UTF_8_Bridge is

   --  @summary Decode a UTF-8 byte sequence into a wide_wide_string result.
   --
   --  @description
   --  Total and non-raising (NFR-UTF8-004, NFR-UTF8-005). Runs the shared
   --  six-variant UTF-8 validator first. On failure, returns
   --  Wide_Wide_UTF_8_Results.Make_Error (Reason). On success, decodes via
   --  Ada.Strings.UTF_Encoding.Wide_Wide_Strings.Decode, then wraps the
   --  result in Unbounded_Wide_Wide_String. No range-narrowing needed: the
   --  validator already excludes > U+10FFFF. Empty input returns Is_Ok = True
   --  with an empty string (FUNC-UTF8-009).
   --
   --  Naming: suffixed _Wide_Wide to avoid aliasing risk when all four backends'
   --  packages are simultaneously visible.
   --
   --  @param Source  UTF-8 byte sequence to decode.
   --  @return        Wide_Wide_UTF_8_Results.UTF_8_Decode_Result.
   --  @relation FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010, FUNC-UTF8-011, NFR-UTF8-004
   function From_UTF_8_Wide_Wide
     (Source : String) return Wide_Wide_UTF_8_Results.UTF_8_Decode_Result;

end Wide_Wide_UTF_8_Bridge;
