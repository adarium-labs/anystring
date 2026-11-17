-------------------------------------------------------------------------------
--  UXString_UTF_8_Bridge - From_UTF_8 body for the uxstring backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Strings.Unbounded;
with Anystrings_UTF_8_Validate;
with Anystrings_UTF_8;
with Anystrings_UTF_8_Replace;
with UXString_Operations;
with UXStrings;

package body UXString_UTF_8_Bridge is

   use UXString_UTF_8_Results;
   use Anystrings_UTF_8;

   --  Build a UXString from a Source already validated as UTF-8, through the
   --  shared decoder: a leading U+FEFF is kept and no library decoder runs
   --  (UXStrings.From_UTF_8 would strip a BOM). UXS5 stores code points, so no
   --  UTF-8 storage invariant applies to the result.
   function Build_UXString_From_Valid_UTF_8
     (Source : String) return UXStrings.UXString
   is
   begin
      return UXString_Operations.From_Wide_Wide_String
        (Anystrings_UTF_8_Replace.Decode_Replacing (Source));
   end Build_UXString_From_Valid_UTF_8;

   --  @relation FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010, FUNC-UTF8-011,
   --            FUNC-UTF8-013, NFR-UTF8-004, NFR-UTF8-005
   function From_UTF_8_UXString
     (Source : String) return UXString_UTF_8_Results.UTF_8_Decode_Result
   is
      VR : constant Anystrings_UTF_8_Validate.Validate_Result :=
        Anystrings_UTF_8_Validate.Validate (Source);
   begin
      if not VR.Is_Ok then
         return Make_Error (VR.Error);
      end if;

      --  Source is well-formed UTF-8. Build a UXString that stores Latin-1
      --  supplement code points (U+0080..U+00FF) as single bytes, matching
      --  the convention used by To_String_Type / To_UXString so that
      --  From_UTF_8 (To_UTF_8 (S)) = S holds (FUNC-UTF8-011, NFR-UTF8-004).
      declare
         Result : constant UXStrings.UXString :=
           Build_UXString_From_Valid_UTF_8 (Source);
      begin
         return Make_Ok (Result);
      end;
   exception
      when others =>
         --  Defensive: should not be reached after validator pass.
         return Make_Error (Anystrings_UTF_8.Invalid_Lead_Byte);
   end From_UTF_8_UXString;

end UXString_UTF_8_Bridge;
