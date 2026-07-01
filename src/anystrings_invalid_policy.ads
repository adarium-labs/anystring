--  Anystrings_Invalid_Policy - Per-call invalid-code-point policy types
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

--  @summary
--  Shared enum + failure record for the Wide_Wide_String ingress boundary's
--  per-call invalid-code-point policy (Fix 2 Tier 2).
--
--  @description
--  Backend-agnostic. Placed at src/ (not inside a backend directory) so the
--  enum is declared exactly once across the tree - all five backends
--  re-export the same literals through their String_Types facade.
--
--  The four policies extend the WWS ingress boundary beyond the existing
--  "substitute with backend default" (retained as Backend_Default):
--
--    Backend_Default  - Substitute invalid code-points with the backend's
--                       built-in `Invalid_Substitute_Codepoint`; matches
--                       the zero-arg `From_Wide_Wide_String` behaviour.
--    Substitute_With  - Substitute with a caller-supplied Unicode scalar
--                       (must itself be valid; enforced by precondition).
--    Skip             - Drop invalid code-points; output length may shrink.
--    Report_As_Error  - Return a discriminated `WWS_Decode_Result` carrying
--                       the first offending code-point and its index.
--
--  External Effects: None
--  Thread Safety: N/A (no state)
--  SPARK Status: Compatible

package Anystrings_Invalid_Policy
  with SPARK_Mode
is

   --  @summary Per-call behaviour when From_Wide_Wide_String_Policy or
   --  From_Wide_Wide_String_Checked encounters an invalid Unicode
   --  code-point (surrogate U+D800..U+DFFF or value > U+10FFFF).
   type Invalid_Codepoint_Policy is
     (Backend_Default, Substitute_With, Skip, Report_As_Error);

   --  @summary Why a Wide_Wide_Character was rejected as invalid.
   --
   --  @description
   --    Surrogate_Codepoint    - Value in U+D800..U+DFFF (UTF-16 surrogate).
   --    Out_Of_Range_Codepoint - Value strictly greater than U+10FFFF.
   type WWS_Error_Kind is
     (Surrogate_Codepoint,
      Out_Of_Range_Codepoint);

   --  @summary Structured failure descriptor returned by the
   --  Report_As_Error policy.
   --
   --  @description
   --    Kind   - Which validity constraint was violated.
   --    Index  - 1-based position of the offending code-point in the
   --             caller-supplied Wide_Wide_String (independent of the
   --             array's actual 'First index).
   --    Value  - The offending Wide_Wide_Character (for diagnostics).
   type WWS_Failure is record
      Kind  : WWS_Error_Kind;
      Index : Positive;
      Value : Wide_Wide_Character;
   end record;

   --  @summary True iff CP is a valid Unicode scalar value.
   --
   --  @description
   --  A Unicode scalar value is a code-point in U+0000..U+10FFFF that is
   --  not a UTF-16 surrogate (U+D800..U+DFFF). Used as the SPARK-friendly
   --  precondition on user-supplied substitute characters for the
   --  Substitute_With policy.
   function Is_Valid_Scalar (CP : Wide_Wide_Character) return Boolean
   is (Wide_Wide_Character'Pos (CP) <= 16#10_FFFF#
       and then Wide_Wide_Character'Pos (CP) not in 16#D800# .. 16#DFFF#);

end Anystrings_Invalid_Policy;
