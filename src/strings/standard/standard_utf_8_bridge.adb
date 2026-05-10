-------------------------------------------------------------------------------
--  Standard_UTF_8_Bridge - From_UTF_8 body for the standard backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Anystrings_UTF_8_Validate;
with Anystrings_UTF_8;
with Standard_String_Operations;
with Ada.Strings.UTF_Encoding;
with Ada.Strings.UTF_Encoding.Strings;

package body Standard_UTF_8_Bridge is

   use Standard_UTF_8_Results;
   use Anystrings_UTF_8;

   --  @relation FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010, FUNC-UTF8-011, NFR-UTF8-004
   function From_UTF_8_Standard (Source : String) return Standard_UTF_8_Results.UTF_8_Decode_Result is
      VR : constant Anystrings_UTF_8_Validate.Validate_Result := Anystrings_UTF_8_Validate.Validate (Source);
   begin
      if not VR.Is_Ok then
         return Make_Error (VR.Error);
      end if;

      --  Source is well-formed UTF-8. Decode to a Latin-1 String.
      --  Ada.Strings.UTF_Encoding.Strings.Decode raises Encoding_Error for
      --  code points > U+00FF. On this backend To_UTF_8 only emits encodings
      --  of Latin-1 code points (0..255), so Encoding_Error is never raised
      --  on the round-trip domain. For code points > U+00FF we return an
      --  error (Code_Point_Out_Of_Range) rather than substituting '?', so
      --  that callers can distinguish representable from unrepresentable input.
      declare
         Decoded : constant String :=
           Ada.Strings.UTF_Encoding.Strings.Decode (Item => Source, Input_Scheme => Ada.Strings.UTF_Encoding.UTF_8);
      begin
         return Make_Ok (Standard_String_Operations.To_Unbounded_String (Decoded));
      end;
   exception
      when Ada.Strings.UTF_Encoding.Encoding_Error =>
         --  Code points > U+00FF are unrepresentable on this backend.
         return Make_Error (Code_Point_Out_Of_Range);
   end From_UTF_8_Standard;

end Standard_UTF_8_Bridge;
