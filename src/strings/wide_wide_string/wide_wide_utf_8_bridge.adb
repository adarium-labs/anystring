-------------------------------------------------------------------------------
--  Wide_Wide_UTF_8_Bridge - From_UTF_8 body for the wide_wide_string backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Anystrings_UTF_8_Validate;
with Anystrings_UTF_8_Replace;
with Ada.Strings.Wide_Wide_Unbounded;

package body Wide_Wide_UTF_8_Bridge is

   use Wide_Wide_UTF_8_Results;

   --  @relation FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010, FUNC-UTF8-011, NFR-UTF8-004
   function From_UTF_8_Wide_Wide
     (Source : String) return Wide_Wide_UTF_8_Results.UTF_8_Decode_Result
   is
      VR : constant Anystrings_UTF_8_Validate.Validate_Result :=
        Anystrings_UTF_8_Validate.Validate (Source);
   begin
      if not VR.Is_Ok then
         return Make_Error (VR.Error);
      end if;

      --  Source is well-formed UTF-8: decode it with the shared decode path,
      --  which keeps a leading BOM. No library decoder is called (it would
      --  strip a BOM and raise on ill-formed input).
      return Make_Ok
        (Ada.Strings.Wide_Wide_Unbounded.To_Unbounded_Wide_Wide_String
           (Anystrings_UTF_8_Replace.Decode_Replacing (Source)));
   end From_UTF_8_Wide_Wide;

end Wide_Wide_UTF_8_Bridge;
