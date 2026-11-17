-------------------------------------------------------------------------------
--  Anystrings Tests - Ingress Environment Child-Process Test Suite Body
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Characters.Latin_1;
with Ada.Command_Line;
with Ada.Directories;
with Ada.Environment_Variables;
with Ada.Strings.Unbounded;
with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with GNAT.OS_Lib;
with Ingress_Vectors;

package body Ingress_Env_Test is

   Prefix : constant String := "ANYSTRING_P3_";
   V_Name : constant String := "ANYSTRING_P3_V";
   LF     : constant Character := Ada.Characters.Latin_1.LF;

   function Bin_Dir return String is
   begin
      return Ada.Directories.Containing_Directory (Ada.Command_Line.Command_Name);
   end Bin_Dir;

   --  ASCII text as a Wide_Wide_String of the same code points.
   function Widen (S : String) return Wide_Wide_String is
      W : Wide_Wide_String (1 .. S'Length);
   begin
      for I in S'Range loop
         W (I - S'First + 1) := Wide_Wide_Character'Val (Character'Pos (S (I)));
      end loop;
      return W;
   end Widen;

   --  One Table I row, two children (value case, name case).
   procedure Check_Env_Row
     (Id        : String;
      Input_Hex : String;
      Cps_Hex   : String;
      Valid     : Boolean;
      CPL       : Natural;
      Len_Std   : Natural;
      Len_Wide  : Natural;
      Len_Other : Natural)
   is
      pragma Unreferenced (Valid, CPL, Len_Std, Len_Wide, Len_Other);
      Raw     : constant String := Ingress_Vectors.Bytes (Input_Hex);
      Want    : constant Wide_Wide_String := Ingress_Vectors.Code_Points (Cps_Hex);
      N_Name  : constant String := Prefix & Raw;
      Dir     : constant String := Bin_Dir;
      Program : constant String := Dir & "/ingress_probe";
      No_Args : constant GNAT.OS_Lib.Argument_List (1 .. 0) := [others => null];
      Output  : Ada.Strings.Unbounded.Unbounded_String;
      RC      : Integer;
      Ok      : Boolean;
   begin
      --  Value case: only ANYSTRING_P3_V, holding the malformed row as value.
      Ada.Environment_Variables.Clear (N_Name);
      Ada.Environment_Variables.Set (V_Name, Raw);
      Ingress_Vectors.Run_Capture
        (Program => Program, Args => No_Args, Output => Output,
         Return_Code => RC, Success => Ok);
      Ada.Environment_Variables.Clear (V_Name);
      Assert (Ok and then RC = 0, Id & " value case: the probe ran");
      declare
         Cps : constant String := Ingress_Vectors.Hex_Image (Want);
      begin
         Assert (Ada.Strings.Unbounded.To_String (Output) =
                   "GET " & Cps & " present" & LF
                   & "ITER1 " & Ingress_Vectors.Hex_Image (Widen (V_Name)) & " " & Cps & LF
                   & "ITER2 " & Ingress_Vectors.Hex_Image (Widen (V_Name)) & " " & Cps & LF,
                 Id & " value case (Get_Env and both Iterate_Env): "
                 & Ada.Strings.Unbounded.To_String (Output));
      end;

      --  Name case: only ANYSTRING_P3_<row>, holding the malformed row as the
      --  name suffix and as the value.
      Ada.Environment_Variables.Set (N_Name, Raw);
      Ingress_Vectors.Run_Capture
        (Program => Program, Args => No_Args, Output => Output,
         Return_Code => RC, Success => Ok);
      Ada.Environment_Variables.Clear (N_Name);
      Assert (Ok and then RC = 0, Id & " name case: the probe ran");
      declare
         Name_Cps : constant String := Ingress_Vectors.Hex_Image (Widen (Prefix) & Want);
         Cps      : constant String := Ingress_Vectors.Hex_Image (Want);
      begin
         Assert (Ada.Strings.Unbounded.To_String (Output) =
                   "GET - absent" & LF
                   & "ITER1 " & Name_Cps & " " & Cps & LF
                   & "ITER2 " & Name_Cps & " " & Cps & LF,
                 Id & " name case (Iterate_Env, both overloads): "
                 & Ada.Strings.Unbounded.To_String (Output));
      end;
   end Check_Env_Row;

   procedure Test_Env_Children_Through_Get_Env_And_Iterate_Env
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Ingress_Vectors.For_Each_Row (Check_Env_Row'Access);
   end Test_Env_Children_Through_Get_Env_And_Iterate_Env;

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Ingress Environment child processes (KI-046 fix round 1)");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine
        (T, (Routine      => Test_Env_Children_Through_Get_Env_And_Iterate_Env'Access,
             Routine_Name => AUnit.Format ("Malformed env names and values: Get_Env and both Iterate_Env overloads")));
   end Register_Tests;

end Ingress_Env_Test;
