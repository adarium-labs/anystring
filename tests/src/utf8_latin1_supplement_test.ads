-------------------------------------------------------------------------------
--  Anystrings Tests - UTF-8 Latin-1 Supplement Test Suite Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test suite: UTF-8 encoding of Latin-1 supplement code points.
--
--  @description
--  Verifies that To_UTF_8 encodes code points in the Latin-1 supplement
--  range (U+0080..U+00FF) as proper two-byte UTF-8 sequences, and that
--  the result is distinct from To_Latin_1 output for those code points.
--  Covers FUNC-UTF8-003 (To_UTF_8 total correctness) and NFR-UTF8-010
--  (non-conflation with To_Latin_1).
--
--  Note on NFR-UTF8-010 distinctness: the assertion that
--    To_UTF_8 (S) /= To_Latin_1 (S)
--  is meaningful for the standard backend (where To_Latin_1 returns a
--  single byte per Latin-1 code point and To_UTF_8 returns two bytes for
--  code points U+0080..U+00FF). On wide/wide_wide/uxstring backends the
--  assertion still holds because the UTF-8 encoding of e.g. U+00E9 ("é")
--  is two bytes while the Latin-1 encoding is one byte, regardless of the
--  backend's internal character type.
--
--  Requirements Coverage: FUNC-UTF8-003, NFR-UTF8-010
--
--  External Effects: None
--  Thread Safety: N/A
--  SPARK Status: Not Applicable (test code)

with AUnit.Test_Cases;

--  @relation FUNC-UTF8-003, NFR-UTF8-010
package UTF8_Latin1_Supplement_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   --  @relation FUNC-UTF8-003
   procedure Test_E_Acute_Encodes_To_Two_UTF8_Bytes
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-003
   procedure Test_E_Acute_UTF8_Bytes_Are_C3_A9
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation NFR-UTF8-010
   procedure Test_Latin1_Supplement_UTF8_Distinct_From_Latin1
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-003
   procedure Test_Multiple_Latin1_Supplement_Chars_Expand
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end UTF8_Latin1_Supplement_Test;
