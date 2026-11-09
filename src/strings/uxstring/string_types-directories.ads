-------------------------------------------------------------------------------
--  String_Types.Directories - Ada.Directories bridge
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Child package of String_Types exposing the Ada.Directories bridge.
--
--  @description
--  Thin wrappers over the per-backend UXString_Directories implementation
--  package (String_Type is a private wrapper on this backend, so the
--  subprograms cannot be plain renames). Consumers opt in to the filesystem
--  API with `with String_Types.Directories;` without forcing Ada.Directories
--  into the dependency closure of every `with String_Types;`.
--
--  Public surface is identical across all five backends
--  (FUNC-FACADE-003), only the implementation differs.
--
--  @relation FUNC-FACADE-002, FUNC-FACADE-003, FUNC-FACADE-008, NFR-FACADE-002

with UXString_Directories;

package String_Types.Directories
  with SPARK_Mode => Off
is

   subtype File_Kind is UXString_Directories.File_Kind;

   Directory     : constant File_Kind := UXString_Directories.Directory;
   Ordinary_File : constant File_Kind := UXString_Directories.Ordinary_File;
   Special_File  : constant File_Kind := UXString_Directories.Special_File;

   function "=" (Left, Right : File_Kind) return Boolean renames UXString_Directories."=";

   function Exists (Path : String_Type) return Boolean;

   function Kind (Path : String_Type) return File_Kind;

   function Create_Directory (Path : String_Type) return Boolean;

   function Delete_File (Path : String_Type) return Boolean;

   function Rename (Old_Path, New_Path : String_Type) return Boolean;

end String_Types.Directories;
