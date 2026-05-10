-------------------------------------------------------------------------------
--  Wide_UTF_8_Bridge - From_UTF_8 wrapper for the wide_string backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Thin bridge package supplying From_UTF_8_Wide for the wide_string backend.
--
--  @description
--  Wide_String_Operations cannot return Wide_UTF_8_Results.UTF_8_Decode_Result
--  directly because Wide_UTF_8_Results depends on Wide_String_Operations,
--  which would create a circular dependency. This bridge package breaks the
--  cycle by withing both packages and declaring the one bridging function.
--
--  Wide_Strings passes Wide_UTF_8_Bridge.From_UTF_8_Wide as the actual for
--  the From_UTF_8 formal subprogram. String_Types renames it.
--
--  Backend-specific note (Code_Point_Out_Of_Range re-use, Q2 resolution):
--    Wide_Character cannot represent Unicode scalars U+10000..U+10FFFF.
--    These values are valid UTF-8 and valid Unicode, but unrepresentable in
--    this backend. The auto-resolved design decision classifies them as
--    Code_Point_Out_Of_Range (the same variant used for scalars > U+10FFFF).
--    This is permitted by FUNC-UTF8-010's "deterministic for a given backend"
--    clause. A new variant (e.g. Unrepresentable_In_Backend) was considered
--    but rejected to keep the enumeration stable across backends. See
--    docs/tech-specs/utf8-boundary-api.md §5.2 and §11 Q2.
--
--  Responsibilities:
--    * Declare From_UTF_8_Wide returning Wide_UTF_8_Results.UTF_8_Decode_Result.
--
--  Requirements Coverage: FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010,
--                          FUNC-UTF8-011, NFR-UTF8-004, NFR-UTF8-006
--
--  External Effects: None
--  Thread Safety: Stateless; safe to call from multiple tasks simultaneously.
--  SPARK Status: Not applicable (body uses GNAT runtime).

--  @relation FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010, FUNC-UTF8-011, NFR-UTF8-004

with Wide_UTF_8_Results;

package Wide_UTF_8_Bridge is

   --  @summary Decode a UTF-8 byte sequence into a wide_string backend result.
   --
   --  @description
   --  Total and non-raising (NFR-UTF8-004, NFR-UTF8-005). Runs the shared
   --  six-variant UTF-8 validator first. On failure, returns
   --  Wide_UTF_8_Results.Make_Error (Reason). On success, decodes via
   --  Ada.Strings.UTF_Encoding.Wide_Strings.Decode to a Wide_String, then
   --  converts to Unbounded_Wide_String.
   --
   --  Code points U+10000..U+10FFFF (valid Unicode, valid UTF-8, but
   --  unrepresentable in Wide_Character) are classified as
   --  Code_Point_Out_Of_Range — see package header for the design rationale.
   --
   --  Empty input returns Is_Ok = True with an empty string (FUNC-UTF8-009).
   --
   --  Naming: suffixed _Wide to avoid aliasing risk when all four backends'
   --  packages are simultaneously visible.
   --
   --  @param Source  UTF-8 byte sequence to decode.
   --  @return        Wide_UTF_8_Results.UTF_8_Decode_Result.
   --  @relation FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010, FUNC-UTF8-011, NFR-UTF8-004
   function From_UTF_8_Wide
     (Source : String) return Wide_UTF_8_Results.UTF_8_Decode_Result;

end Wide_UTF_8_Bridge;
