-------------------------------------------------------------------------------
--  Anystrings Tests - Scalar Ingress Width Test Suite Spec
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test suite: Pad_To_Width on the three sides (Left, Right, Both)
--  with a padding character that is not a Unicode scalar value. The padding
--  must be stored as U+FFFD and no stored code point may be a non-scalar.
--
--  @description
--  Only compiled with ANYSTRING_WITH_WIDTH=true (see anystrings_tests.gpr).
--  On standard a Character cannot hold a non-scalar value, so the non-scalar
--  rows are skipped there.
--
--  SPARK Status: Not Applicable (test code)

with AUnit.Test_Cases;

package Scalar_Ingress_Width_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   procedure Test_Pad_Scalar_All_Sides
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Pad_Non_Scalar_All_Sides
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end Scalar_Ingress_Width_Test;
