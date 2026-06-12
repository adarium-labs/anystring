-------------------------------------------------------------------------------
--  UXString_Directories - Ada.Directories bridge for the uxstring backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Stand-alone Ada.Directories bridge for the uxstring backend.
--  Spec SPARK_Mode On; body SPARK_Mode Off.
--
--  @relation FUNC-DIR-001, FUNC-FACADE-008, NFR-FACADE-002, NFR-DIR-001

with UXStrings;

package UXString_Directories with SPARK_Mode is

   subtype String_Type is UXStrings.UXString;

   --  @relation FUNC-DIR-001
   type File_Kind is (Directory, Ordinary_File, Special_File);

   --  @relation FUNC-DIR-002, NFR-DIR-001
   function Exists (Path : String_Type) return Boolean;

   --  @relation FUNC-DIR-003, NFR-DIR-001
   function Kind (Path : String_Type) return File_Kind;

   --  @relation FUNC-DIR-004, NFR-DIR-001
   function Create_Directory (Path : String_Type) return Boolean;

   --  @relation FUNC-DIR-005, NFR-DIR-001
   function Delete_File (Path : String_Type) return Boolean;

   --  @relation FUNC-DIR-006, NFR-DIR-001
   function Rename (Old_Path, New_Path : String_Type) return Boolean;

end UXString_Directories;
