-------------------------------------------------------------------------------
--  Anystrings Tests - UTF-8 Latin-1 Supplement Test Suite Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test bodies: Latin-1 supplement encodes to two-byte UTF-8 sequences.

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with String_Types;     use String_Types;

package body UTF8_Latin1_Supplement_Test is

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("UTF8 Latin-1 Supplement Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is

   begin
      Add_Routine
        (T, (Routine      => Test_E_Acute_Encodes_To_Two_UTF8_Bytes'Access,
             Routine_Name => AUnit.Format ("To_UTF_8 of U+00E9 (e-acute) produces 2-byte sequence")));
      Add_Routine
        (T, (Routine      => Test_E_Acute_UTF8_Bytes_Are_C3_A9'Access,
             Routine_Name => AUnit.Format ("To_UTF_8 of U+00E9 produces bytes 0xC3 0xA9")));
      Add_Routine
        (T, (Routine      => Test_Latin1_Supplement_UTF8_Distinct_From_Latin1'Access,
             Routine_Name => AUnit.Format ("To_UTF_8 of U+00E9 differs from To_Latin_1 of same value")));
      Add_Routine
        (T, (Routine      => Test_Multiple_Latin1_Supplement_Chars_Expand'Access,
             Routine_Name => AUnit.Format ("Multiple Latin-1 supplement chars expand to 2 bytes each in UTF-8")));
   end Register_Tests;

   --------------------------------------------------------------------------
   --  Helper: build String_Type containing the Unicode code point Pos
   --  (0..255) by encoding Pos as UTF-8 and ingesting it via From_UTF_8.
   --  Backend-agnostic: works identically on standard (UTF-8 storage per
   --  FUNC-CONV-001), wide_string, wide_wide_string, uxstring, vss.
   function Latin1_Char (Pos : Natural) return String_Type is
      UTF8 : String (1 .. 2);
      Len  : Natural;
      R    : UTF_8_Decode_Result;
   begin
      if Pos <= 16#7F# then
         UTF8 (1) := Character'Val (Pos);
         Len := 1;
      else
         UTF8 (1) := Character'Val (16#C0# + Pos / 64);
         UTF8 (2) := Character'Val (16#80# + (Pos mod 64));
         Len := 2;
      end if;
      R := From_UTF_8 (UTF8 (1 .. Len));
      return Get_Value (R);
   end Latin1_Char;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-003
   procedure Test_E_Acute_Encodes_To_Two_UTF8_Bytes
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Arrange: U+00E9 LATIN SMALL LETTER E WITH ACUTE
      Source     : constant String_Type := Latin1_Char (16#E9#);
      --  Act
      Utf8_Bytes : constant String      := To_UTF_8 (Source);
   begin
      --  Assert: one code point in Latin-1 supplement expands to 2 UTF-8 bytes
      Assert (Utf8_Bytes'Length = 2,
              "To_UTF_8 of U+00E9 shall produce exactly 2 bytes");
   end Test_E_Acute_Encodes_To_Two_UTF8_Bytes;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-003
   procedure Test_E_Acute_UTF8_Bytes_Are_C3_A9
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Arrange
      Source     : constant String_Type := Latin1_Char (16#E9#);
      --  Expected UTF-8 encoding of U+00E9: 0xC3 0xA9
      Expected   : constant String :=
        Character'Val (16#C3#) & Character'Val (16#A9#);
      --  Act
      Utf8_Bytes : constant String := To_UTF_8 (Source);
   begin
      --  Assert byte values
      Assert (Utf8_Bytes = Expected,
              "To_UTF_8 of U+00E9 shall yield bytes 0xC3 0xA9");
   end Test_E_Acute_UTF8_Bytes_Are_C3_A9;

   --------------------------------------------------------------------------
   --  @relation NFR-UTF8-010
   procedure Test_Latin1_Supplement_UTF8_Distinct_From_Latin1
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Arrange: U+00E9
      Source     : constant String_Type := Latin1_Char (16#E9#);
      --  Act
      Utf8_Bytes  : constant String := To_UTF_8 (Source);
      Latin1_Bytes : constant String := To_Latin_1 (Source);
   begin
      --  Assert: UTF-8 encoding of U+00E9 is 2 bytes; Latin-1 is 1 byte —
      --  they must differ (NFR-UTF8-010: no conflation of the two boundaries)
      Assert (Utf8_Bytes /= Latin1_Bytes,
              "To_UTF_8 and To_Latin_1 of U+00E9 must return different Strings");
   end Test_Latin1_Supplement_UTF8_Distinct_From_Latin1;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-003
   procedure Test_Multiple_Latin1_Supplement_Chars_Expand
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Arrange: "éàü" — three code points in U+0080..U+00FF
      --  Each expands to 2 UTF-8 bytes, so total UTF-8 length = 6
      E_Acute : constant String_Type := Latin1_Char (16#E9#); --  U+00E9
      A_Grave : constant String_Type := Latin1_Char (16#E0#); --  U+00E0
      U_Umlaut : constant String_Type := Latin1_Char (16#FC#); --  U+00FC

      Source     : constant String_Type := Concat (Concat (E_Acute, A_Grave), U_Umlaut);
      --  Act
      Utf8_Bytes : constant String      := To_UTF_8 (Source);
   begin
      --  Assert: 3 code points × 2 bytes each = 6 UTF-8 bytes
      Assert (Utf8_Bytes'Length = 6,
              "Three Latin-1 supplement chars shall produce 6 UTF-8 bytes");
   end Test_Multiple_Latin1_Supplement_Chars_Expand;

end UTF8_Latin1_Supplement_Test;
