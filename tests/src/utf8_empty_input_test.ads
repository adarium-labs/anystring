-------------------------------------------------------------------------------
--  Anystrings Tests - UTF-8 Empty-Input Test Suite Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test suite: UTF-8 operations on empty String_Type / empty String.
--
--  @description
--  Verifies that To_UTF_8 and From_UTF_8 handle empty inputs consistently
--  across all backends, as required by FUNC-UTF8-004 and FUNC-UTF8-009.
--
--  Requirements Coverage: FUNC-UTF8-004, FUNC-UTF8-009, NFR-UTF8-008
--
--  External Effects: None
--  Thread Safety: N/A
--  SPARK Status: Not Applicable (test code)

with AUnit.Test_Cases;

--  @relation FUNC-UTF8-004, FUNC-UTF8-009
package UTF8_Empty_Input_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   --  @relation FUNC-UTF8-004
   procedure Test_To_UTF8_Empty_Returns_Empty_String
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-009
   procedure Test_From_UTF8_Empty_Returns_Ok_With_Empty_Value
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-009
   procedure Test_From_UTF8_Empty_Value_Equals_Null_String
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end UTF8_Empty_Input_Test;
