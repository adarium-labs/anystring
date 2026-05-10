-------------------------------------------------------------------------------
--  Wide_Wide_UTF_8_Bridge - From_UTF_8 body for the wide_wide_string backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Anystrings_UTF_8_Validate;
with Anystrings_UTF_8;
with Ada.Strings.Wide_Wide_Unbounded;
with Ada.Strings.UTF_Encoding;
with Ada.Strings.UTF_Encoding.Wide_Wide_Strings;

package body Wide_Wide_UTF_8_Bridge is

   use Wide_Wide_UTF_8_Results;
   use Anystrings_UTF_8;

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

      --  Source is well-formed UTF-8 with no surrogates and no scalars >
      --  U+10FFFF (the validator already rejects those). Decode directly;
      --  Wide_Wide_Character covers the full Unicode scalar range, so
      --  Encoding_Error should never be raised, but we guard defensively.
      declare
         Decoded : constant Wide_Wide_String :=
           Ada.Strings.UTF_Encoding.Wide_Wide_Strings.Decode
             (Item         => Source,
              Input_Scheme => Ada.Strings.UTF_Encoding.UTF_8);
      begin
         return Make_Ok
           (Ada.Strings.Wide_Wide_Unbounded.To_Unbounded_Wide_Wide_String
              (Decoded));
      end;
   exception
      when Ada.Strings.UTF_Encoding.Encoding_Error =>
         --  Defensive: should not be reached after validator pass.
         return Make_Error (Code_Point_Out_Of_Range);
   end From_UTF_8_Wide_Wide;

end Wide_Wide_UTF_8_Bridge;
