--  Anystrings Tests - Command-Line Bridge Test Suite Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

--  @summary
--  AUnit test suite: Ada.Command_Line bridge (FUNC-CMDLINE-001..009).
--
--  @description
--  Validates the command-line access API exposed through String_Types.
--  The fixture is backend-agnostic: the same source compiles for all five
--  backends (standard, wide_string, wide_wide_string, uxstring, vss),
--  exercising FUNC-CMDLINE-009 by construction.
--
--  SPARK Status: Not Applicable (test code).

with AUnit.Test_Cases;

package Cmdline_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   --  @relation FUNC-CMDLINE-001
   procedure Test_Argument_Count_Is_Natural
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-CMDLINE-002, FUNC-CMDLINE-008
   procedure Test_Argument_Indexed_Access_Does_Not_Raise
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-CMDLINE-003
   procedure Test_Argument_Out_Of_Range_Raises
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-CMDLINE-003
   procedure Test_Argument_Positive_Last_Raises
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-CMDLINE-004
   procedure Test_Command_Name_Does_Not_Raise
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-CMDLINE-005, FUNC-CMDLINE-006
   procedure Test_Set_Exit_Status_Named_Constant
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-CMDLINE-005, FUNC-CMDLINE-007
   procedure Test_Set_Exit_Status_Integer_Overload
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end Cmdline_Test;
