--  Anystrings Tests - Filesystem Boundary Test Suite Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

--  @summary
--  AUnit test suite: Ada.Directories bridge (FUNC-DIR-001..008, NFR-DIR-001..006).

--  @description
--  Validates the filesystem boundary API exposed through String_Types.
--  Backend-agnostic: the same source compiles for all five backends
--  (standard, wide_string, wide_wide_string, uxstring, vss),
--  exercising FUNC-DIR-008 by construction.
--
--  SPARK Status: Not Applicable (test code).

with AUnit.Test_Cases;

package Filesystem_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   --  @relation FUNC-DIR-002, FUNC-DIR-003, NFR-DIR-001
   procedure Test_Exists_Returns_False_For_Nonexistent_Path
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-DIR-002, FUNC-DIR-003, FUNC-DIR-005
   procedure Test_Exists_And_Kind_On_Ascii_File
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-DIR-003, FUNC-DIR-004
   procedure Test_Create_Directory_And_Kind_Is_Directory
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-DIR-006, NFR-DIR-001
   procedure Test_Rename_Round_Trip
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-DIR-005, NFR-DIR-001
   procedure Test_Delete_File_Round_Trip_And_Totality
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-DIR-002, FUNC-DIR-003, FUNC-DIR-005, FUNC-DIR-007, NFR-DIR-006
   procedure Test_Utf8_Multibyte_Path
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-DIR-004, FUNC-DIR-005, FUNC-DIR-006, NFR-DIR-001
   procedure Test_Mutator_Totality_On_Nonexistent_Input
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-DIR-002, FUNC-DIR-003, FUNC-DIR-005, NFR-DIR-001
   procedure Test_Empty_Path_Edge_Case
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end Filesystem_Test;
