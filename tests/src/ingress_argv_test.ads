-------------------------------------------------------------------------------
--  Anystrings Tests - Ingress Argv Test Suite Spec (KI-046 L1)
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test suite: Table I rows as argv[1] and as argv[0] (Command_Name).
--
--  @description
--  Each row is passed through argv0_exec to the ingress_probe program, which
--  prints the Command_Name and Argument (1) of the facade. The raw bytes reach
--  the program unchanged, so the ingress itself is exercised, not a copy made
--  by the test. The probe and argv0_exec are built next to this test program.
--
--  SPARK Status: Not Applicable (test code)

with AUnit.Test_Cases;

package Ingress_Argv_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   procedure Test_Table_I_Argv_And_Command_Name
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end Ingress_Argv_Test;
