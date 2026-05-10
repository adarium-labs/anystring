-------------------------------------------------------------------------------
--  Anystrings Tests - UTF-8 Error Mapping Test Suite Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test bodies: canonical invalid UTF-8 → correct UTF_8_Decode_Error.

with AUnit.Assertions;  use AUnit.Assertions;
with AUnit.Test_Cases;  use AUnit.Test_Cases;
with String_Types;      use String_Types;

package body UTF8_Error_Mapping_Test is

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("UTF8 Error Mapping Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is

   begin
      Add_Routine
        (T, (Routine      => Test_Bare_Continuation_Byte_Is_Invalid_Lead_Byte'Access,
             Routine_Name => AUnit.Format ("0x80 alone maps to Invalid_Lead_Byte")));
      Add_Routine
        (T, (Routine      => Test_Lone_Lead_Byte_Is_Truncated_Sequence'Access,
             Routine_Name => AUnit.Format ("0xC3 alone maps to Truncated_Sequence")));
      Add_Routine
        (T, (Routine      => Test_Lead_Plus_ASCII_Is_Invalid_Continuation'Access,
             Routine_Name => AUnit.Format ("0xC3 0x28 maps to Invalid_Continuation")));
      Add_Routine
        (T, (Routine      => Test_Overlong_Sequence_Is_Overlong_Encoding'Access,
             Routine_Name => AUnit.Format ("0xC0 0xAF maps to Overlong_Encoding")));
      Add_Routine
        (T, (Routine      => Test_Surrogate_UTF8_Is_Surrogate_Code_Point'Access,
             Routine_Name => AUnit.Format ("0xED 0xA0 0x80 (U+D800) maps to Surrogate_Code_Point")));
      Add_Routine
        (T, (Routine      => Test_Beyond_Unicode_Is_Code_Point_Out_Of_Range'Access,
             Routine_Name => AUnit.Format ("0xF4 0x90 0x80 0x80 (U+110000) maps to Code_Point_Out_Of_Range")));
   end Register_Tests;

   --------------------------------------------------------------------------
   --  Helper: assert that an input byte sequence is rejected with the
   --  expected error variant.
   procedure Assert_Error
     (Input    : String;
      Expected : UTF_8_Decode_Error;
      Label    : String)
   is
      Result : constant UTF_8_Decode_Result := From_UTF_8 (Input);
   begin
      Assert (not Is_Ok (Result),
              Label & ": From_UTF_8 shall return Is_Ok = False");
      Assert (Get_Error (Result) = Expected,
              Label & ": From_UTF_8 shall return " & Expected'Image);
   end Assert_Error;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-010
   procedure Test_Bare_Continuation_Byte_Is_Invalid_Lead_Byte
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  A bare continuation byte (0x80) at the start of a sequence
      Input : constant String := (1 => Character'Val (16#80#));
   begin
      Assert_Error (Input, Invalid_Lead_Byte,
                    "Bare continuation byte 0x80");
   end Test_Bare_Continuation_Byte_Is_Invalid_Lead_Byte;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-010
   procedure Test_Lone_Lead_Byte_Is_Truncated_Sequence
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  0xC3 is a two-byte lead byte; alone it is truncated
      Input : constant String := (1 => Character'Val (16#C3#));
   begin
      Assert_Error (Input, Truncated_Sequence,
                    "Lone 2-byte lead byte 0xC3");
   end Test_Lone_Lead_Byte_Is_Truncated_Sequence;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-010
   procedure Test_Lead_Plus_ASCII_Is_Invalid_Continuation
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  0xC3 followed by 0x28 '(' — not a valid continuation byte
      Input : constant String :=
        Character'Val (16#C3#) & Character'Val (16#28#);
   begin
      Assert_Error (Input, Invalid_Continuation,
                    "Lead byte 0xC3 followed by ASCII 0x28");
   end Test_Lead_Plus_ASCII_Is_Invalid_Continuation;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-010
   procedure Test_Overlong_Sequence_Is_Overlong_Encoding
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  0xC0 0xAF — overlong encoding of U+002F '/'
      Input : constant String :=
        Character'Val (16#C0#) & Character'Val (16#AF#);
   begin
      Assert_Error (Input, Overlong_Encoding,
                    "Overlong 2-byte sequence 0xC0 0xAF encoding U+002F");
   end Test_Overlong_Sequence_Is_Overlong_Encoding;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-010
   procedure Test_Surrogate_UTF8_Is_Surrogate_Code_Point
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  0xED 0xA0 0x80 — UTF-8 encoding of U+D800 (high surrogate)
      Input : constant String :=
        Character'Val (16#ED#) & Character'Val (16#A0#) & Character'Val (16#80#);
   begin
      Assert_Error (Input, Surrogate_Code_Point,
                    "UTF-8 encoded U+D800 (0xED 0xA0 0x80)");
   end Test_Surrogate_UTF8_Is_Surrogate_Code_Point;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-010
   procedure Test_Beyond_Unicode_Is_Code_Point_Out_Of_Range
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  0xF4 0x90 0x80 0x80 — encodes U+110000 (one beyond U+10FFFF)
      Input : constant String :=
        Character'Val (16#F4#) & Character'Val (16#90#)
        & Character'Val (16#80#) & Character'Val (16#80#);
   begin
      Assert_Error (Input, Code_Point_Out_Of_Range,
                    "4-byte sequence for U+110000 (0xF4 0x90 0x80 0x80)");
   end Test_Beyond_Unicode_Is_Code_Point_Out_Of_Range;

end UTF8_Error_Mapping_Test;
