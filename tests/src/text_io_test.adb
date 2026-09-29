--  Anystrings Tests - Text_IO Bridge Encoding Test Suite Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

with Ada.Directories;
with Ada.Streams;      use Ada.Streams;
with Ada.Streams.Stream_IO;
with Ada.Text_IO;
with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with GNAT.OS_Lib;
with String_Types;     use String_Types;
with String_Types.Text_IO;

package body Text_IO_Test is

   package TIO renames String_Types.Text_IO;

   --  "é→" (U+00E9 U+2192) and its UTF-8 encoding.
   SAMPLE       : constant Wide_Wide_String := Wide_Wide_Character'Val (16#E9#) & Wide_Wide_Character'Val (16#2192#);
   SAMPLE_UTF_8 : constant Stream_Element_Array := [16#C3#, 16#A9#, 16#E2#, 16#86#, 16#92#, 16#0A#];

   --  Unique /tmp path: /tmp/anystrings_tio_<Label>_<PID>.
   function Make_Path (Label : String) return String is
      Img : constant String := Integer'Image (GNAT.OS_Lib.Pid_To_Integer (GNAT.OS_Lib.Current_Process_Id));
   begin
      return "/tmp/anystrings_tio_" & Label & "_" & Img (Img'First + 1 .. Img'Last);
   end Make_Path;

   --  Raw bytes of a file.
   function Read_Bytes (Path : String) return Stream_Element_Array is
      File   : Ada.Streams.Stream_IO.File_Type;
      Size   : constant Stream_Element_Offset := Stream_Element_Offset (Ada.Directories.Size (Path));
      Buffer : Stream_Element_Array (1 .. Size);
      Last   : Stream_Element_Offset;
   begin
      Ada.Streams.Stream_IO.Open (File, Ada.Streams.Stream_IO.In_File, Path);
      Ada.Streams.Stream_IO.Read (File, Buffer, Last);
      Ada.Streams.Stream_IO.Close (File);
      return Buffer (1 .. Last);
   end Read_Bytes;

   --  Write raw bytes to a file.
   procedure Write_Bytes (Path : String; Bytes : Stream_Element_Array) is
      File : Ada.Streams.Stream_IO.File_Type;
   begin
      Ada.Streams.Stream_IO.Create (File, Ada.Streams.Stream_IO.Out_File, Path);
      Ada.Streams.Stream_IO.Write (File, Bytes);
      Ada.Streams.Stream_IO.Close (File);
   end Write_Bytes;

   procedure Write_Sample (Path : String) is
      File : TIO.File_Type;
   begin
      TIO.Create (File, TIO.Out_File, Path);
      TIO.Put_Line (File, From_Wide_Wide_String (SAMPLE));
      TIO.Close (File);
   end Write_Sample;

   overriding
   function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Text_IO Bridge Encoding Tests");
   end Name;

   overriding
   procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine
        (T,
         (Routine      => Test_Put_Line_Writes_UTF_8'Access,
          Routine_Name => AUnit.Format ("Put_Line writes non-ASCII text as UTF-8")));
      Add_Routine
        (T,
         (Routine      => Test_Round_Trip_Non_ASCII'Access,
          Routine_Name => AUnit.Format ("Put_Line / Get_Line round-trip non-ASCII text")));
      Add_Routine
        (T,
         (Routine      => Test_Get_Line_Invalid_UTF_8_Is_Total'Access,
          Routine_Name => AUnit.Format ("Get_Line does not raise on invalid UTF-8")));
      Add_Routine
        (T,
         (Routine      => Test_Put_Line_Ignores_File_WCEM'Access,
          Routine_Name => AUnit.Format ("Put_Line writes UTF-8 once under WCEM=8 and WCEM=b")));
   end Register_Tests;

   procedure Test_Put_Line_Ignores_File_WCEM (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);

      procedure Check (Form : String) is
         Path : constant String := Make_Path ("wcem_" & Form (Form'Last));
         File : Ada.Text_IO.File_Type;
      begin
         Ada.Text_IO.Create (File, Ada.Text_IO.Out_File, Path, Form => Form);
         TIO.Put_Line (File, From_Wide_Wide_String (SAMPLE));
         Ada.Text_IO.Close (File);
         declare
            Bytes : constant Stream_Element_Array := Read_Bytes (Path);
         begin
            Ada.Directories.Delete_File (Path);
            Assert (Bytes = SAMPLE_UTF_8, Form & ": Put_Line must write C3 A9 E2 86 92 0A exactly once encoded");
         end;
      end Check;
   begin
      Check ("WCEM=8");
      Check ("WCEM=b");
   end Test_Put_Line_Ignores_File_WCEM;

   procedure Test_Put_Line_Writes_UTF_8 (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
      Path : constant String := Make_Path ("put");
   begin
      Write_Sample (Path);
      declare
         Bytes : constant Stream_Element_Array := Read_Bytes (Path);
      begin
         Ada.Directories.Delete_File (Path);
         Assert (Bytes = SAMPLE_UTF_8, "Put_Line must write C3 A9 E2 86 92 0A");
      end;
   end Test_Put_Line_Writes_UTF_8;

   procedure Test_Round_Trip_Non_ASCII (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
      Path : constant String := Make_Path ("round_trip");
      File : TIO.File_Type;
      Line : String_Type;
   begin
      Write_Sample (Path);
      TIO.Open (File, TIO.In_File, Path);
      Line := TIO.Get_Line (File);
      TIO.Close (File);
      Ada.Directories.Delete_File (Path);
      Assert (To_Wide_Wide_String (Line) = SAMPLE, "Get_Line must return the code points written by Put_Line");
   end Test_Round_Trip_Non_ASCII;

   procedure Test_Get_Line_Invalid_UTF_8_Is_Total (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
      Path : constant String := Make_Path ("invalid");
      File : TIO.File_Type;
      Line : String_Type;
   begin
      --  "a", lone 0xE9 (not UTF-8), "b", LF
      Write_Bytes (Path, [16#61#, 16#E9#, 16#62#, 16#0A#]);
      TIO.Open (File, TIO.In_File, Path);
      Line := TIO.Get_Line (File);
      TIO.Close (File);
      Ada.Directories.Delete_File (Path);
      Assert (Length (Line) > 0, "Get_Line must return the line, not raise");
   end Test_Get_Line_Invalid_UTF_8_Is_Total;

end Text_IO_Test;
