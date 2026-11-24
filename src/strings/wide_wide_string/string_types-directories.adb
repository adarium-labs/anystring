-------------------------------------------------------------------------------
--  String_Types.Directories - Ada.Directories bridge (bodies)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with String_Empty_Value.Convert;

package body String_Types.Directories with SPARK_Mode => Off is

   package Conv renames String_Empty_Value.Convert;

   function Exists (Path : String_Type) return Boolean
   is (Wide_Wide_Directories.Exists (Conv.To_Unbounded (Path)));

   function Kind (Path : String_Type) return File_Kind
   is (Wide_Wide_Directories.Kind (Conv.To_Unbounded (Path)));

   function Create_Directory (Path : String_Type) return Boolean
   is (Wide_Wide_Directories.Create_Directory (Conv.To_Unbounded (Path)));

   function Delete_File (Path : String_Type) return Boolean
   is (Wide_Wide_Directories.Delete_File (Conv.To_Unbounded (Path)));

   function Rename (Old_Path, New_Path : String_Type) return Boolean
   is (Wide_Wide_Directories.Rename (Conv.To_Unbounded (Old_Path), Conv.To_Unbounded (New_Path)));

end String_Types.Directories;
