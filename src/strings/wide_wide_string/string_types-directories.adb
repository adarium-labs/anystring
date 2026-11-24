-------------------------------------------------------------------------------
--  String_Types.Directories - Ada.Directories bridge (bodies)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

package body String_Types.Directories with SPARK_Mode => Off is

   function Exists (Path : String_Type) return Boolean
   is (Wide_Wide_Directories.Exists (Unwrap (Path)));

   function Kind (Path : String_Type) return File_Kind
   is (Wide_Wide_Directories.Kind (Unwrap (Path)));

   function Create_Directory (Path : String_Type) return Boolean
   is (Wide_Wide_Directories.Create_Directory (Unwrap (Path)));

   function Delete_File (Path : String_Type) return Boolean
   is (Wide_Wide_Directories.Delete_File (Unwrap (Path)));

   function Rename (Old_Path, New_Path : String_Type) return Boolean
   is (Wide_Wide_Directories.Rename (Unwrap (Old_Path), Unwrap (New_Path)));

end String_Types.Directories;
