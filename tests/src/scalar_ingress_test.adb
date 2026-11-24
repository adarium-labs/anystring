-------------------------------------------------------------------------------
--  Anystrings Tests - Scalar Ingress Test Suite Body
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with String_Types;
with Ingress_Vectors;

package body Scalar_Ingress_Test is

   subtype Char is String_Types.Character_Type;
   subtype Str  is String_Types.String_Type;

   --  U+FFFD as the one-element string every replacement must produce.
   Replacement : constant Wide_Wide_String := (1 => Wide_Wide_Character'Val (16#FFFD#));

   function Is_Scalar (CP : Natural) return Boolean
   is (CP <= 16#10_FFFF# and then CP not in 16#D800# .. 16#DFFF#);

   --  True when the backend's Character_Type can hold code point CP
   --  (standard: 0..255; wide_string: 0..FFFF; the others: all of
   --  Wide_Wide_Character).
   function Representable (CP : Natural) return Boolean
   is (CP <= Char'Pos (Char'Last));

   function Code_Points_Of (S : Str) return Wide_Wide_String
   is (String_Types.To_Wide_Wide_String (S));

   --  Each stored code point must be a Unicode scalar value.
   procedure Assert_All_Scalar (S : Str; Id : String) is
      WS : constant Wide_Wide_String := Code_Points_Of (S);
   begin
      for C of WS loop
         Assert (Is_Scalar (Wide_Wide_Character'Pos (C)),
                 Id & ": stored code point is not a scalar value");
      end loop;
   end Assert_All_Scalar;

   --------------------------------------------------------------------------
   --  A non-scalar Character_Type value is replaced by U+FFFD on every
   --  constructor and mutator that takes a character.

   procedure Check_Non_Scalar (CP : Natural; Id : String) is
      C    : constant Char := Char'Val (CP);
      Base : constant Str := String_Types.To_String_Type ("a");
      A    : constant Wide_Wide_String := Ingress_Vectors.Code_Points ("61");
   begin
      Assert (Code_Points_Of (String_Types.From_Character (C)) = Replacement,
              Id & ": From_Character");
      Assert (Code_Points_Of (String_Types.Append_Character (Base, C)) = A & Replacement,
              Id & ": Append_Character");
      Assert (Code_Points_Of (String_Types.Prepend_Character (C, Base)) = Replacement & A,
              Id & ": Prepend_Character");
      Assert (Code_Points_Of (String_Types."&" (Base, C)) = A & Replacement,
              Id & ": String & Character");
      Assert (Code_Points_Of (String_Types."&" (C, Base)) = Replacement & A,
              Id & ": Character & String");
      Assert (Code_Points_Of (String_Types.Head (Base, 3, C))
                = A & Replacement & Replacement,
              Id & ": Head pad");
      Assert (Code_Points_Of (String_Types.Tail (Base, 3, C))
                = Replacement & Replacement & A,
              Id & ": Tail pad");
      Assert (String_Types.Code_Point_Length (String_Types.From_Character (C)) = 1,
              Id & ": Code_Point_Length of the replacement");
   end Check_Non_Scalar;

   procedure Test_Non_Scalar_Characters_Replaced
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      --  Representable is False on standard: nothing to check there.
      if Representable (16#110000#) then
         Check_Non_Scalar (16#110000#, "N1 U+110000");
      end if;
      if Representable (16#D800#) then
         Check_Non_Scalar (16#D800#, "N2 surrogate U+D800");
      end if;
      if Representable (16#DFFF#) then
         Check_Non_Scalar (16#DFFF#, "N3 surrogate U+DFFF");
      end if;
   end Test_Non_Scalar_Characters_Replaced;

   --------------------------------------------------------------------------
   --  A scalar character passes through every constructor unchanged.

   procedure Check_Scalar (CP : Natural; Id : String) is
      C    : constant Char := Char'Val (CP);
      Base : constant Str := String_Types.To_String_Type ("a");
      A    : constant Wide_Wide_String := Ingress_Vectors.Code_Points ("61");
      V    : constant Wide_Wide_String := (1 => Wide_Wide_Character'Val (CP));
   begin
      Assert (Code_Points_Of (String_Types.From_Character (C)) = V,
              Id & ": From_Character");
      Assert (Code_Points_Of (String_Types.Append_Character (Base, C)) = A & V,
              Id & ": Append_Character");
      Assert (Code_Points_Of (String_Types.Prepend_Character (C, Base)) = V & A,
              Id & ": Prepend_Character");
      Assert (Code_Points_Of (String_Types."&" (Base, C)) = A & V,
              Id & ": String & Character");
      Assert (Code_Points_Of (String_Types."&" (C, Base)) = V & A,
              Id & ": Character & String");
      Assert (Code_Points_Of (String_Types.Head (Base, 2, C)) = A & V,
              Id & ": Head pad");
   end Check_Scalar;

   procedure Test_Scalar_Characters_Unchanged
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Check_Scalar (16#41#, "S1 ASCII");
      --  On standard a Character is one byte, so E9 and a 4-byte sequence are
      --  not single characters there; the rows run on the code-point backends.
      if Representable (16#E9#) and then Char'Pos (Char'Last) > 16#FF# then
         Check_Scalar (16#E9#, "S2 U+00E9");
      end if;
      if Representable (16#1F600#) then
         Check_Scalar (16#1F600#, "S3 U+1F600");
      end if;
   end Test_Scalar_Characters_Unchanged;

   --------------------------------------------------------------------------
   --  Latin-1 / native String inputs: no stored code point is a surrogate or
   --  above U+10FFFF. standard keeps raw bytes (documented), so it is skipped.

   procedure Test_Latin_1_Native_Strings_Scalar
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Base : constant Str := String_Types.To_String_Type ("a");
   begin
      if Char'Pos (Char'Last) <= 16#FF# then
         return;  --  standard: Latin-1 bytes are stored as given, see above.
      end if;
      for B in 0 .. 255 loop
         declare
            One : constant String (1 .. 1) := (1 => Character'Val (B));
         begin
            Assert_All_Scalar (String_Types.To_String_Type (One), "L1 To_String_Type byte");
            Assert_All_Scalar (String_Types."&" (Base, One), "L2 String & Latin-1");
            Assert_All_Scalar (String_Types."&" (One, Base), "L3 Latin-1 & String");
         end;
      end loop;
   end Test_Latin_1_Native_Strings_Scalar;

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Scalar Ingress (constructors and mutators, policy P)");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine
        (T, (Routine      => Test_Non_Scalar_Characters_Replaced'Access,
             Routine_Name => AUnit.Format ("Non-scalar characters become U+FFFD")));
      Add_Routine
        (T, (Routine      => Test_Scalar_Characters_Unchanged'Access,
             Routine_Name => AUnit.Format ("Scalar characters pass through unchanged")));
      Add_Routine
        (T, (Routine      => Test_Latin_1_Native_Strings_Scalar'Access,
             Routine_Name => AUnit.Format ("Latin-1 and native strings store scalars only")));
   end Register_Tests;

end Scalar_Ingress_Test;
