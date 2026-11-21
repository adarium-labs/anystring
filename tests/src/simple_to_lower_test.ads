-------------------------------------------------------------------------------
--  Anystrings Tests - Simple_To_Lower Test Suite Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test suite: Simple_To_Lower, the length-preserving lower-case mapping.
--
--  @description
--  Every expectation is written in code points (To_Wide_Wide_String), never in
--  stored bytes, so the same test runs on every backend. Each case also checks
--  that Length and Code_Point_Length of the result equal those of the input.
--  Where the backend counts bytes (standard), a mapping that would change the
--  UTF-8 byte length is not applied; those cases expect the input unchanged.

with AUnit.Test_Cases;

package Simple_To_Lower_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   procedure Test_ASCII
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Latin_1
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Greek
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Empty
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Unchanged
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Dotted_I_And_Capital_Sharp_S
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Supplementary_Plane
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Generated_Samples
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Malformed_Bytes_Standard_Only
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end Simple_To_Lower_Test;
