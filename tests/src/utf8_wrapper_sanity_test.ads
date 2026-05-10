-------------------------------------------------------------------------------
--  Anystrings Tests - UTF-8 Wrapper Sanity Test Suite Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test suite: As_UTF_8, Decode_UTF_8, UTF_8_Is_Valid consistency.
--
--  @description
--  Verifies that the wrapper expression functions declared in Anystrings
--  (and re-exported by String_Types) are consistent with the underlying
--  formal subprograms To_UTF_8 and From_UTF_8:
--
--    As_UTF_8 (S) = To_UTF_8 (S)           for sampled S
--    Decode_UTF_8 (B) ~ From_UTF_8 (B)     (same Is_Ok and value/error)
--    UTF_8_Is_Valid (B) = Is_Ok (From_UTF_8 (B))
--
--  The test exercises both well-formed and malformed inputs so that all
--  three functions' True and False branches are covered.
--
--  Requirements Coverage: NFR-UTF8-002
--
--  External Effects: None
--  Thread Safety: N/A
--  SPARK Status: Not Applicable (test code)

with AUnit.Test_Cases;

--  @relation NFR-UTF8-002
package UTF8_Wrapper_Sanity_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   --  @relation NFR-UTF8-002
   procedure Test_As_UTF8_Equals_To_UTF8_On_ASCII
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation NFR-UTF8-002
   procedure Test_As_UTF8_Equals_To_UTF8_On_Latin1_Supplement
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation NFR-UTF8-002
   procedure Test_Decode_UTF8_Is_Ok_Consistent_With_From_UTF8
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation NFR-UTF8-002
   procedure Test_Decode_UTF8_Error_Consistent_With_From_UTF8
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation NFR-UTF8-002
   procedure Test_UTF8_Is_Valid_True_For_Well_Formed_Input
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation NFR-UTF8-002
   procedure Test_UTF8_Is_Valid_False_For_Malformed_Input
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end UTF8_Wrapper_Sanity_Test;
