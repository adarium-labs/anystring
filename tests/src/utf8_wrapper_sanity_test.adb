-------------------------------------------------------------------------------
--  Anystrings Tests - UTF-8 Wrapper Sanity Test Suite Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test bodies: As_UTF_8, Decode_UTF_8, UTF_8_Is_Valid consistency.

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with String_Types;     use String_Types;

package body UTF8_Wrapper_Sanity_Test is

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("UTF8 Wrapper Sanity Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is

   begin
      Add_Routine
        (T, (Routine      => Test_As_UTF8_Equals_To_UTF8_On_ASCII'Access,
             Routine_Name => AUnit.Format ("As_UTF_8 (S) = To_UTF_8 (S) for ASCII input")));
      Add_Routine
        (T, (Routine      => Test_As_UTF8_Equals_To_UTF8_On_Latin1_Supplement'Access,
             Routine_Name => AUnit.Format ("As_UTF_8 (S) = To_UTF_8 (S) for Latin-1 supplement input")));
      Add_Routine
        (T, (Routine      => Test_Decode_UTF8_Is_Ok_Consistent_With_From_UTF8'Access,
             Routine_Name => AUnit.Format ("Decode_UTF_8 and From_UTF_8 agree on Is_Ok for well-formed input")));
      Add_Routine
        (T, (Routine      => Test_Decode_UTF8_Error_Consistent_With_From_UTF8'Access,
             Routine_Name => AUnit.Format ("Decode_UTF_8 and From_UTF_8 agree on Is_Ok for malformed input")));
      Add_Routine
        (T, (Routine      => Test_UTF8_Is_Valid_True_For_Well_Formed_Input'Access,
             Routine_Name => AUnit.Format ("UTF_8_Is_Valid returns True for valid UTF-8")));
      Add_Routine
        (T, (Routine      => Test_UTF8_Is_Valid_False_For_Malformed_Input'Access,
             Routine_Name => AUnit.Format ("UTF_8_Is_Valid returns False for invalid UTF-8")));
   end Register_Tests;

   --------------------------------------------------------------------------
   --  @relation NFR-UTF8-002
   procedure Test_As_UTF8_Equals_To_UTF8_On_ASCII
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Source : constant String_Type := To_String_Type (String'("Test ASCII 123"));
   begin
      Assert (As_UTF_8 (Source) = To_UTF_8 (Source),
              "As_UTF_8 (S) shall equal To_UTF_8 (S) for ASCII input");
   end Test_As_UTF8_Equals_To_UTF8_On_ASCII;

   --------------------------------------------------------------------------
   --  @relation NFR-UTF8-002
   procedure Test_As_UTF8_Equals_To_UTF8_On_Latin1_Supplement
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Build U+00E9 via To_String_Type on its Latin-1 byte
      E_Acute : constant String (1 .. 1) := (1 => Character'Val (16#E9#));
      Source  : constant String_Type     := To_String_Type (E_Acute);
   begin
      Assert (As_UTF_8 (Source) = To_UTF_8 (Source),
              "As_UTF_8 (S) shall equal To_UTF_8 (S) for Latin-1 supplement input");
   end Test_As_UTF8_Equals_To_UTF8_On_Latin1_Supplement;

   --------------------------------------------------------------------------
   --  @relation NFR-UTF8-002
   procedure Test_Decode_UTF8_Is_Ok_Consistent_With_From_UTF8
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Well-formed: ASCII "Hello"
      Input    : constant String             := "Hello";
      Via_From : constant UTF_8_Decode_Result := From_UTF_8 (Input);
      Via_Dec  : constant UTF_8_Decode_Result := Decode_UTF_8 (Input);
   begin
      Assert (Is_Ok (Via_From) = Is_Ok (Via_Dec),
              "Decode_UTF_8 and From_UTF_8 shall have the same Is_Ok "
              & "for well-formed UTF-8 input");
      if Is_Ok (Via_From) and Is_Ok (Via_Dec) then
         Assert (Get_Value (Via_From) = Get_Value (Via_Dec),
                 "Decode_UTF_8 and From_UTF_8 shall yield equal values "
                 & "for well-formed UTF-8 input");
      end if;
   end Test_Decode_UTF8_Is_Ok_Consistent_With_From_UTF8;

   --------------------------------------------------------------------------
   --  @relation NFR-UTF8-002
   procedure Test_Decode_UTF8_Error_Consistent_With_From_UTF8
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Malformed: bare continuation byte 0x80
      Input    : constant String              := (1 => Character'Val (16#80#));
      Via_From : constant UTF_8_Decode_Result := From_UTF_8 (Input);
      Via_Dec  : constant UTF_8_Decode_Result := Decode_UTF_8 (Input);
   begin
      Assert (Is_Ok (Via_From) = Is_Ok (Via_Dec),
              "Decode_UTF_8 and From_UTF_8 shall have the same Is_Ok "
              & "for malformed UTF-8 input");
      if not Is_Ok (Via_From) and not Is_Ok (Via_Dec) then
         Assert (Get_Error (Via_From) = Get_Error (Via_Dec),
                 "Decode_UTF_8 and From_UTF_8 shall yield the same error "
                 & "for malformed UTF-8 input");
      end if;
   end Test_Decode_UTF8_Error_Consistent_With_From_UTF8;

   --------------------------------------------------------------------------
   --  @relation NFR-UTF8-002
   procedure Test_UTF8_Is_Valid_True_For_Well_Formed_Input
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Sampled well-formed inputs
      ASCII_Input : constant String := "Hello, World!";
      E_Acute_UTF8 : constant String :=
        Character'Val (16#C3#) & Character'Val (16#A9#);
      Empty_Input  : constant String := "";
   begin
      Assert (UTF_8_Is_Valid (ASCII_Input),
              "UTF_8_Is_Valid shall return True for ASCII input");
      Assert (UTF_8_Is_Valid (E_Acute_UTF8),
              "UTF_8_Is_Valid shall return True for 2-byte UTF-8 U+00E9");
      Assert (UTF_8_Is_Valid (Empty_Input),
              "UTF_8_Is_Valid shall return True for empty input");
   end Test_UTF8_Is_Valid_True_For_Well_Formed_Input;

   --------------------------------------------------------------------------
   --  @relation NFR-UTF8-002
   procedure Test_UTF8_Is_Valid_False_For_Malformed_Input
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Sampled malformed inputs
      Bare_Cont  : constant String := (1 => Character'Val (16#80#));
      Lone_Lead  : constant String := (1 => Character'Val (16#C3#));
      Overlong   : constant String :=
        Character'Val (16#C0#) & Character'Val (16#AF#);
   begin
      Assert (not UTF_8_Is_Valid (Bare_Cont),
              "UTF_8_Is_Valid shall return False for bare continuation byte");
      Assert (not UTF_8_Is_Valid (Lone_Lead),
              "UTF_8_Is_Valid shall return False for lone lead byte");
      Assert (not UTF_8_Is_Valid (Overlong),
              "UTF_8_Is_Valid shall return False for overlong encoding");
   end Test_UTF8_Is_Valid_False_For_Malformed_Input;

end UTF8_Wrapper_Sanity_Test;
