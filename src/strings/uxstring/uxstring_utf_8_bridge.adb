-------------------------------------------------------------------------------
--  UXString_UTF_8_Bridge - From_UTF_8 body for the uxstring backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Strings.Unbounded;
with Anystrings_UTF_8_Validate;
with Anystrings_UTF_8;
with UXStrings;

package body UXString_UTF_8_Bridge is

   use UXString_UTF_8_Results;
   use Anystrings_UTF_8;

   --  Build a UXString from validated UTF-8 bytes using the same internal
   --  storage convention as UXString_Operations.To_UXString (= From_UTF_8):
   --    * Code points U+0000..U+00FF are stored as a single Latin-1 byte so
   --      that UXString equality (byte-level in UXS1) agrees with the result
   --      of To_String_Type on the same Latin-1 source bytes.
   --    * Code points U+0100..U+10FFFF are stored as their UTF-8 byte sequence
   --      which matches what UXStrings.From_UTF_8 would store.
   --  This ensures From_UTF_8 (To_UTF_8 (S)) = S for any S.
   function Build_UXString_From_Valid_UTF_8
     (Source : String) return UXStrings.UXString
   is
      use Ada.Strings.Unbounded;

      Buf  : Unbounded_String;
      I    : Positive;
      Lead : Natural;
      CP   : Natural;
   begin
      if Source'Length = 0 then
         return UXStrings.Null_UXString;
      end if;

      I := Source'First;
      while I <= Source'Last loop
         Lead := Character'Pos (Source (I));

         if Lead <= 16#7F# then
            --  ASCII (U+0000..U+007F): single byte; same in Latin-1 and UTF-8.
            Append (Buf, Source (I));
            I := I + 1;

         elsif Lead in 16#C2# .. 16#DF# then
            --  2-byte sequence (U+0080..U+07FF).
            --  Source was already validated, so the continuation byte is present.
            CP := (Lead mod 32) * 64 + (Character'Pos (Source (I + 1)) mod 64);
            if CP <= 16#FF# then
               --  U+0080..U+00FF: store as one Latin-1 byte.
               Append (Buf, Character'Val (CP));
            else
               --  U+0100..U+07FF: store as UTF-8 bytes.
               Append (Buf, Source (I .. I + 1));
            end if;
            I := I + 2;

         elsif Lead in 16#E0# .. 16#EF# then
            --  3-byte sequence (U+0800..U+FFFF). Code point > U+00FF; store as UTF-8.
            Append (Buf, Source (I .. I + 2));
            I := I + 3;

         else
            --  4-byte sequence (U+10000..U+10FFFF). Store as UTF-8.
            Append (Buf, Source (I .. I + 3));
            I := I + 4;
         end if;
      end loop;

      return UXStrings.From_UTF_8
        (UXStrings.UTF_8_Character_Array (To_String (Buf)));
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
