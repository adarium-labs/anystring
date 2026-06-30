-------------------------------------------------------------------------------
--  Anystrings Tests - UTF-8 Empty-Input Test Suite Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test bodies: UTF-8 operations on empty inputs.

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with String_Types;     use String_Types;

package body UTF8_Empty_Input_Test is

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("UTF8 Empty-Input Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is

   begin
      Add_Routine
        (T, (Routine      => Test_To_UTF8_Empty_Returns_Empty_String'Access,
             Routine_Name => AUnit.Format ("To_UTF_8 on empty String_Type returns empty String")));
      Add_Routine
        (T, (Routine      => Test_From_UTF8_Empty_Returns_Ok_With_Empty_Value'Access,
             Routine_Name => AUnit.Format ("From_UTF_8 on empty String returns Is_Ok = True")));
      Add_Routine
        (T, (Routine      => Test_From_UTF8_Empty_Value_Equals_Null_String'Access,
             Routine_Name => AUnit.Format ("From_UTF_8 on empty String: Get_Value equals Null_String")));
   end Register_Tests;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-004
   procedure Test_To_UTF8_Empty_Returns_Empty_String
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Arrange
      Empty : constant String_Type := To_String_Type (String'(""));
      --  Act
      Result : constant String := To_UTF_8 (Empty);
   begin
      --  Assert
      Assert (Result = "", "To_UTF_8 (empty String_Type) shall return """"");
   end Test_To_UTF8_Empty_Returns_Empty_String;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-009
   procedure Test_From_UTF8_Empty_Returns_Ok_With_Empty_Value
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Act
      Result : constant UTF_8_Decode_Result := From_UTF_8 ("");
   begin
      --  Assert
      Assert (Is_Ok (Result),
              "From_UTF_8 ("""") shall return Is_Ok = True");
   end Test_From_UTF8_Empty_Returns_Ok_With_Empty_Value;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-009
   procedure Test_From_UTF8_Empty_Value_Equals_Null_String
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Arrange
      Empty    : constant String_Type := To_String_Type (String'(""));
      --  Act
      Result   : constant UTF_8_Decode_Result := From_UTF_8 ("");
      Decoded  : constant String_Type := Get_Value (Result);
   begin
      --  Assert
      Assert (Is_Ok (Result),
              "From_UTF_8 ("""") shall return Is_Ok = True before value check");
      Assert (Decoded = Empty,
              "Get_Value of From_UTF_8 ("""") shall equal empty String_Type");
   end Test_From_UTF8_Empty_Value_Equals_Null_String;

end UTF8_Empty_Input_Test;
