-------------------------------------------------------------------------------
--  UXString_Directories - Ada.Directories bridge for the uxstring backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Directories;
with UXString_Operations;

package body UXString_Directories with SPARK_Mode => Off is

   --  @relation FUNC-DIR-002, NFR-DIR-001
   function Exists (Path : String_Type) return Boolean is
      POSIX_Path : constant String := UXString_Operations.To_UTF_8 (Path);
   begin
      if POSIX_Path'Length = 0 then
         return False;
      end if;
      return Ada.Directories.Exists (POSIX_Path);
   exception
      when others =>
         return False;
   end Exists;

   --  @relation FUNC-DIR-003, NFR-DIR-001
   function Kind (Path : String_Type) return File_Kind is
      POSIX_Path  : constant String := UXString_Operations.To_UTF_8 (Path);
      Native_Kind : Ada.Directories.File_Kind;
   begin
      if POSIX_Path'Length = 0 then
         return Special_File;
      end if;
      Native_Kind := Ada.Directories.Kind (POSIX_Path);
      case Native_Kind is
         when Ada.Directories.Directory     =>
            return Directory;

         when Ada.Directories.Ordinary_File =>
            return Ordinary_File;

         when Ada.Directories.Special_File  =>
            return Special_File;
      end case;
   exception
      when others =>
         return Special_File;
   end Kind;

   --  @relation FUNC-DIR-004, NFR-DIR-001
   function Create_Directory (Path : String_Type) return Boolean is
      POSIX_Path : constant String := UXString_Operations.To_UTF_8 (Path);
   begin
      if POSIX_Path'Length = 0 then
         return False;
      end if;
      Ada.Directories.Create_Directory (POSIX_Path);
      return True;
   exception
      when others =>
         return False;
   end Create_Directory;

   --  @relation FUNC-DIR-005, NFR-DIR-001
   function Delete_File (Path : String_Type) return Boolean is
      POSIX_Path : constant String := UXString_Operations.To_UTF_8 (Path);
   begin
      if POSIX_Path'Length = 0 then
         return False;
      end if;
      Ada.Directories.Delete_File (POSIX_Path);
      return True;
   exception
      when others =>
         return False;
   end Delete_File;

   --  @relation FUNC-DIR-006, NFR-DIR-001
   function Rename (Old_Path, New_Path : String_Type) return Boolean is
      Src : constant String := UXString_Operations.To_UTF_8 (Old_Path);
      Dst : constant String := UXString_Operations.To_UTF_8 (New_Path);
   begin
      if Src'Length = 0 or else Dst'Length = 0 then
         return False;
      end if;
      Ada.Directories.Rename (Src, Dst);
      return True;
   exception
      when others =>
         return False;
   end Rename;

end UXString_Directories;
