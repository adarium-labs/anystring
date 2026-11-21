-------------------------------------------------------------------------------
--  Anystrings Tests - Case Mapping (To_Lower / To_Upper) Test Suite Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test suite: To_Lower and To_Upper on UTF-8 storage (standard) and on
--  code-point storage (the other backends).
--
--  @description
--  Expectations are written in code points and asserted on every backend: the
--  full Unicode case mapping (generated UCD tables) gives the same result on
--  standard, wide_string, wide_wide_string, uxstring and vss.
--    - Byte_Counting: standard, where a String_Type is UTF-8 bytes. Byte-level
--      checks (valid UTF-8 result, ill-formed bytes kept, Char_To_Lower /
--      Char_To_Upper on bytes) run only there.

with AUnit.Test_Cases;

package Case_Mapping_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private
   procedure Test_ASCII_Unchanged_By_Case_Mapping
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   procedure Test_Shared_Expectations
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   procedure Test_Round_Trip
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   procedure Test_Final_Sigma
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   procedure Test_Standard_Valid_UTF_8_Bytes
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   procedure Test_Standard_Ill_Formed_Bytes_Kept
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   procedure Test_Standard_Overlong_And_Out_Of_Range_Kept
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   procedure Test_Length_Contract
     (T : in out AUnit.Test_Cases.Test_Case'Class);
   procedure Test_Standard_Char_Mapping_ASCII_Only
     (T : in out AUnit.Test_Cases.Test_Case'Class);
end Case_Mapping_Test;
