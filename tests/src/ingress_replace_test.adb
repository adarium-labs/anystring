-------------------------------------------------------------------------------
--  Anystrings Tests - Ingress Replacement Test Suite Body (KI-046 L1)
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Environment_Variables;
with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with Anystrings_UTF_8_Replace;
with Anystrings_UTF_8_Validate;
with String_Types;
with String_Types.Environment;
with Ingress_Vectors;

package body Ingress_Replace_Test is

   --  Environment variable used for the in-process environment rows.
   Probe_Var : constant String := "ANYSTRING_INGRESS_PROBE";

   --------------------------------------------------------------------------
   --  Table I, in-process: the shared decoder, the environment ingress and
   --  the checked From_UTF_8 (rows of Ingress_Vectors.For_Each_Row).

   procedure Check_Row
     (Id        : String;
      Input_Hex : String;
      Cps_Hex   : String;
      Valid     : Boolean;
      CPL       : Natural;
      Len_Std   : Natural;
      Len_Wide  : Natural;
      Len_Other : Natural)
   is
      Raw      : constant String := Ingress_Vectors.Bytes (Input_Hex);
      Want     : constant Wide_Wide_String := Ingress_Vectors.Code_Points (Cps_Hex);
      Len_Want : constant Natural :=
        Ingress_Vectors.Expected_Length (Len_Std, Len_Wide, Len_Other);
      Name     : constant String_Types.String_Type :=
        String_Types.To_String_Type (Probe_Var);
      Checked  : constant String_Types.UTF_8_Decode_Result :=
        String_Types.From_UTF_8 (Raw);
   begin
      --  Algorithm R on its own.
      Assert (Anystrings_UTF_8_Replace.Decode_Replacing (Raw) = Want,
              Id & ": Decode_Replacing code points");
      Assert (Anystrings_UTF_8_Replace.Code_Point_Count (Raw) = CPL,
              Id & ": Code_Point_Count");

      --  Environment ingress through the facade.
      Ada.Environment_Variables.Set (Probe_Var, Raw);
      Assert (String_Types.Environment.Env_Exists (Name),
              Id & ": variable present after ingress");
      declare
         Value : constant String_Types.String_Type :=
           String_Types.Environment.Get_Env (Name);
      begin
         Assert (String_Types.To_Wide_Wide_String (Value) = Want,
                 Id & ": environment code points");
         Assert (String_Types.Code_Point_Length (Value) = CPL,
                 Id & ": environment Code_Point_Length");
         Assert (String_Types.Length (Value) = Len_Want,
                 Id & ": environment Length on this backend");
      end;

      --  Checked From_UTF_8: Ok for well-formed rows, an error otherwise.
      if Valid then
         Assert (String_Types.Is_Ok (Checked), Id & ": checked From_UTF_8 is Ok");
         Assert (String_Types.To_Wide_Wide_String (String_Types.Get_Value (Checked)) = Want,
                 Id & ": checked From_UTF_8 code points");
      else
         Assert (not String_Types.Is_Ok (Checked),
                 Id & ": checked From_UTF_8 is an error (contract unchanged)");
      end if;
   end Check_Row;

   procedure Test_Table_I_Environment_And_Checked
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Ingress_Vectors.For_Each_Row (Check_Row'Access);
      Ada.Environment_Variables.Clear (Probe_Var);
   end Test_Table_I_Environment_And_Checked;

   --------------------------------------------------------------------------
   --  Table II: the From side (policy P), code points in, code points out.

   procedure Check_From (Id, Input_Hex, Want_Hex : String; Std_Length : Natural) is
      Input  : constant Wide_Wide_String := Ingress_Vectors.Code_Points (Input_Hex);
      Want   : constant Wide_Wide_String := Ingress_Vectors.Code_Points (Want_Hex);
      Stored : constant String_Types.String_Type := String_Types.From_Wide_Wide_String (Input);
   begin
      Assert (String_Types.To_Wide_Wide_String (Stored) = Want,
              Id & ": From_Wide_Wide_String code points");
      Assert (String_Types.Code_Point_Length (Stored) = Want'Length,
              Id & ": Code_Point_Length of the stored value");
      if Ingress_Vectors.Backend_Class = 1 then
         Assert (String_Types.Length (Stored) = Std_Length,
                 Id & ": standard Length counts bytes");
      end if;
   end Check_From;

   procedure Test_Table_II_From_Side
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Check_From ("F01", "61 D800 62", "61 FFFD 62", 5);
      Check_From ("F02", "DFFF", "FFFD", 3);
      Check_From ("F03", "110000", "FFFD", 3);
      Check_From ("F04", "10FFFF", "10FFFF", 4);
      Check_From ("F05", "FEFF 61", "FEFF 61", 4);
      Check_From ("F06", "FEFF FEFF", "FEFF FEFF", 6);
   end Test_Table_II_From_Side;

   --------------------------------------------------------------------------
   --  Table III: the variable is unset (E1) or set to the empty string (E2).

   procedure Test_Table_III_Environment_States
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Name : constant String_Types.String_Type := String_Types.To_String_Type (Probe_Var);
   begin
      Ada.Environment_Variables.Clear (Probe_Var);
      Assert (not String_Types.Environment.Env_Exists (Name),
              "E1: an unset variable is absent");
      Assert (String_Types.Length (String_Types.Environment.Get_Env (Name)) = 0,
              "E1: Get_Env of an unset variable is empty");

      Ada.Environment_Variables.Set (Probe_Var, "");
      Assert (String_Types.Environment.Env_Exists (Name),
              "E2: a variable set to the empty string is present");
      Assert (String_Types.Length (String_Types.Environment.Get_Env (Name)) = 0,
              "E2: the empty value is empty");
      Ada.Environment_Variables.Clear (Probe_Var);
   end Test_Table_III_Environment_States;

   --------------------------------------------------------------------------
   --  Storage facts (Table IV) and the Code_Point_Length contract.

   procedure Check_Invariant (S : String_Types.String_Type; Id : String) is
   begin
      Assert (String_Types.Code_Point_Length (S) = String_Types.To_Wide_Wide_String (S)'Length,
              Id & ": Code_Point_Length = To_Wide_Wide_String'Length");
   end Check_Invariant;

   procedure Test_Storage_And_Code_Point_Length
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      --  Well-formed storage inputs: accepted by To_String_Type on every back end.
      Check_Invariant (String_Types.To_String_Type (Ingress_Vectors.Bytes ("C3 A9")), "valid-2-byte");
      Check_Invariant (String_Types.To_String_Type (Ingress_Vectors.Bytes ("F0 9F 98 80")), "valid-4-byte");
      Check_Invariant (String_Types.To_String_Type (Ingress_Vectors.Bytes ("EF BB BF 61")), "BOM");
      Check_Invariant (String_Types.To_String_Type ("abc"), "ASCII");

      --  Ill-formed storage inputs: only standard stores raw bytes. On the other
      --  back ends To_String_Type rejects or reads them differently (uxstring
      --  raises in UXStrings.From_UTF_8), so they are not part of this gate.
      if Ingress_Vectors.Backend_Class = 1 then
         Check_Invariant (String_Types.To_String_Type (Ingress_Vectors.Bytes ("E9")), "S1-bytes");
         Check_Invariant (String_Types.To_String_Type (Ingress_Vectors.Bytes ("E2 82 61")), "S2-bytes");
         Check_Invariant (String_Types.To_String_Type (Ingress_Vectors.Bytes ("ED A0 80")), "CESU");
      end if;

      --  Table IV on the standard back end: a lone Latin-1 byte and a broken
      --  sequence are replaced by R (one U+FFFD per maximal subpart).
      if Ingress_Vectors.Backend_Class = 1 then
         Assert (String_Types.To_Wide_Wide_String
                   (String_Types.To_String_Type (Ingress_Vectors.Bytes ("E9")))
                 = Ingress_Vectors.Code_Points ("FFFD"),
                 "S1: standard E9 is one U+FFFD");
         Assert (String_Types.To_Wide_Wide_String
                   (String_Types.To_String_Type (Ingress_Vectors.Bytes ("E2 82 61")))
                 = Ingress_Vectors.Code_Points ("FFFD 61"),
                 "S2: standard E2 82 61 is U+FFFD then a");
      end if;
   end Test_Storage_And_Code_Point_Length;

   --------------------------------------------------------------------------
   --  Property gate of the replacement unit: strings of length 1 to 4 over a
   --  boundary alphabet, and every 2-byte string, checked against a reference
   --  decoder written from Unicode Table 3-7 (it shares no code with the unit).

   Symbols : constant array (Positive range <>) of Natural :=
     [16#00#, 16#41#, 16#7F#, 16#80#, 16#8F#, 16#90#, 16#9F#, 16#A0#, 16#BF#,
      16#C0#, 16#C1#, 16#C2#, 16#DF#, 16#E0#, 16#E1#, 16#EC#, 16#ED#, 16#EE#,
      16#EF#, 16#F0#, 16#F1#, 16#F3#, 16#F4#, 16#F5#, 16#FF#];

   --  Lead byte rule: whether B starts a sequence, the number of continuation
   --  bytes, and the range of the first continuation byte (the others are
   --  80..BF).
   procedure Lead_Rule
     (B : Natural; Ok : out Boolean; Need : out Natural; Lo, Hi : out Natural) is
   begin
      Ok   := True;
      Need := 0;
      Lo   := 16#80#;
      Hi   := 16#BF#;
      if B in 16#C2# .. 16#DF# then
         Need := 1;
      elsif B = 16#E0# then
         Need := 2;
         Lo   := 16#A0#;
      elsif B in 16#E1# .. 16#EC# | 16#EE# .. 16#EF# then
         Need := 2;
      elsif B = 16#ED# then
         Need := 2;
         Hi   := 16#9F#;
      elsif B = 16#F0# then
         Need := 3;
         Lo   := 16#90#;
      elsif B in 16#F1# .. 16#F3# then
         Need := 3;
      elsif B = 16#F4# then
         Need := 3;
         Hi   := 16#8F#;
      else
         Ok := False;
      end if;
   end Lead_Rule;

   function Reference (S : String) return Wide_Wide_String is
      Result : Wide_Wide_String (1 .. S'Length);
      Count  : Natural := 0;
      I      : Natural := S'First;
   begin
      while I <= S'Last loop
         declare
            B    : constant Natural := Character'Pos (S (I));
            Ok   : Boolean;
            Need : Natural;
            Lo   : Natural;
            Hi   : Natural;
         begin
            Count := Count + 1;
            if B < 16#80# then
               Result (Count) := Wide_Wide_Character'Val (B);
               I := I + 1;
            else
               Lead_Rule (B, Ok, Need, Lo, Hi);
               if not Ok then
                  Result (Count) := Wide_Wide_Character'Val (16#FFFD#);
                  I := I + 1;
               else
                  declare
                     CP : Natural :=
                       (if Need = 1 then B mod 16#20#
                        elsif Need = 2 then B mod 16#10#
                        else B mod 16#08#);
                     K  : Natural := 0;
                  begin
                     while K < Need and then I + K + 1 <= S'Last loop
                        declare
                           C : constant Natural := Character'Pos (S (I + K + 1));
                           L : constant Natural := (if K = 0 then Lo else 16#80#);
                           H : constant Natural := (if K = 0 then Hi else 16#BF#);
                        begin
                           exit when C < L or else C > H;
                           CP := CP * 64 + C mod 64;
                           K  := K + 1;
                        end;
                     end loop;
                     if K = Need then
                        Result (Count) := Wide_Wide_Character'Val (CP);
                        I := I + Need + 1;
                     else
                        Result (Count) := Wide_Wide_Character'Val (16#FFFD#);
                        I := I + K + 1;
                     end if;
                  end;
               end if;
            end if;
         end;
      end loop;
      return Result (1 .. Count);
   end Reference;

   procedure Check_String (S : String) is
      R    : constant Wide_Wide_String := Anystrings_UTF_8_Replace.Decode_Replacing (S);
      Rep  : constant String := Anystrings_UTF_8_Replace.Replace_Ill_Formed (S);
      Well : constant Boolean := Anystrings_UTF_8_Validate.Validate (S).Is_Ok;
   begin
      Assert (R = Reference (S), "property: decode equals the reference decoder");
      Assert (Well = (Rep = S), "property: valid iff the replacement is the identity");
      Assert (Anystrings_UTF_8_Validate.Validate (Rep).Is_Ok,
              "property: the replacement is well formed");
      Assert (Anystrings_UTF_8_Replace.Code_Point_Count (S) = R'Length,
              "property: Code_Point_Count equals the decoded length");
   end Check_String;

   procedure Enumerate (Len : Positive) is
      Total : constant Natural := Symbols'Length ** Len;
      Buf   : String (1 .. Len);
   begin
      for N in 0 .. Total - 1 loop
         declare
            Code : Natural := N;
         begin
            for P in reverse 1 .. Len loop
               Buf (P) := Character'Val (Symbols (Symbols'First + Code mod Symbols'Length));
               Code := Code / Symbols'Length;
            end loop;
         end;
         Check_String (Buf);
      end loop;
   end Enumerate;

   procedure Test_Property_Gate
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      for Len in 1 .. 4 loop
         Enumerate (Len);
      end loop;

      for B1 in 0 .. 255 loop
         for B2 in 0 .. 255 loop
            declare
               Pair : constant String :=
                 Character'Val (B1) & Character'Val (B2);
            begin
               Check_String (Pair);
            end;
         end loop;
      end loop;
   end Test_Property_Gate;

   --------------------------------------------------------------------------

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Ingress Replacement (KI-046 L1) Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine
        (T, (Routine      => Test_Table_I_Environment_And_Checked'Access,
             Routine_Name => AUnit.Format ("Table I: environment ingress and checked From_UTF_8")));
      Add_Routine
        (T, (Routine      => Test_Table_II_From_Side'Access,
             Routine_Name => AUnit.Format ("Table II: From side code points (policy P)")));
      Add_Routine
        (T, (Routine      => Test_Table_III_Environment_States'Access,
             Routine_Name => AUnit.Format ("Table III: unset and empty environment variable")));
      Add_Routine
        (T, (Routine      => Test_Storage_And_Code_Point_Length'Access,
             Routine_Name => AUnit.Format ("Table IV: storage facts and Code_Point_Length")));
      Add_Routine
        (T, (Routine      => Test_Property_Gate'Access,
             Routine_Name => AUnit.Format ("Property gate of the replacement unit")));
   end Register_Tests;

end Ingress_Replace_Test;
