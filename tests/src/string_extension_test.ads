-------------------------------------------------------------------------------
--  Anystrings Tests - String Extension Operations Test Suite Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test suite: Index_From, Index_Reverse, Replace, Head, Tail.
--
--  @description
--  Validates the five new Ada.Strings.Fixed bridge operations exposed
--  through every backend. All tests are written against the String_Types
--  facade so they exercise the active backend.

with AUnit.Test_Cases;

package String_Extension_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   procedure Test_Index_From_Basic
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Index_From_Past_End
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Index_Reverse_Basic
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Replace_Multiple
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Replace_Empty_Pattern
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Replace_Not_Found
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Replace_Empty_By
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Head_Pad
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Head_Truncate
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Tail_Pad
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Tail_Truncate
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Replace_Multi_Byte
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end String_Extension_Test;
