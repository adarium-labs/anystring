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
--  Backend-specific note (wide_string):
--    The storage is UTF-16. Scalars U+10000..U+10FFFF are valid UTF-8 and
--    are stored as surrogate pairs, so they decode to Ok (they are not
--    Code_Point_Out_Of_Range on this backend). A leading U+FEFF is kept.
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
   --  Wide_String_Operations.From_Wide_Wide_String (the shared replacement
   --  decoder output), so a leading U+FEFF is kept and no library decoder runs.
   --
   --  Code points U+10000..U+10FFFF are stored as UTF-16 surrogate pairs and
   --  are Ok; see the package header.
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
