-------------------------------------------------------------------------------
--  Anystrings Tests - UTF-8 ASCII Fast-Path Test Suite Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test bodies: ASCII strings pass through To_UTF_8 unchanged.

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with String_Types;     use String_Types;

package body UTF8_ASCII_Fast_Path_Test is

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("UTF8 ASCII Fast-Path Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is

   begin
      Add_Routine
        (T, (Routine      => Test_ASCII_String_Is_Unchanged_After_To_UTF8'Access,
             Routine_Name => AUnit.Format ("To_UTF_8 on ASCII string returns identical byte sequence")));
      Add_Routine
        (T, (Routine      => Test_ASCII_Printable_Range_Round_Trip'Access,
             Routine_Name => AUnit.Format ("ASCII printable range (U+0020..U+007E) survives round trip")));
      Add_Routine
        (T, (Routine      => Test_ASCII_Single_Char_Encoding'Access,
             Routine_Name => AUnit.Format ("Single ASCII character encodes to single byte")));
   end Register_Tests;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-005
   procedure Test_ASCII_String_Is_Unchanged_After_To_UTF8
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Arrange
      Source     : constant String     := "Hello, World!";
      Source_St  : constant String_Type := To_String_Type (Source);
      --  Act
      Utf8_Bytes : constant String     := To_UTF_8 (Source_St);
   begin
      --  Assert: UTF-8 of ASCII must be byte-for-byte identical
      Assert (Utf8_Bytes = Source,
              "To_UTF_8 on ASCII string shall return the same bytes");
      Assert (Utf8_Bytes'Length = Source'Length,
              "UTF-8 length of ASCII string shall equal original length");
   end Test_ASCII_String_Is_Unchanged_After_To_UTF8;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-005
   procedure Test_ASCII_Printable_Range_Round_Trip
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Arrange: build a string of all printable ASCII characters U+0020..U+007E
      Printable  : String (1 .. 95);
   begin
      for I in Printable'Range loop
         Printable (I) := Character'Val (16#20# + (I - 1));
      end loop;

      declare
         Source_St  : constant String_Type          := To_String_Type (Printable);
         --  Act
         Utf8_Bytes : constant String               := To_UTF_8 (Source_St);
         R          : constant UTF_8_Decode_Result  := From_UTF_8 (Utf8_Bytes);
      begin
         --  Assert round-trip
         Assert (Utf8_Bytes = Printable,
                 "To_UTF_8 on ASCII printable range shall be unchanged");
         Assert (Is_Ok (R),
                 "From_UTF_8 of ASCII UTF-8 bytes shall succeed");
         Assert (Get_Value (R) = Source_St,
                 "Round-trip of ASCII printable range shall reproduce source");
      end;
   end Test_ASCII_Printable_Range_Round_Trip;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-005
   procedure Test_ASCII_Single_Char_Encoding
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Arrange: 'A' = U+0041
      Ch         : constant Character_Type := Character_Type'Val (16#41#);
      Source_St  : constant String_Type    := From_Character (Ch);
      --  Act
      Utf8_Bytes : constant String         := To_UTF_8 (Source_St);
   begin
      --  Assert: single byte, same value
      Assert (Utf8_Bytes'Length = 1,
              "To_UTF_8 of single ASCII char shall produce one byte");
      Assert (Utf8_Bytes (Utf8_Bytes'First) = Character'Val (16#41#),
              "To_UTF_8 of 'A' shall produce byte 0x41");
   end Test_ASCII_Single_Char_Encoding;

end UTF8_ASCII_Fast_Path_Test;
