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
--  Wrappers around the per-backend Wide_Wide_Directories implementation
--  package, so that consumers can opt in to the filesystem API with
--  `with String_Types.Directories;` without forcing Ada.Directories into
--  the dependency closure of every `with String_Types;`. The String_Type
--  paths are unwrapped before the call (see the body).
--
--  Public surface is identical across all five backends
--  (FUNC-FACADE-003).
--
--  @relation FUNC-FACADE-002, FUNC-FACADE-003, FUNC-FACADE-008, NFR-FACADE-002

with Wide_Wide_Directories;

package String_Types.Directories with SPARK_Mode is

   subtype File_Kind is Wide_Wide_Directories.File_Kind;

   Directory     : constant File_Kind := Wide_Wide_Directories.Directory;
   Ordinary_File : constant File_Kind := Wide_Wide_Directories.Ordinary_File;
   Special_File  : constant File_Kind := Wide_Wide_Directories.Special_File;

   function "=" (Left, Right : File_Kind) return Boolean
     renames Wide_Wide_Directories."=";

   function Exists (Path : String_Type) return Boolean;

   function Kind (Path : String_Type) return File_Kind;

   function Create_Directory (Path : String_Type) return Boolean;

   function Delete_File (Path : String_Type) return Boolean;

   function Rename (Old_Path, New_Path : String_Type) return Boolean;

end String_Types.Directories;
