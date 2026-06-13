--  Width_Parity_Test — Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
--
--  @summary
--  AUnit test suite: cross-backend API surface parity (FUNC-WIDTH-002).
--
--  @description
--  One test procedure calls every public subprogram in String_Types.Width
--  once on the mixed corpus "héllo 日本語".  Purpose: verify that the
--  entire width surface compiles and links identically regardless of
--  backend, and that all symbols resolve to consistent types.
--
--  This is a smoke test for parity, not a deep validator.  Numeric
--  correctness of individual functions is tested in the sibling suites.
--
--  SPARK Status: Not Applicable (test code).

with AUnit.Test_Cases;

package Width_Parity_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   --  @relation FUNC-WIDTH-002
   procedure Test_All_Width_Symbols_Callable_On_Mixed_Corpus
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end Width_Parity_Test;
