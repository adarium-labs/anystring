-------------------------------------------------------------------------------
--  Anystrings Tests - Main Test Runner
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test runner for the anystrings UTF-8 boundary API test suite.
--
--  @description
--  Registers all nine UTF-8 test suites and runs them via the AUnit
--  framework. Exits with status code 1 on any test failure so that CI
--  pipelines and the run_all_backends.sh script can detect failures.
--
--  Build and run per backend:
--    cd tests && STRING_TYPE=standard         alr build && alr run
--    cd tests && STRING_TYPE=wide_string      alr build && alr run
--    cd tests && STRING_TYPE=wide_wide_string alr build && alr run
--
--  Requirements Coverage: NFR-UTF8-008 (cross-backend consistency)

with Ada.Text_IO;

with AUnit;
with AUnit.Reporter.Text;
with AUnit.Run;
with AUnit.Test_Suites;

with UTF8_Empty_Input_Test;
with UTF8_ASCII_Fast_Path_Test;
with UTF8_Latin1_Supplement_Test;
with UTF8_Surrogate_Substitution_Test;
with UTF8_Round_Trip_Test;
with UTF8_Error_Mapping_Test;
with UTF8_Non_Raising_Test;
with UTF8_Wrapper_Sanity_Test;
with UTF8_Get_Value_Or_Test;
with Char_Classification_Test;
with String_Extension_Test;

procedure Anystrings_Test_Runner is

   --  Build the top-level suite by adding each sub-suite's test case.
   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      S : constant AUnit.Test_Suites.Access_Test_Suite :=
        AUnit.Test_Suites.New_Suite;
   begin
      S.Add_Test (new UTF8_Empty_Input_Test.Test_Case);
      S.Add_Test (new UTF8_ASCII_Fast_Path_Test.Test_Case);
      S.Add_Test (new UTF8_Latin1_Supplement_Test.Test_Case);
      S.Add_Test (new UTF8_Surrogate_Substitution_Test.Test_Case);
      S.Add_Test (new UTF8_Round_Trip_Test.Test_Case);
      S.Add_Test (new UTF8_Error_Mapping_Test.Test_Case);
      S.Add_Test (new UTF8_Non_Raising_Test.Test_Case);
      S.Add_Test (new UTF8_Wrapper_Sanity_Test.Test_Case);
      S.Add_Test (new UTF8_Get_Value_Or_Test.Test_Case);
      S.Add_Test (new Char_Classification_Test.Test_Case);
      S.Add_Test (new String_Extension_Test.Test_Case);
      return S;
   end Suite;

   function Run is new AUnit.Run.Test_Runner_With_Status (Suite);

   Reporter    : AUnit.Reporter.Text.Text_Reporter;
   Status      : AUnit.Status;
   All_Passed  : Boolean;

begin
   Ada.Text_IO.Put_Line ("Anystrings UTF-8 Test Suite");
   Ada.Text_IO.Put_Line ("Backend: STRING_TYPE (selected at build time)");
   Ada.Text_IO.New_Line;

   Status     := Run (Reporter);
   All_Passed := AUnit."=" (Status, AUnit.Success);

   Ada.Text_IO.New_Line;
   if All_Passed then
      Ada.Text_IO.Put_Line ("RESULT: PASS");
   else
      Ada.Text_IO.Put_Line ("RESULT: FAIL");
   end if;

   if not All_Passed then
      raise Program_Error with "Test suite failed";
   end if;
end Anystrings_Test_Runner;
