-------------------------------------------------------------------------------
--  String_Types.Directories - Ada.Directories bridge re-exports
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Child package of String_Types exposing the Ada.Directories bridge.
--
--  @description
--  Pure renames of the per-backend UXString_Directories implementation
--  package, so that consumers can opt in to the filesystem API with
--  `with String_Types.Directories;` without forcing Ada.Directories into
--  the dependency closure of every `with String_Types;`.
--
--  Public surface is identical across all five backends
--  (FUNC-FACADE-003), only the rename targets differ.
--
--  @relation FUNC-FACADE-002, FUNC-FACADE-003, FUNC-FACADE-008, NFR-FACADE-002

with UXString_Directories;

package String_Types.Directories with SPARK_Mode is

   subtype File_Kind is UXString_Directories.File_Kind;

   Directory     : constant File_Kind := UXString_Directories.Directory;
   Ordinary_File : constant File_Kind := UXString_Directories.Ordinary_File;
   Special_File  : constant File_Kind := UXString_Directories.Special_File;

   function "=" (Left, Right : File_Kind) return Boolean
     renames UXString_Directories."=";

   function Exists (Path : String_Type) return Boolean
     renames UXString_Directories.Exists;

   function Kind (Path : String_Type) return File_Kind
     renames UXString_Directories.Kind;

   function Create_Directory (Path : String_Type) return Boolean
     renames UXString_Directories.Create_Directory;

   function Delete_File (Path : String_Type) return Boolean
     renames UXString_Directories.Delete_File;

   function Rename (Old_Path, New_Path : String_Type) return Boolean
     renames UXString_Directories.Rename;

end String_Types.Directories;
