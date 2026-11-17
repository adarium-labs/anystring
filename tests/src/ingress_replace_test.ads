-------------------------------------------------------------------------------
--  Anystrings Tests - Ingress Replacement Test Suite Spec (KI-046 L1)
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test suite: algorithm R (U+FFFD replacement of maximal ill-formed
--  subparts) on the shared decoder, the ingress vectors through the
--  environment and the checked From_UTF_8, the From-side policy P rows, the
--  environment states, the Code_Point_Length contract, and the property gate.
--
--  @description
--  Runs in-process on every backend. The argv rows are checked by
--  Ingress_Argv_Test, which spawns the probe program.
--
--  SPARK Status: Not Applicable (test code)

with AUnit.Test_Cases;

package Ingress_Replace_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   procedure Test_Table_I_Environment_And_Checked
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Table_II_From_Side
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Table_III_Environment_States
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Storage_And_Code_Point_Length
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Property_Gate
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end Ingress_Replace_Test;
