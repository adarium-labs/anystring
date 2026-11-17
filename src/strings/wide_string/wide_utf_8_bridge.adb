-------------------------------------------------------------------------------
--  Wide_UTF_8_Bridge - From_UTF_8 body for the wide_string backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Anystrings_UTF_8_Validate;
with Anystrings_UTF_8_Replace;
with Wide_String_Operations;

package body Wide_UTF_8_Bridge is

   use Wide_UTF_8_Results;

   --  @relation FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010, FUNC-UTF8-011, NFR-UTF8-004
   function From_UTF_8_Wide
     (Source : String) return Wide_UTF_8_Results.UTF_8_Decode_Result
   is
      VR : constant Anystrings_UTF_8_Validate.Validate_Result :=
        Anystrings_UTF_8_Validate.Validate (Source);
   begin
      if not VR.Is_Ok then
         return Make_Error (VR.Error);
      end if;

      --  Source is well-formed UTF-8: decode it with the shared decode path,
      --  which keeps a leading BOM and stores supplementary code points as
      --  UTF-16 surrogate pairs. No library decoder is called (it would strip a
      --  BOM and raise on supplementary code points).
      return Make_Ok
        (Wide_String_Operations.From_Wide_Wide_String
           (Anystrings_UTF_8_Replace.Decode_Replacing (Source)));
   end From_UTF_8_Wide;

end Wide_UTF_8_Bridge;
