--  Anystrings Tests - Wide_Wide_String Boundary Test Suite Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

--  @summary
--  AUnit test suite: code-point-indexed boundary
--  (To_Wide_Wide_String / To_String_Type).
--
--  @description
--  Verifies the contract for the two new symmetric subprograms added to
--  every backend:
--
--    function To_Wide_Wide_String (Source : String_Type) return Wide_Wide_String;
--    function To_String_Type      (Source : Wide_Wide_String) return String_Type;
--
--  Both are total (never raise) and treat Wide_Wide_String as the canonical
--  "one Wide_Wide_Character per Unicode code-point" interchange type.
--
--  Coverage:
--    1. ASCII, BMP and supplementary-plane round-trip (W -> S -> W).
--    2. Empty-string handling in both directions.
--    3. Wide_Wide_String inputs containing surrogates or values > U+10FFFF
--       are normalised to U+FFFD when passed through To_String_Type and
--       then re-decoded with To_Wide_Wide_String.
--    4. Truncating a multi-unit encoding via Slice (which yields a lone
--       UTF-8 lead byte on the standard backend or a lone UTF-16 surrogate
--       on the wide_string backend) decodes to U+FFFD. On code-point
--       backends (wide_wide_string, uxstring, vss) the test is skipped
--       because supplementary code-points already occupy a single unit.
--
--  External Effects: None
--  Thread Safety: N/A
--  SPARK Status: Not Applicable (test code)

with AUnit.Test_Cases;

package WWS_Boundary_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   procedure Test_Empty_String_Round_Trip
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_ASCII_Round_Trip
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_BMP_Non_ASCII_Round_Trip
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Supplementary_Plane_Round_Trip
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Surrogate_In_Wide_Wide_Becomes_FFFD
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Out_Of_Range_Wide_Wide_Becomes_FFFD
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Empty_Wide_Wide_String_Round_Trip
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Truncated_Multi_Unit_Encoding_Decodes_To_FFFD
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end WWS_Boundary_Test;
