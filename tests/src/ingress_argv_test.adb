-------------------------------------------------------------------------------
--  Anystrings Tests - Ingress Argv Test Suite Body (KI-046 L1)
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Characters.Latin_1;
with Ada.Command_Line;
with Ada.Directories;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;
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

   --  Runs the probe with Raw as argv[0] and as argv[1] (through argv0_exec),
   --  and compares the two lines it prints with the Table I expectations.
   --  The child's output goes to a file with a name unique to this run
   --  (Ingress_Vectors.Run_Capture), so concurrent runs cannot collide.
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
      LF       : constant Character := Ada.Characters.Latin_1.LF;
      Raw      : constant String := Ingress_Vectors.Bytes (Input_Hex);
      Want     : constant Wide_Wide_String := Ingress_Vectors.Code_Points (Cps_Hex);
      Len_Want : constant Natural :=
        Ingress_Vectors.Expected_Length (Len_Std, Len_Wide, Len_Other);
      Dir      : constant String := Bin_Dir;
      Args     : constant GNAT.OS_Lib.Argument_List :=
        [1 => new String'(Dir & "/ingress_probe"),
         2 => new String'(Raw),
         3 => new String'(Raw)];
      Expected : constant String :=
        Ingress_Vectors.Hex_Image (Want) & " " & Trim (CPL) & " " & Trim (Len_Want);
      Output   : Ada.Strings.Unbounded.Unbounded_String;
      RC       : Integer;
      Ok       : Boolean;
   begin
      Ingress_Vectors.Run_Capture
        (Program     => Dir & "/argv0_exec",
         Args        => Args,
         Output      => Output,
         Return_Code => RC,
         Success     => Ok);
      Assert (Ok and then RC = 0, Id & ": argv0_exec ran the probe");
      Assert (Ada.Strings.Unbounded.To_String (Output) =
                "CMD " & Expected & LF & "ARG " & Expected & LF,
              Id & ": argv[0] and argv[1] lines: "
              & Ada.Strings.Unbounded.To_String (Output));
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
