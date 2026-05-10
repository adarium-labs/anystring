-------------------------------------------------------------------------------
--  Wide_UTF_8_Bridge - From_UTF_8 body for the wide_string backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Anystrings_UTF_8_Validate;
with Anystrings_UTF_8;
with Wide_String_Operations;
with Ada.Strings.Wide_Unbounded;
with Ada.Strings.UTF_Encoding;
with Ada.Strings.UTF_Encoding.Wide_Strings;

package body Wide_UTF_8_Bridge is

   use Wide_UTF_8_Results;
   use Anystrings_UTF_8;

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

      --  Source is well-formed UTF-8. Decode to a Wide_String.
      --  Ada.Strings.UTF_Encoding.Wide_Strings.Decode raises Encoding_Error
      --  for code points > U+FFFF (supplementary plane), which are valid
      --  Unicode scalars but unrepresentable in Wide_Character.
      --  Per the design decision (Q2 resolution in tech-spec §11), we
      --  classify these as Code_Point_Out_Of_Range.
      declare
         Decoded : constant Wide_String :=
           Ada.Strings.UTF_Encoding.Wide_Strings.Decode
             (Item         => Source,
              Input_Scheme => Ada.Strings.UTF_Encoding.UTF_8);
      begin
         return Make_Ok
           (Ada.Strings.Wide_Unbounded.To_Unbounded_Wide_String (Decoded));
      end;
   exception
      when Ada.Strings.UTF_Encoding.Encoding_Error =>
         --  Code points > U+FFFF are unrepresentable in Wide_Character.
         return Make_Error (Code_Point_Out_Of_Range);
   end From_UTF_8_Wide;

end Wide_UTF_8_Bridge;
