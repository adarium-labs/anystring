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
--  Expectations are written in code points, so they run on every backend.
--  Two backend classes need care:
--    - Maps_Non_ASCII: backends whose To_Lower / To_Upper map non-ASCII letters
--      (standard, vss, uxstring). On wide_string and wide_wide_string the case
--      mapping is ASCII-only today; those cases then pin the unchanged result.
--    - Full_Case_Mapping: standard and vss (U+0130 gives two code points).
--      uxstring maps per code point with the GNAT tables and the wide backends
--      are ASCII-only; the full-mapping cases are not asserted on those.
--    - Byte_Counting: standard, where a String_Type is UTF-8 bytes. Byte-level
--      checks (valid UTF-8 result, ill-formed bytes kept) run only there.

with AUnit.Test_Cases;

package Case_Mapping_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   procedure Test_ASCII_Unchanged_By_Case_Mapping
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Latin_1_Letter_Mapping
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Round_Trip
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Full_Mapping_Changes_Length
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Final_Sigma
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Standard_Valid_UTF_8_Bytes
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Standard_Ill_Formed_Bytes_Kept
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Standard_Overlong_And_Out_Of_Range_Kept
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end Case_Mapping_Test;
