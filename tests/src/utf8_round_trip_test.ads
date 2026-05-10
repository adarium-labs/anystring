-------------------------------------------------------------------------------
--  Anystrings Tests - UTF-8 Round-Trip Test Suite Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test suite: From_UTF_8 (To_UTF_8 (S)) = S for surrogate-free S.
--
--  @description
--  Verifies the forward round-trip invariant (FUNC-UTF8-011): for every
--  surrogate-free String_Type value S representable by the backend,
--    let R := From_UTF_8 (To_UTF_8 (S))
--    Is_Ok (R) = True
--    Get_Value (R) = S
--
--  Covers: empty string, ASCII, Latin-1 supplement, Greek BMP, CJK BMP.
--  For backends that support code points > U+FFFF (wide_wide_string and
--  uxstring), supplementary-plane code points (e.g. U+1F600 GRINNING FACE)
--  are also tested. On backends where Character_Type cannot represent
--  U+1F600 (standard: Character 0..255; wide_string: Wide_Character
--  0..U+FFFF), that sub-test is skipped with an explanatory message using
--  the same runtime-probe approach as the surrogate-substitution suite.
--
--  Requirements Coverage: FUNC-UTF8-011, NFR-UTF8-008
--
--  External Effects: None
--  Thread Safety: N/A
--  SPARK Status: Not Applicable (test code)

with AUnit.Test_Cases;

--  @relation FUNC-UTF8-011
package UTF8_Round_Trip_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   --  @relation FUNC-UTF8-011
   procedure Test_Round_Trip_Empty_String
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-011
   procedure Test_Round_Trip_ASCII_Hello
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-011
   procedure Test_Round_Trip_Latin1_Supplement
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-011
   procedure Test_Round_Trip_Greek_BMP
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-011
   procedure Test_Round_Trip_CJK_BMP
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-011
   procedure Test_Round_Trip_Supplementary_Plane_If_Supported
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end UTF8_Round_Trip_Test;
