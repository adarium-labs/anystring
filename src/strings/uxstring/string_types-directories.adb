-------------------------------------------------------------------------------
--  String_Types.Directories - Ada.Directories bridge (bodies)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

package body String_Types.Directories
  with SPARK_Mode => Off
is

   function Exists (Path : String_Type) return Boolean
   is (UXString_Directories.Exists (Path.Value));

   function Kind (Path : String_Type) return File_Kind
   is (UXString_Directories.Kind (Path.Value));

   function Create_Directory (Path : String_Type) return Boolean
   is (UXString_Directories.Create_Directory (Path.Value));

   function Delete_File (Path : String_Type) return Boolean
   is (UXString_Directories.Delete_File (Path.Value));

   function Rename (Old_Path, New_Path : String_Type) return Boolean
   is (UXString_Directories.Rename (Old_Path.Value, New_Path.Value));

end String_Types.Directories;
