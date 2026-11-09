-------------------------------------------------------------------------------
--  Anystrings Tests - Length Contracts Test Suite Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test suite: length contracts of String_Types on every backend.
--
--  @description
--  Exercises Length, Is_Empty, Empty_String, the "&" overloads, Concat,
--  Append_Character, Prepend_Character, Append, Slice, To_String_Type and
--  To_Latin_1. Inputs are ASCII or single Latin-1 bytes, which every backend
--  stores one unit per byte, so the same assertions hold on all backends.
--  The suite is built with assertions enabled (-gnata), so the contracts of
--  the SPARK_Mode => Off bodies are checked at run time as well.

with AUnit.Test_Cases;

package Length_Contracts_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding
   function Name (T : Test_Case) return AUnit.Message_String;

   overriding
   procedure Register_Tests (T : in out Test_Case);

private

   procedure Test_Empty_String (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Concat_Lengths (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Concat_Function_Forms (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Append_Lengths (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Slice_Lengths (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Slice_Out_Of_Range_Raises (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_To_String_Type_Length (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_To_Latin_1_Length (T : in out AUnit.Test_Cases.Test_Case'Class);

end Length_Contracts_Test;
