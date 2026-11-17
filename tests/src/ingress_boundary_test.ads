-------------------------------------------------------------------------------
--  Anystrings Tests - Ingress Boundary Test Suite Spec (KI-046 fix round 1)
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test suite: the replacement decoder on strings whose bounds lie at
--  the top of the Integer range (Positive'Last), where an index plus a length
--  would overflow; and the uxstring To_String_Type decision (valid UTF-8,
--  U+FFFD for ill-formed subparts, never Latin-1 fallback).
--
--  @description
--  The strings are declared with lower bounds Positive'Last - N + 1, so every
--  index touched by the decoder is near Positive'Last. Before the fix, the
--  lead-byte scan formed Index + Accepted + 1 before testing it against
--  Source'Last, which overflowed for such bounds.
--
--  Requirements Coverage: FUNC-UTF8-007, FUNC-UTF8-010, NFR-UTF8-004
--
--  SPARK Status: Not Applicable (test code)

with AUnit.Test_Cases;

package Ingress_Boundary_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   --  @relation FUNC-UTF8-007
   procedure Test_Decoder_At_Top_Of_Index_Range
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-007, NFR-UTF8-004
   procedure Test_Top_Of_Range_Single_Byte_And_Scalar
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-010
   procedure Test_Checked_From_UTF_8_At_Top_Of_Range
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-007
   procedure Test_To_String_Type_Replaces_Latin_1_Bytes
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end Ingress_Boundary_Test;
