--  anystrings - Ada string abstraction crate
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
--
--  Demonstrates: Filesystem boundary (FUNC-DIR-001..008)
--
--  Exercises the five Ada.Directories wrappers exposed via String_Types:
--    Exists / Kind / Create_Directory / Delete_File / Rename
--
--  Build and run (standard backend):
--    cd examples && alr build
--    bin/standard/anystrings_filesystem_demo
--
--  Build and run (wide_string backend):
--    STRING_TYPE=wide_string alr build
--    bin/wide_string/utf_8/anystrings_filesystem_demo

with Ada.Directories;
with Ada.Text_IO;
with String_Types; use String_Types;
with String_Types.Directories; use String_Types.Directories;
with String_Types.Text_IO; use String_Types.Text_IO;

procedure Anystrings_Filesystem_Demo is

   procedure Section (Title : String) is
   begin
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("--- " & Title & " ---");
   end Section;

begin
   --  1. Exists / Kind on a non-existent path (FUNC-DIR-002, FUNC-DIR-003)
   Section ("Exists / Kind: non-existent path");
   declare
      Bogus : constant String_Type :=
         To_String_Type ("/tmp/anystrings-demo-does-not-exist-XYZ");
   begin
      Ada.Text_IO.Put_Line ("Bogus exists?  " & Boolean'Image (Exists (Bogus)));
      Ada.Text_IO.Put_Line ("Bogus kind:    " & File_Kind'Image (Kind (Bogus)));
   end;

   --  2. Create_Directory, query Kind, clean up (FUNC-DIR-004, FUNC-DIR-003)
   --     Delete_Directory is out of scope for the bridge; Ada.Directories is
   --     used directly for teardown only.
   Section ("Create_Directory / Kind / cleanup");
   declare
      Dir : constant String_Type :=
         To_String_Type ("/tmp/anystrings-demo-dir");
      OK  : Boolean;
   begin
      OK := Create_Directory (Dir);
      Ada.Text_IO.Put_Line ("Created dir?   " & Boolean'Image (OK));
      Ada.Text_IO.Put_Line ("Exists?        " & Boolean'Image (Exists (Dir)));
      Ada.Text_IO.Put_Line ("Kind:          " & File_Kind'Image (Kind (Dir)));
      Ada.Directories.Delete_Directory (To_Latin_1 (Dir));
      Ada.Text_IO.Put_Line ("After cleanup: " & Boolean'Image (Exists (Dir)));
   end;

   --  3. Ordinary file: Kind / Rename / Delete (FUNC-DIR-003, FUNC-DIR-005,
   --     FUNC-DIR-006).  Text_IO.Create takes a plain String name; To_Latin_1
   --     is byte-identity for the ASCII path used here.
   Section ("Ordinary file: Kind / Rename / Delete");
   declare
      Src         : constant String_Type :=
         To_String_Type ("/tmp/anystrings-demo-src.txt");
      Dst         : constant String_Type :=
         To_String_Type ("/tmp/anystrings-demo-dst.txt");
      File_Handle : File_Type;
      OK          : Boolean;
   begin
      Create (File_Handle, Out_File, To_Latin_1 (Src));
      Put (File_Handle, To_String_Type ("hello from anystrings"));
      Close (File_Handle);

      Ada.Text_IO.Put_Line ("Src exists? " & Boolean'Image (Exists (Src)));
      Ada.Text_IO.Put_Line ("Kind:       " & File_Kind'Image (Kind (Src)));

      OK := Rename (Src, Dst);
      Ada.Text_IO.Put_Line ("Renamed?    " & Boolean'Image (OK));
      Ada.Text_IO.Put_Line ("Src gone?   " & Boolean'Image (not Exists (Src)));
      Ada.Text_IO.Put_Line ("Dst exists? " & Boolean'Image (Exists (Dst)));

      OK := Delete_File (Dst);
      Ada.Text_IO.Put_Line ("Deleted?    " & Boolean'Image (OK));
   end;

   --  4. UTF-8 path "café" (FUNC-DIR-007).
   --     The string literal is UTF-8 encoded in source (c=0x63 a=0x61 f=0x66
   --     é=0xC3 0xA9); To_String_Type stores these bytes as-is on the standard
   --     backend (FUNC-CONV-001 byte identity).  On Unicode backends the bridge
   --     re-encodes back to UTF-8 at the Ada.Directories boundary so the OS
   --     path is consistent with what was stored.
   --
   --     Teardown uses To_UTF_8 rather than To_Latin_1: on Unicode backends
   --     To_UTF_8 reproduces the same bytes that Create_Directory handed to
   --     Ada.Directories, whereas To_Latin_1 would produce a different byte
   --     sequence and miss the directory.
   Section ("UTF-8 path: café");
   declare
      Cafe_Dir : constant String_Type :=
         To_String_Type ("/tmp/anystrings-demo-café-dir");
      OK       : Boolean;
   begin
      OK := Create_Directory (Cafe_Dir);
      Ada.Text_IO.Put_Line ("UTF-8 dir created? " & Boolean'Image (OK));
      Ada.Text_IO.Put_Line ("Exists?            " & Boolean'Image (Exists (Cafe_Dir)));
      Ada.Text_IO.Put_Line ("Kind:              " & File_Kind'Image (Kind (Cafe_Dir)));
      Ada.Directories.Delete_Directory (To_UTF_8 (Cafe_Dir));
      Ada.Text_IO.Put_Line ("After cleanup:     " & Boolean'Image (Exists (Cafe_Dir)));
   end;

exception
   when others =>
      Ada.Text_IO.Put_Line ("[ERROR] Unexpected exception -- check teardown.");
      raise;
end Anystrings_Filesystem_Demo;
