-------------------------------------------------------------------------------
--  Anystrings Tests - UTF-8 Get_Value_Or Accessor Test Suite Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test bodies: Get_Value_Or returns decoded value on success and
--  Fallback on failure; callable without a prior Is_Ok guard.

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with String_Types;     use String_Types;

package body UTF8_Get_Value_Or_Test is

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("UTF8 Get_Value_Or Accessor Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine
        (T, (Routine      => Test_Get_Value_Or_Returns_Value_On_Success'Access,
             Routine_Name => AUnit.Format
               ("Get_Value_Or returns decoded value when Is_Ok (R)")));
      Add_Routine
        (T, (Routine      => Test_Get_Value_Or_Returns_Fallback_On_Failure'Access,
             Routine_Name => AUnit.Format
               ("Get_Value_Or returns Fallback unchanged when not Is_Ok (R)")));
      Add_Routine
        (T, (Routine      => Test_Get_Value_Or_Fallback_Value_Is_Preserved_Exactly'Access,
             Routine_Name => AUnit.Format
               ("Get_Value_Or preserves distinct fallback values verbatim")));
      Add_Routine
        (T, (Routine      => Test_Get_Value_Or_Usable_Without_Is_Ok_Guard'Access,
             Routine_Name => AUnit.Format
               ("Get_Value_Or is callable without a prior Is_Ok guard")));
      Add_Routine
        (T, (Routine      => Test_Get_Value_Or_Result_Equals_Get_Value_On_Success'Access,
             Routine_Name => AUnit.Format
               ("Get_Value_Or result equals Get_Value (R) when Is_Ok (R)")));
   end Register_Tests;

   --------------------------------------------------------------------------
   --  Helpers

   --  Well-formed UTF-8: ASCII "Hello"
   ASCII_UTF8 : constant String := "Hello";

   --  Malformed UTF-8: bare continuation byte 0x80 — always yields an error
   Malformed_UTF8 : constant String := (1 => Character'Val (16#80#));

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-002, FUNC-UTF8-014
   procedure Test_Get_Value_Or_Returns_Value_On_Success
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Arrange
      Fallback : constant String_Type         := To_String_Type ("fallback");
      R        : constant UTF_8_Decode_Result := From_UTF_8 (ASCII_UTF8);
   begin
      --  Pre-condition: this result must be a success
      Assert (Is_Ok (R), "Precondition: ASCII input must decode successfully");

      --  Act + Assert
      Assert
        (Get_Value_Or (R, Fallback) = Get_Value (R),
         "Get_Value_Or shall return the decoded value when Is_Ok (R)");
   end Test_Get_Value_Or_Returns_Value_On_Success;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-014
   procedure Test_Get_Value_Or_Returns_Fallback_On_Failure
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Arrange
      Fallback : constant String_Type         := To_String_Type ("default");
      R        : constant UTF_8_Decode_Result := From_UTF_8 (Malformed_UTF8);
   begin
      --  Pre-condition: the malformed input must yield a failure result
      Assert (not Is_Ok (R),
              "Precondition: malformed input must not decode successfully");

      --  Act + Assert
      Assert
        (Get_Value_Or (R, Fallback) = Fallback,
         "Get_Value_Or shall return Fallback unchanged when not Is_Ok (R)");
   end Test_Get_Value_Or_Returns_Fallback_On_Failure;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-014
   procedure Test_Get_Value_Or_Fallback_Value_Is_Preserved_Exactly
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Arrange: two different fallback values — both must come back intact
      Fallback_A : constant String_Type         := To_String_Type ("alpha");
      Fallback_B : constant String_Type         := To_String_Type ("beta");
      R          : constant UTF_8_Decode_Result := From_UTF_8 (Malformed_UTF8);
   begin
      Assert (not Is_Ok (R),
              "Precondition: malformed input must yield a failure result");

      --  Act + Assert
      Assert
        (Get_Value_Or (R, Fallback_A) = Fallback_A,
         "Get_Value_Or shall preserve fallback value 'alpha' exactly");
      Assert
        (Get_Value_Or (R, Fallback_B) = Fallback_B,
         "Get_Value_Or shall preserve fallback value 'beta' exactly");
      Assert
        (Get_Value_Or (R, Fallback_A) /= Get_Value_Or (R, Fallback_B),
         "Get_Value_Or shall return the specific Fallback that was passed in");
   end Test_Get_Value_Or_Fallback_Value_Is_Preserved_Exactly;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-014
   procedure Test_Get_Value_Or_Usable_Without_Is_Ok_Guard
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Arrange: one success result and one failure result
      Fallback   : constant String_Type         := To_String_Type ("none");
      R_Ok       : constant UTF_8_Decode_Result := From_UTF_8 (ASCII_UTF8);
      R_Err      : constant UTF_8_Decode_Result := From_UTF_8 (Malformed_UTF8);
      --  Act: call Get_Value_Or on both results in an unconditional expression,
      --  without any surrounding Is_Ok guard — this is the "guard-free" idiom.
      Result_Ok  : constant String_Type := Get_Value_Or (R_Ok, Fallback);
      Result_Err : constant String_Type := Get_Value_Or (R_Err, Fallback);
   begin
      --  Assert: no exception was raised, and outcomes are the expected ones
      Assert (Is_Ok (R_Ok),
              "Precondition: success input must decode successfully");
      Assert (not Is_Ok (R_Err),
              "Precondition: malformed input must yield a failure result");
      Assert (Result_Ok = Get_Value (R_Ok),
              "Get_Value_Or on a success result shall equal Get_Value (R_Ok)");
      Assert (Result_Err = Fallback,
              "Get_Value_Or on a failure result shall not raise and shall "
              & "equal Fallback");
   end Test_Get_Value_Or_Usable_Without_Is_Ok_Guard;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-002, FUNC-UTF8-014
   procedure Test_Get_Value_Or_Result_Equals_Get_Value_On_Success
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Arrange: a well-formed multi-byte UTF-8 sequence (U+00E9, é)
      E_Acute_UTF8 : constant String :=
        Character'Val (16#C3#) & Character'Val (16#A9#);
      Fallback     : constant String_Type         := To_String_Type ("");
      R            : constant UTF_8_Decode_Result := From_UTF_8 (E_Acute_UTF8);
   begin
      Assert (Is_Ok (R),
              "Precondition: well-formed 2-byte UTF-8 must decode successfully");

      --  The Post contract on Get_Value_Or states:
      --    if Is_Ok (R) then Get_Value_Or'Result = Get_Value (R)
      Assert
        (Get_Value_Or (R, Fallback) = Get_Value (R),
         "Get_Value_Or result shall equal Get_Value (R) for a success result");
   end Test_Get_Value_Or_Result_Equals_Get_Value_On_Success;

end UTF8_Get_Value_Or_Test;
