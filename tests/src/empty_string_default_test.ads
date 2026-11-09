-------------------------------------------------------------------------------
--  Anystrings Tests - Empty_String As A Component Default Test Suite Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test suite: Empty_String used as the default of record components
--  whose subtype carries a Dynamic_Predicate, on every backend.
--
--  @description
--  Regression test for a heap corruption on the uxstring backend. When
--  Empty_String was a function, GNAT copied its result into the component of
--  a default-initialised record without Adjust and then finalized the
--  temporary, so the UXString buffer was freed twice ("malloc(): unaligned
--  fastbin chunk detected" at run time). Empty_String is a constant again;
--  this suite default-initialises, copies, assigns and finalizes such records
--  at library level and in local scopes. A double free aborts the test binary.

with AUnit.Test_Cases;

package Empty_String_Default_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding
   function Name (T : Test_Case) return AUnit.Message_String;

   overriding
   procedure Register_Tests (T : in out Test_Case);

private

   procedure Test_Library_Level_Default (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Local_Defaults_Are_Independent (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Copy_And_Assign (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Repeated_Create_And_Finalize (T : in out AUnit.Test_Cases.Test_Case'Class);

end Empty_String_Default_Test;
