-------------------------------------------------------------------------------
--  Anystrings Tests - UTF-8 Surrogate Substitution Test Suite Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test suite: surrogate code-unit substitution in To_UTF_8.
--
--  @description
--  Verifies that To_UTF_8 replaces each surrogate code unit (U+D800..U+DFFF)
--  with the UTF-8 encoding of U+FFFD (the three bytes EF BF BD).
--
--  This test class is meaningful only on backends whose Character_Type can
--  hold values in the surrogate range (wide_string, wide_wide_string).
--  On the standard backend (Character 0..255) and the uxstring backend
--  (which forbids surrogates at construction time), surrogate inputs cannot
--  be constructed, so the tests perform a SKIP with an explanatory message.
--
--  Runtime-skip strategy: we probe whether the backend's Character_Type
--  can represent Wide_Character'Val (16#D800#) by attempting the conversion
--  through Character_Type'Val. If Character_Type'Range_Length < 16#D800#,
--  we assert True with a skip message. This compiles on all four backends
--  without #if / GPR scenario gymnastics.
--
--  Requirements Coverage: FUNC-UTF8-007
--
--  External Effects: None
--  Thread Safety: N/A
--  SPARK Status: Not Applicable (test code)

with AUnit.Test_Cases;

--  @relation FUNC-UTF8-007
package UTF8_Surrogate_Substitution_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   --  @relation FUNC-UTF8-007
   procedure Test_High_Surrogate_Becomes_Replacement_Char
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-007
   procedure Test_Low_Surrogate_Becomes_Replacement_Char
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-007
   procedure Test_Surrogate_Pair_Becomes_Two_Replacement_Chars
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-007
   procedure Test_To_UTF8_Does_Not_Raise_On_Surrogate_Input
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end UTF8_Surrogate_Substitution_Test;
