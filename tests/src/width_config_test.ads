--  Width_Config_Test — Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
--
--  @summary
--  AUnit test suite: Width_Configuration type, Default_Linux / Default_Strict
--  named constants, Narrow / Wide context literals, and malformed-input
--  best-effort vs strict handling
--  (FUNC-WIDTH-006, NFR-WIDTH-003, NFR-WIDTH-004).
--
--  @description
--  Tests that all configuration surface elements compile and produce
--  numerically correct results on the §8.2 corpus.  The malformed-input
--  tests validate the best-effort contract: no exception is raised when
--  Reject_Illegal = False (the default).
--
--  SPARK Status: Not Applicable (test code).

with AUnit.Test_Cases;

package Width_Config_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   --  @relation FUNC-WIDTH-006, NFR-WIDTH-003
   procedure Test_Default_Linux_Gives_Correct_ASCII_Width
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-006, NFR-WIDTH-003
   procedure Test_Default_Linux_Is_Default_Conf_Argument
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-006
   procedure Test_Default_Strict_Gives_Same_Width_On_Valid_Input
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-006
   procedure Test_Narrow_Wide_Context_Constants_Are_Accessible
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation NFR-WIDTH-004
   procedure Test_Best_Effort_Does_Not_Raise_On_Raw_Byte
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation NFR-WIDTH-004
   procedure Test_Best_Effort_Single_Byte_Width_Is_One
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end Width_Config_Test;
