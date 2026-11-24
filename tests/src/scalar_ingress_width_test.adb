-------------------------------------------------------------------------------
--  Anystrings Tests - Scalar Ingress Width Test Suite Body
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with String_Types;
with String_Types.Width;
with Ingress_Vectors;

package body Scalar_Ingress_Width_Test is

   subtype Char is String_Types.Character_Type;
   subtype Str  is String_Types.String_Type;
   subtype Side is String_Types.Width.Pad_Side;
   use type String_Types.Width.Pad_Side;

   Sides : constant array (1 .. 3) of Side :=
     [String_Types.Width.Left, String_Types.Width.Right, String_Types.Width.Both];

   function Is_Scalar (CP : Natural) return Boolean
   is (CP <= 16#10_FFFF# and then CP not in 16#D800# .. 16#DFFF#);

   --  True when the backend's Character_Type can hold code point CP.
   function Representable (CP : Natural) return Boolean
   is (CP <= Char'Pos (Char'Last));

   function Code_Points_Of (S : Str) return Wide_Wide_String
   is (String_Types.To_Wide_Wide_String (S));

   --  Pad_To_Width ("a", 4, Pad, Side): three padding cells around one "a".
   --  The padding is the character itself when it is scalar, U+FFFD otherwise.
   procedure Check_Side (CP : Natural; Pad_Side : Side; Id : String) is
      Base    : constant Str := String_Types.To_String_Type ("a");
      Pad_Cp  : constant Natural := (if Is_Scalar (CP) then CP else 16#FFFD#);
      P       : constant Wide_Wide_String := (1 => Wide_Wide_Character'Val (Pad_Cp));
      A       : constant Wide_Wide_String := Ingress_Vectors.Code_Points ("61");
      Want    : Wide_Wide_String (1 .. 4);
      Got     : constant Wide_Wide_String :=
        Code_Points_Of (String_Types.Width.Pad_To_Width (Base, 4, Char'Val (CP), Pad_Side));
   begin
      if Pad_Side = String_Types.Width.Left then
         Want := P & P & P & A;
      elsif Pad_Side = String_Types.Width.Right then
         Want := A & P & P & P;
      else
         Want := P & A & P & P;
      end if;

      Assert (Got = Want, Id & ": Pad_To_Width code points");
      for C of Got loop
         Assert (Is_Scalar (Wide_Wide_Character'Pos (C)),
                 Id & ": Pad_To_Width stored a non-scalar code point");
      end loop;
   end Check_Side;

   procedure Test_Pad_Scalar_All_Sides
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      for S of Sides loop
         Check_Side (16#20#, S, "W1 space");
         Check_Side (16#78#, S, "W2 x");
         if Representable (16#E9#) and then Char'Pos (Char'Last) > 16#FF# then
            Check_Side (16#E9#, S, "W3 U+00E9");
         end if;
      end loop;
   end Test_Pad_Scalar_All_Sides;

   procedure Test_Pad_Non_Scalar_All_Sides
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      --  Representable is False on standard: nothing to check there.
      for S of Sides loop
         if Representable (16#D800#) then
            Check_Side (16#D800#, S, "W4 surrogate U+D800");
         end if;
         if Representable (16#DFFF#) then
            Check_Side (16#DFFF#, S, "W5 surrogate U+DFFF");
         end if;
         if Representable (16#110000#) then
            Check_Side (16#110000#, S, "W6 U+110000");
         end if;
      end loop;
   end Test_Pad_Non_Scalar_All_Sides;

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Scalar Ingress (Pad_To_Width padding, width build)");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine
        (T, (Routine      => Test_Pad_Scalar_All_Sides'Access,
             Routine_Name => AUnit.Format ("Pad_To_Width: scalar pad unchanged on all sides")));
      Add_Routine
        (T, (Routine      => Test_Pad_Non_Scalar_All_Sides'Access,
             Routine_Name => AUnit.Format ("Pad_To_Width: non-scalar pad becomes U+FFFD on all sides")));
   end Register_Tests;

end Scalar_Ingress_Width_Test;
