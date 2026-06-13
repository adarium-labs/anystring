--  Width_Tests_Registry — Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
--
--  @summary
--  Bridge: conditionally adds all five width test suites to the runner.
--
--  @description
--  Always compiled.  The body resolves to one of two implementations
--  selected by ANYSTRING_WITH_WIDTH in anystrings_tests.gpr:
--    src_width/width_tests_registry.adb      (WITH_WIDTH=true)
--    src_width_stub/width_tests_registry.adb  (WITH_WIDTH=false)
--
--  SPARK Status: Not Applicable (test infrastructure).

with AUnit.Test_Suites;

package Width_Tests_Registry is

   procedure Add_To_Suite (S : AUnit.Test_Suites.Access_Test_Suite);

end Width_Tests_Registry;
