-------------------------------------------------------------------------------
--  Anystrings Tests - Scalar Ingress Test Suite Spec
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test suite: every public constructor and mutator that takes a
--  Character_Type or a native String leaves only Unicode scalar values in
--  the String_Type (policy P at the ingress, the same U+FFFD replacement as
--  From_Wide_Wide_String).
--
--  @description
--  Runs in-process on every backend. On standard the Character_Type cannot
--  hold a non-scalar value at all, so the non-scalar rows are skipped there;
--  the Latin-1 rows are skipped there too because standard stores raw bytes
--  (docs/text-model.md, section 9.2).
--
--  The compile-time half of the invariant, that a wide_wide_string String_Type
--  cannot be built from a raw Unbounded_Wide_Wide_String, cannot be stated as
--  an AUnit test (a rejected compilation is not a runtime result). It is
--  documented in docs/text-model.md, section 9.6, and enforced by String_Type
--  being private.
--
--  SPARK Status: Not Applicable (test code)

with AUnit.Test_Cases;

package Scalar_Ingress_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   procedure Test_Non_Scalar_Characters_Replaced
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Scalar_Characters_Unchanged
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Derived_Values_Keep_Scalars
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Latin_1_Native_Strings_Scalar
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end Scalar_Ingress_Test;
