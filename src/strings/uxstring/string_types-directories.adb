-------------------------------------------------------------------------------
--  String_Types.Directories - Ada.Directories bridge (bodies)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with UXString_Wrapper.Convert;

package body String_Types.Directories
  with SPARK_Mode => Off
is

   package Conv renames UXString_Wrapper.Convert;

   function Exists (Path : String_Type) return Boolean
   is (UXString_Directories.Exists (Conv.To_UXString (Path)));

   function Kind (Path : String_Type) return File_Kind
   is (UXString_Directories.Kind (Conv.To_UXString (Path)));

   function Create_Directory (Path : String_Type) return Boolean
   is (UXString_Directories.Create_Directory (Conv.To_UXString (Path)));

   function Delete_File (Path : String_Type) return Boolean
   is (UXString_Directories.Delete_File (Conv.To_UXString (Path)));

   function Rename (Old_Path, New_Path : String_Type) return Boolean
   is (UXString_Directories.Rename (Conv.To_UXString (Old_Path), Conv.To_UXString (New_Path)));

end String_Types.Directories;
