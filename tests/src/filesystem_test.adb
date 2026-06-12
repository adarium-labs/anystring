--  Anystrings Tests - Filesystem Boundary Test Suite Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

with Ada.Directories;
with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with GNAT.OS_Lib;
with String_Types;     use String_Types;
with String_Types.Directories; use String_Types.Directories;
with String_Types.Text_IO; use String_Types.Text_IO;

package body Filesystem_Test is

   --  Return the current process ID as a trimmed decimal string.
   function Pid_String return String is
      Img : constant String :=
        Integer'Image
          (GNAT.OS_Lib.Pid_To_Integer (GNAT.OS_Lib.Current_Process_Id));
   begin
      return Img (Img'First + 1 .. Img'Last);
   end Pid_String;

   --  Build a unique /tmp path: /tmp/anystrings_<Label>_<PID>.
   function Make_Path (Label : String) return String_Type is
   begin
      return To_String_Type ("/tmp/anystrings_" & Label & "_" & Pid_String);
   end Make_Path;

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Filesystem Boundary Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine
        (T,
         (Routine      => Test_Exists_Returns_False_For_Nonexistent_Path'Access,
          Routine_Name =>
            AUnit.Format ("Exists returns False for nonexistent path")));
      Add_Routine
        (T,
         (Routine      => Test_Exists_And_Kind_On_Ascii_File'Access,
          Routine_Name =>
            AUnit.Format ("Exists and Kind round-trip on ASCII ordinary file")));
      Add_Routine
        (T,
         (Routine      => Test_Create_Directory_And_Kind_Is_Directory'Access,
          Routine_Name =>
            AUnit.Format ("Create_Directory returns True and Kind is Directory")));
      Add_Routine
        (T,
         (Routine      => Test_Rename_Round_Trip'Access,
          Routine_Name =>
            AUnit.Format ("Rename: source gone, destination exists after rename")));
      Add_Routine
        (T,
         (Routine      => Test_Delete_File_Round_Trip_And_Totality'Access,
          Routine_Name =>
            AUnit.Format ("Delete_File round-trip; second call returns False")));
      Add_Routine
        (T,
         (Routine      => Test_Utf8_Multibyte_Path'Access,
          Routine_Name =>
            AUnit.Format
              ("Exists and Kind on UTF-8 multibyte path (cafe with accented e)")));
      Add_Routine
        (T,
         (Routine      => Test_Mutator_Totality_On_Nonexistent_Input'Access,
          Routine_Name =>
            AUnit.Format
              ("Mutators return False on nonexistent input without raising")));
      Add_Routine
        (T,
         (Routine      => Test_Empty_Path_Edge_Case'Access,
          Routine_Name =>
            AUnit.Format
              ("Empty path: Exists=False, Kind=Special_File, Delete_File=False")));
   end Register_Tests;

   --  -----------------------------------------------------------------------
   --  T1 — Exists returns False for nonexistent path (FUNC-DIR-002, NFR-DIR-001)
   --  Also verifies Kind returns Special_File (FUNC-DIR-003 totality).
   --  -----------------------------------------------------------------------

   procedure Test_Exists_Returns_False_For_Nonexistent_Path
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Path : constant String_Type :=
        To_String_Type
          ("/tmp/anystrings_does_not_exist_XYZ_" & Pid_String);
   begin
      Assert
        (not Exists (Path),
         "Exists should return False for a path that was never created");
      Assert
        (Kind (Path) = Special_File,
         "Kind should return Special_File for a nonexistent path");
   end Test_Exists_Returns_False_For_Nonexistent_Path;

   --  -----------------------------------------------------------------------
   --  T2 — Exists and Kind on ASCII ordinary file (FUNC-DIR-002, FUNC-DIR-003)
   --  Creates a file via the Text I/O facade, asserts Exists + Kind, then
   --  deletes via Delete_File and verifies Exists returns False.
   --  -----------------------------------------------------------------------

   procedure Test_Exists_And_Kind_On_Ascii_File
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Path : constant String_Type := Make_Path ("t2_ascii");
      File : File_Type;
   begin
      --  Pre-cleanup (best-effort, guards against a prior crashed run)
      declare
         Unused : constant Boolean := Delete_File (Path);
         pragma Unreferenced (Unused);
      begin
         null;
      end;

      Create (File, Out_File, To_UTF_8 (Path));
      Close (File);

      Assert (Exists (Path),
              "Exists should be True for a just-created ASCII file");
      Assert (Kind (Path) = Ordinary_File,
              "Kind should be Ordinary_File for a plain created file");

      Assert (Delete_File (Path),
              "Delete_File should return True for an existing ordinary file");
      Assert (not Exists (Path),
              "Exists should be False immediately after Delete_File");
   exception
      when others =>
         declare
            Unused : constant Boolean := Delete_File (Path);
            pragma Unreferenced (Unused);
         begin
            null;
         end;
         raise;
   end Test_Exists_And_Kind_On_Ascii_File;

   --  -----------------------------------------------------------------------
   --  T3 — Create_Directory returns True and Kind reports Directory
   --       (FUNC-DIR-004, FUNC-DIR-003)
   --  Cleanup uses Ada.Directories.Delete_Directory directly because the
   --  bridge does not yet expose Delete_Directory.
   --  -----------------------------------------------------------------------

   procedure Test_Create_Directory_And_Kind_Is_Directory
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Path : constant String_Type := Make_Path ("t3_dir");
   begin
      --  Pre-cleanup
      begin
         Ada.Directories.Delete_Directory (To_UTF_8 (Path));
      exception
         when others => null;
      end;

      Assert (Create_Directory (Path),
              "Create_Directory should return True for a new directory path");
      Assert (Exists (Path),
              "Exists should be True after Create_Directory");
      Assert (Kind (Path) = Directory,
              "Kind should be Directory for a created directory");

      Ada.Directories.Delete_Directory (To_UTF_8 (Path));
   exception
      when others =>
         begin
            Ada.Directories.Delete_Directory (To_UTF_8 (Path));
         exception
            when others => null;
         end;
         raise;
   end Test_Create_Directory_And_Kind_Is_Directory;

   --  -----------------------------------------------------------------------
   --  T4 — Rename round-trip (FUNC-DIR-006)
   --  Also asserts that renaming a nonexistent source returns False (NFR-DIR-001).
   --  -----------------------------------------------------------------------

   procedure Test_Rename_Round_Trip
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Src  : constant String_Type := Make_Path ("t4_rename_src");
      Dst  : constant String_Type := Make_Path ("t4_rename_dst");
      File : File_Type;
   begin
      --  Pre-cleanup
      declare
         U1 : constant Boolean := Delete_File (Src);
         U2 : constant Boolean := Delete_File (Dst);
         pragma Unreferenced (U1, U2);
      begin
         null;
      end;

      Create (File, Out_File, To_UTF_8 (Src));
      Close (File);

      Assert (Rename (Src, Dst),
              "Rename should return True when source exists");
      Assert (not Exists (Src),
              "Source should not exist after rename");
      Assert (Exists (Dst),
              "Destination should exist after rename");

      --  Totality: renaming already-moved source returns False (NFR-DIR-001)
      Assert (not Rename (Src, Dst),
              "Rename with nonexistent source should return False without raising");

      Assert (Delete_File (Dst),
              "Delete_File should succeed on the renamed destination");
   exception
      when others =>
         declare
            U1 : constant Boolean := Delete_File (Src);
            U2 : constant Boolean := Delete_File (Dst);
            pragma Unreferenced (U1, U2);
         begin
            null;
         end;
         raise;
   end Test_Rename_Round_Trip;

   --  -----------------------------------------------------------------------
   --  T5 — Delete_File round-trip and totality (FUNC-DIR-005, NFR-DIR-001)
   --  The second Delete_File call on the already-deleted path must return
   --  False without raising, proving the totality contract.
   --  -----------------------------------------------------------------------

   procedure Test_Delete_File_Round_Trip_And_Totality
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Path : constant String_Type := Make_Path ("t5_delete");
      File : File_Type;
   begin
      --  Pre-cleanup
      declare
         Unused : constant Boolean := Delete_File (Path);
         pragma Unreferenced (Unused);
      begin
         null;
      end;

      Create (File, Out_File, To_UTF_8 (Path));
      Close (File);

      Assert (Delete_File (Path),
              "Delete_File should return True for an existing file");
      Assert (not Exists (Path),
              "Exists should be False after Delete_File");

      Assert (not Delete_File (Path),
              "Delete_File on an already-deleted path must return False without raising");
   end Test_Delete_File_Round_Trip_And_Totality;

   --  -----------------------------------------------------------------------
   --  T6 — UTF-8 multibyte path (FUNC-DIR-007, NFR-DIR-006)
   --  'é' is U+00E9, encoded in UTF-8 as 0xC3 0xA9.
   --  The path is built via To_String_Type from a Standard.String that
   --  carries those two raw bytes — never via To_Latin_1.
   --  On Unicode backends this exercises the To_UTF_8 re-encoding path;
   --  on the standard backend it is byte-identity.  Both must produce the
   --  same OS-level path bytes (FUNC-DIR-007 regression check).
   --  -----------------------------------------------------------------------

   procedure Test_Utf8_Multibyte_Path
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Cafe_Path : constant String_Type :=
        To_String_Type
          ("/tmp/anystrings_caf"
           & Character'Val (16#C3#)
           & Character'Val (16#A9#)
           & "_"
           & Pid_String);
      File : File_Type;
   begin
      --  Pre-cleanup
      declare
         Unused : constant Boolean := Delete_File (Cafe_Path);
         pragma Unreferenced (Unused);
      begin
         null;
      end;

      Create (File, Out_File, To_UTF_8 (Cafe_Path));
      Close (File);

      Assert
        (Exists (Cafe_Path),
         "Exists must be True for a UTF-8 multibyte path "
         & "(regression: To_Latin_1 would corrupt the path bytes)");
      Assert
        (Kind (Cafe_Path) = Ordinary_File,
         "Kind must be Ordinary_File for the UTF-8-named file");

      Assert (Delete_File (Cafe_Path),
              "Delete_File should succeed on a UTF-8-named file");
      Assert (not Exists (Cafe_Path),
              "Exists should be False after deleting the UTF-8-named file");
   exception
      when others =>
         declare
            Unused : constant Boolean := Delete_File (Cafe_Path);
            pragma Unreferenced (Unused);
         begin
            null;
         end;
         raise;
   end Test_Utf8_Multibyte_Path;

   --  -----------------------------------------------------------------------
   --  T7 — Totality of mutators on nonexistent input (NFR-DIR-001)
   --  -----------------------------------------------------------------------

   procedure Test_Mutator_Totality_On_Nonexistent_Input
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Ghost      : constant String_Type :=
        To_String_Type ("/tmp/anystrings_ghost_" & Pid_String);
      Ghost_Src  : constant String_Type :=
        To_String_Type ("/tmp/anystrings_ghost_src_" & Pid_String);
      Ghost_Dst  : constant String_Type :=
        To_String_Type ("/tmp/anystrings_ghost_dst_" & Pid_String);
      Dir_Path   : constant String_Type := Make_Path ("t7_newdir");
   begin
      --  Pre-cleanup of the directory created below
      begin
         Ada.Directories.Delete_Directory (To_UTF_8 (Dir_Path));
      exception
         when others => null;
      end;

      Assert (not Delete_File (Ghost),
              "Delete_File on a never-created path should return False");
      Assert (not Rename (Ghost_Src, Ghost_Dst),
              "Rename with nonexistent source should return False");

      Assert (Create_Directory (Dir_Path),
              "Create_Directory should return True for a genuinely new path");
      Assert (not Create_Directory (Dir_Path),
              "Create_Directory on an already-existing path should return False");

      Ada.Directories.Delete_Directory (To_UTF_8 (Dir_Path));
   exception
      when others =>
         begin
            Ada.Directories.Delete_Directory (To_UTF_8 (Dir_Path));
         exception
            when others => null;
         end;
         raise;
   end Test_Mutator_Totality_On_Nonexistent_Input;

   --  -----------------------------------------------------------------------
   --  T8 — Empty path edge cases (NFR-DIR-001)
   --  -----------------------------------------------------------------------

   procedure Test_Empty_Path_Edge_Case
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Assert (not Exists (Empty_String),
              "Exists on empty path should return False without raising");
      Assert (Kind (Empty_String) = Special_File,
              "Kind on empty path should return Special_File without raising");
      Assert (not Delete_File (Empty_String),
              "Delete_File on empty path should return False without raising");
   end Test_Empty_Path_Edge_Case;

end Filesystem_Test;
