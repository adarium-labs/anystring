-------------------------------------------------------------------------------
--  Anystrings Tests - Case Mapping (To_Lower / To_Upper) Test Suite Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with String_Types;     use String_Types;

package body Case_Mapping_Test is

   --  Code point from its value; avoids non-ASCII source literals.
   function Cp (Code : Natural) return Wide_Wide_Character is
   begin
      return Wide_Wide_Character'Val (Code);
   end Cp;

   --  True on a backend whose Length counts UTF-8 bytes (standard).
   Byte_Counting : constant Boolean :=
     Length (From_Wide_Wide_String (Wide_Wide_String'(1 => Cp (16#E9#)))) = 2;

   --  True on a backend whose To_Lower maps U+00C9 to U+00E9. Standard, vss and
   --  uxstring do; wide_string and wide_wide_string are ASCII-only today.
   Maps_Non_ASCII : constant Boolean :=
     To_Wide_Wide_String (To_Lower (From_Wide_Wide_String (Wide_Wide_String'(1 => Cp (16#C9#)))))
     = Wide_Wide_String'(1 => Cp (16#E9#));

   --  True on a backend whose To_Lower is the full mapping (U+0130 gives
   --  U+0069 U+0307). Standard and vss do; uxstring maps per code point with
   --  the GNAT tables and wide_string / wide_wide_string are ASCII-only.
   Full_Case_Mapping : constant Boolean :=
     To_Wide_Wide_String (To_Lower (From_Wide_Wide_String (Wide_Wide_String'(1 => Cp (16#130#)))))
     = Wide_Wide_String'(Cp (16#69#), Cp (16#307#));

   --  Stored bytes of S. Only called when Byte_Counting is True, where each
   --  element is one byte.
   function Bytes (S : String_Type) return String is
      R : String (1 .. Length (S));
   begin
      for I in R'Range loop
         R (I) := Character'Val (Character_Type'Pos (Element (S, I)));
      end loop;
      return R;
   end Bytes;

   --  Map Input with To_Upper (Upper) or To_Lower (not Upper) and compare the
   --  code points with Expected.
   procedure Expect_Map
     (Input    : Wide_Wide_String;
      Expected : Wide_Wide_String;
      Upper    : Boolean;
      Label    : String)
   is
      Source : constant String_Type := From_Wide_Wide_String (Input);
      Result : constant String_Type := (if Upper then To_Upper (Source) else To_Lower (Source));
   begin
      Assert (To_Wide_Wide_String (Result) = Expected, Label & ": unexpected code points");
   end Expect_Map;

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Case Mapping (To_Lower / To_Upper) Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine
        (T,
         (Routine      => Test_ASCII_Unchanged_By_Case_Mapping'Access,
          Routine_Name => AUnit.Format ("ASCII is mapped and round-trips")));
      Add_Routine
        (T,
         (Routine      => Test_Latin_1_Letter_Mapping'Access,
          Routine_Name => AUnit.Format ("U+00C9 <-> U+00E9 (A-acute)")));
      Add_Routine
        (T, (Routine => Test_Round_Trip'Access, Routine_Name => AUnit.Format ("To_Upper (To_Lower (x)) = x")));
      Add_Routine
        (T,
         (Routine      => Test_Full_Mapping_Changes_Length'Access,
          Routine_Name => AUnit.Format ("Full mapping: U+0130 and U+00DF change length")));
      Add_Routine
        (T,
         (Routine      => Test_Final_Sigma'Access,
          Routine_Name => AUnit.Format ("Final_Sigma: word-final, before space, initial, isolated")));
      Add_Routine
        (T,
         (Routine      => Test_Standard_Valid_UTF_8_Bytes'Access,
          Routine_Name => AUnit.Format ("standard: result bytes are valid UTF-8")));
      Add_Routine
        (T,
         (Routine      => Test_Standard_Ill_Formed_Bytes_Kept'Access,
          Routine_Name => AUnit.Format ("standard: ill-formed bytes kept unchanged")));
      Add_Routine
        (T,
         (Routine      => Test_Standard_Overlong_And_Out_Of_Range_Kept'Access,
          Routine_Name => AUnit.Format ("standard: overlong, surrogate and out-of-range sequences kept")));
   end Register_Tests;

   procedure Test_ASCII_Unchanged_By_Case_Mapping (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Expect_Map ("Hello, World 123!", "hello, world 123!", Upper => False, Label => "ASCII lower");
      Expect_Map ("Hello, World 123!", "HELLO, WORLD 123!", Upper => True, Label => "ASCII upper");
   end Test_ASCII_Unchanged_By_Case_Mapping;

   procedure Test_Latin_1_Letter_Mapping (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
      A_Acute_Upper : constant Wide_Wide_String := (1 => Cp (16#C9#));
      A_Acute_Lower : constant Wide_Wide_String := (1 => Cp (16#E9#));
   begin
      if Maps_Non_ASCII then
         Expect_Map (A_Acute_Upper, A_Acute_Lower, Upper => False, Label => "U+00C9 lower");
         Expect_Map (A_Acute_Lower, A_Acute_Upper, Upper => True, Label => "U+00E9 upper");
      else
         --  ASCII-only backend: the letter is not mapped (existing behaviour).
         Expect_Map (A_Acute_Upper, A_Acute_Upper, Upper => False, Label => "U+00C9 lower (ASCII-only)");
         Expect_Map (A_Acute_Lower, A_Acute_Lower, Upper => True, Label => "U+00E9 upper (ASCII-only)");
      end if;
   end Test_Latin_1_Letter_Mapping;

   procedure Test_Round_Trip (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
      Input   : constant Wide_Wide_String :=
        Wide_Wide_String'(Cp (16#C0#), Cp (16#C9#), Cp (16#CE#));
      Source  : constant String_Type := From_Wide_Wide_String (Input);
      Lowered : constant String_Type := To_Lower (Source);
      Back    : constant String_Type := To_Upper (Lowered);
   begin
      Assert (To_Wide_Wide_String (Back) = Input, "To_Upper (To_Lower (x)) /= x");
      if Maps_Non_ASCII then
         Expect_Map
           (Input,
            Wide_Wide_String'(Cp (16#E0#), Cp (16#E9#), Cp (16#EE#)),
            Upper => False,
            Label => "U+00C0 U+00C9 U+00CE lower");
      end if;
      if Byte_Counting then
         Assert (UTF_8_Is_Valid (Bytes (Lowered)), "lower-case result is not valid UTF-8");
         Assert (UTF_8_Is_Valid (Bytes (Back)), "round-trip result is not valid UTF-8");
         Assert (Bytes (Back) = Bytes (Source), "round-trip bytes differ");
      end if;
   end Test_Round_Trip;

   procedure Test_Full_Mapping_Changes_Length (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
      Dotted_I : constant Wide_Wide_String := (1 => Cp (16#130#));
      Sharp_S  : constant Wide_Wide_String := (1 => Cp (16#DF#));
   begin
      --  Full case mapping, as in vss and standard: U+0130 lower-cases to
      --  U+0069 U+0307 (two code points), and U+00DF upper-cases to "SS".
      --  The result may be longer than the input, so To_Lower and To_Upper have
      --  no Length postcondition.
      --  Not asserted on uxstring and wide backends (see Full_Case_Mapping):
      --  they do not give the full mapping, and this suite does not pin them.
      if Full_Case_Mapping then
         Expect_Map
           (Dotted_I,
            Wide_Wide_String'(Cp (16#69#), Cp (16#307#)),
            Upper => False,
            Label => "U+0130 lower (full)");
         Expect_Map (Sharp_S, Wide_Wide_String'("SS"), Upper => True, Label => "U+00DF upper (full)");
      end if;
   end Test_Full_Mapping_Changes_Length;

   --  Final_Sigma (SpecialCasing): a capital sigma at the end of a word lower-
   --  cases to U+03C2; elsewhere to U+03C3. Asserted where Full_Case_Mapping
   --  holds (standard and vss, which agree on these inputs).
   procedure Test_Final_Sigma (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
      Omicron : constant Wide_Wide_Character := Cp (16#39F#);
      Delta_C : constant Wide_Wide_Character := Cp (16#394#);
      Sigma   : constant Wide_Wide_Character := Cp (16#3A3#);
      Alpha   : constant Wide_Wide_Character := Cp (16#391#);
      Beta    : constant Wide_Wide_Character := Cp (16#392#);
      Space   : constant Wide_Wide_Character := Cp (16#20#);
   begin
      if Full_Case_Mapping then
         --  "ΟΔΟΣ" (end of word) -> "οδος"
         Expect_Map
           (Omicron & Delta_C & Omicron & Sigma,
            Cp (16#3BF#) & Cp (16#3B4#) & Cp (16#3BF#) & Cp (16#3C2#),
            Upper => False,
            Label => "final sigma at end of word");
         --  "ΑΣ Β": the space is not case-ignorable, so the sigma is final.
         Expect_Map
           (Alpha & Sigma & Space & Beta,
            Cp (16#3B1#) & Cp (16#3C2#) & Space & Cp (16#3B2#),
            Upper => False,
            Label => "final sigma before a space");
         --  "ΣΑ": no cased letter before the sigma, so it is not final.
         Expect_Map
           (Sigma & Alpha,
            Cp (16#3C3#) & Cp (16#3B1#),
            Upper => False,
            Label => "initial sigma");
         Expect_Map
           (Wide_Wide_String'(1 => Sigma),
            Wide_Wide_String'(1 => Cp (16#3C3#)),
            Upper => False,
            Label => "isolated sigma");
         --  Upper case has no context: U+03C2 -> U+03A3.
         Expect_Map
           (Wide_Wide_String'(1 => Cp (16#3C2#)),
            Wide_Wide_String'(1 => Sigma),
            Upper => True,
            Label => "final sigma upper");
      end if;
   end Test_Final_Sigma;

   procedure Test_Standard_Valid_UTF_8_Bytes (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      if Byte_Counting then
         declare
            E_Acute : constant String_Type := From_Wide_Wide_String (Wide_Wide_String'(1 => Cp (16#C9#)));
            Lowered : constant String_Type := To_Lower (E_Acute);
         begin
            Assert (Bytes (E_Acute) = Character'Val (16#C3#) & Character'Val (16#89#), "U+00C9 is not C3 89");
            Assert
              (Bytes (Lowered) = Character'Val (16#C3#) & Character'Val (16#A9#),
               "To_Lower (U+00C9) is not C3 A9");
            Assert (Bytes (To_Upper (Lowered)) = Bytes (E_Acute), "To_Upper (U+00E9) is not C3 89");
         end;
      end if;
   end Test_Standard_Valid_UTF_8_Bytes;

   procedure Test_Standard_Ill_Formed_Bytes_Kept (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
      C9 : constant Character := Character'Val (16#C9#);
      C0 : constant Character := Character'Val (16#C0#);
      C3 : constant Character := Character'Val (16#C3#);
      B89 : constant Character := Character'Val (16#89#);
      A9  : constant Character := Character'Val (16#A9#);
   begin
      if Byte_Counting then
         --  Latin-1 bytes C9 C0 are not UTF-8: they are copied, the ASCII around
         --  them is mapped.
         declare
            Mixed : constant String_Type := To_String_Type ("A" & C9 & C0 & "b");
         begin
            Assert (Bytes (To_Lower (Mixed)) = "a" & C9 & C0 & "b", "lower: ill-formed bytes changed");
            Assert (Bytes (To_Upper (Mixed)) = "A" & C9 & C0 & "B", "upper: ill-formed bytes changed");
         end;

         --  A truncated lead byte at the end of the string.
         Assert
           (Bytes (To_Lower (To_String_Type ("C" & C3))) = "c" & C3,
            "truncated lead byte changed");

         --  A well-formed letter after ill-formed bytes is still mapped.
         Assert
           (Bytes (To_Lower (To_String_Type (C9 & C3 & B89 & "X"))) = C9 & C3 & A9 & "x",
            "letter after ill-formed bytes not mapped");
      end if;
   end Test_Standard_Ill_Formed_Bytes_Kept;

   procedure Test_Standard_Overlong_And_Out_Of_Range_Kept (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);

      --  Raw is not canonical UTF-8, so the operations must return it unchanged.
      procedure Check_Kept (Raw : String; Label : String) is
         Source : constant String_Type := To_String_Type (Raw);
      begin
         Assert (Bytes (To_Lower (Source)) = Raw, Label & ": To_Lower changed the bytes");
         Assert (Bytes (To_Upper (Source)) = Raw, Label & ": To_Upper changed the bytes");
         Assert (Bytes (Simple_To_Lower (Source)) = Raw, Label & ": Simple_To_Lower changed the bytes");
      end Check_Kept;

      E0_88_BA : constant String := Character'Val (16#E0#) & Character'Val (16#88#) & Character'Val (16#BA#);
      E0_88_BE : constant String := Character'Val (16#E0#) & Character'Val (16#88#) & Character'Val (16#BE#);
      C0_80    : constant String := Character'Val (16#C0#) & Character'Val (16#80#);
      C1_BF    : constant String := Character'Val (16#C1#) & Character'Val (16#BF#);
      ED_A0_80 : constant String := Character'Val (16#ED#) & Character'Val (16#A0#) & Character'Val (16#80#);
      F4_90    : constant String :=
        Character'Val (16#F4#) & Character'Val (16#90#) & Character'Val (16#80#) & Character'Val (16#80#);
   begin
      if Byte_Counting then
         --  E0 88 BA is an overlong encoding of U+023A (whose lower form is
         --  U+2C65): it must not be mapped.
         Check_Kept (E0_88_BA, "overlong U+023A");
         Check_Kept (E0_88_BE, "overlong U+023E");
         Check_Kept (C0_80, "overlong NUL (2 bytes)");
         Check_Kept (C1_BF, "overlong U+007F (2 bytes)");
         Check_Kept (ED_A0_80, "surrogate U+D800");
         Check_Kept (F4_90, "U+110000 (above U+10FFFF)");
         --  Between ASCII letters: the letters are mapped, the bytes are kept.
         Assert
           (Bytes (To_Lower (To_String_Type ("A" & E0_88_BA & "B"))) = "a" & E0_88_BA & "b",
            "lower: overlong between ASCII letters");
         Assert
           (Bytes (To_Upper (To_String_Type ("a" & E0_88_BA & "b"))) = "A" & E0_88_BA & "B",
            "upper: overlong between ASCII letters");
      end if;
   end Test_Standard_Overlong_And_Out_Of_Range_Kept;

end Case_Mapping_Test;
