-------------------------------------------------------------------------------
--  Anystrings Tests - UTF-8 ASCII Fast-Path Test Suite Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test suite: UTF-8 ASCII fast-path correctness.
--
--  @description
--  Verifies that To_UTF_8 on pure-ASCII String_Type values returns the
--  byte-for-byte ASCII representation (single-byte UTF-8 sequences only),
--  as required by FUNC-UTF8-005.
--
--  Requirements Coverage: FUNC-UTF8-005, NFR-UTF8-008
--
--  External Effects: None
--  Thread Safety: N/A
--  SPARK Status: Not Applicable (test code)

with AUnit.Test_Cases;

--  @relation FUNC-UTF8-005
package UTF8_ASCII_Fast_Path_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   --  @relation FUNC-UTF8-005
   procedure Test_ASCII_String_Is_Unchanged_After_To_UTF8
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-005
   procedure Test_ASCII_Printable_Range_Round_Trip
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-005
   procedure Test_ASCII_Single_Char_Encoding
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end UTF8_ASCII_Fast_Path_Test;
