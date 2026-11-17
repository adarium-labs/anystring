-------------------------------------------------------------------------------
--  Anystrings Tests - Ingress Argv Test Suite Body (KI-046 L1)
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Command_Line;
with Ada.Directories;
with Ada.Strings.Fixed;
with Ada.Text_IO;
with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with GNAT.OS_Lib;
with Ingress_Vectors;

package body Ingress_Argv_Test is

   function Trim (N : Natural) return String is
   begin
      return Ada.Strings.Fixed.Trim (Natural'Image (N), Ada.Strings.Both);
   end Trim;

   --  Directory of this test program: the probe programs are built there.
   function Bin_Dir return String is
   begin
      return Ada.Directories.Containing_Directory (Ada.Command_Line.Command_Name);
   end Bin_Dir;

   --  Runs the probe with Raw as argv[0] and as argv[1], and compares the two
   --  lines it prints with the Table I expectations.
   procedure Check_Argv_Row
     (Id        : String;
      Input_Hex : String;
      Cps_Hex   : String;
      Valid     : Boolean;
      CPL       : Natural;
      Len_Std   : Natural;
      Len_Wide  : Natural;
      Len_Other : Natural)
   is
      pragma Unreferenced (Valid);
      Raw      : constant String := Ingress_Vectors.Bytes (Input_Hex);
      Want     : constant Wide_Wide_String := Ingress_Vectors.Code_Points (Cps_Hex);
      Len_Want : constant Natural :=
        Ingress_Vectors.Expected_Length (Len_Std, Len_Wide, Len_Other);
      Dir      : constant String := Bin_Dir;
      Out_File : constant String := Dir & "/ingress_argv_" & Id & ".out";
      Expected : constant String :=
        Ingress_Vectors.Hex_Image (Want) & " " & Trim (CPL) & " " & Trim (Len_Want);
      Args     : constant GNAT.OS_Lib.Argument_List :=
        [1 => new String'(Dir & "/ingress_probe"),
         2 => new String'(Raw),
         3 => new String'(Raw)];
      Ok       : Boolean;
      Code     : Integer;
      File     : Ada.Text_IO.File_Type;
   begin
      GNAT.OS_Lib.Spawn
        (Program_Name => Dir & "/argv0_exec",
         Args         => Args,
         Output_File  => Out_File,
         Success      => Ok,
         Return_Code  => Code,
         Err_To_Out   => True);
      Assert (Ok and then Code = 0, Id & ": argv0_exec ran the probe");

      Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Out_File);
      declare
         Cmd_Line : constant String := Ada.Text_IO.Get_Line (File);
         Arg_Line : constant String := Ada.Text_IO.Get_Line (File);
      begin
         Ada.Text_IO.Close (File);
         Assert (Cmd_Line = "CMD " & Expected,
                 Id & ": argv[0] (Command_Name): " & Cmd_Line);
         Assert (Arg_Line = "ARG " & Expected,
                 Id & ": argv[1] (Argument): " & Arg_Line);
      end;
      Ada.Directories.Delete_File (Out_File);
   end Check_Argv_Row;

   procedure Test_Table_I_Argv_And_Command_Name
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Ingress_Vectors.For_Each_Row (Check_Argv_Row'Access);
   end Test_Table_I_Argv_And_Command_Name;

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Ingress Argv (KI-046 L1) Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine
        (T, (Routine      => Test_Table_I_Argv_And_Command_Name'Access,
             Routine_Name => AUnit.Format ("Table I: argv[1] and argv[0] through the probe")));
   end Register_Tests;

end Ingress_Argv_Test;
