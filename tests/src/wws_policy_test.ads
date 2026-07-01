--  Anystrings Tests - WWS Per-Call Policy Test Suite Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

--  @summary
--  AUnit test suite for the Tier 2 per-call invalid-code-point policy
--  extending the Wide_Wide_String ingress boundary.
--
--  @description
--  Verifies the contract for the three new subprograms added to every
--  backend:
--
--    function From_Wide_Wide_String_With_Substitute
--      (Source     : Wide_Wide_String;
--       Substitute : Wide_Wide_Character) return String_Type;
--
--    function From_Wide_Wide_String_Skip_Invalid
--      (Source : Wide_Wide_String) return String_Type;
--
--    function From_Wide_Wide_String_Checked
--      (Source : Wide_Wide_String) return WWS_Decode_Result;
--
--  All three are total (never raise) at the operations layer; the
--  precondition on Substitute (must be a valid Unicode scalar) is
--  enforced by the public wrappers in string_types.ads.
--
--  Coverage:
--    1. Substitute_With yields caller-supplied Substitute (not backend
--       default) at each invalid slot.
--    2. Skip drops invalid code-points; output round-trips to a shorter
--       Wide_Wide_String with the valid slots preserved.
--    3. Report_As_Error returns Is_Ok = False with correct 1-based Index
--       and Kind for the first invalid code-point.
--    4. Report_As_Error on all-valid input returns Is_Ok = True and the
--       value round-trips to the original Wide_Wide_String.
--    5. Substitute precondition (Substitute must be a valid Unicode
--       scalar) fires an assertion in assertion-enabled builds; the test
--       passes silently in non-assertion builds.
--
--  External Effects: None
--  Thread Safety: N/A
--  SPARK Status: Not Applicable (test code)

with AUnit.Test_Cases;

package WWS_Policy_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   procedure Test_Substitute_With_Explicit_Substitute
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Skip_Drops_Invalid_Codepoints
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Checked_Reports_First_Surrogate_At_Index_3
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Checked_Valid_Input_Round_Trips
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Substitute_Precondition_On_Surrogate_Substitute
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end WWS_Policy_Test;
