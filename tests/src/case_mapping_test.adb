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

   type Codes is array (Positive range <>) of Natural;

   --  The text whose code points are Values.
   function Text (Values : Codes) return Wide_Wide_String is
      R : Wide_Wide_String (1 .. Values'Length);
   begin
      for I in Values'Range loop
         R (I - Values'First + 1) := Cp (Values (I));
      end loop;
      return R;
   end Text;

   --  True on a backend whose Length counts UTF-8 bytes (standard).
   Byte_Counting : constant Boolean :=
     Length (From_Wide_Wide_String (Wide_Wide_String'(1 => Cp (16#E9#)))) = 2;

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
         (Routine      => Test_Shared_Expectations'Access,
          Routine_Name => AUnit.Format ("Shared expectations: ECOLE, sharp s, dotted I, Greek, Cyrillic, Deseret")));
      Add_Routine
        (T, (Routine => Test_Round_Trip'Access, Routine_Name => AUnit.Format ("To_Upper (To_Lower (x)) = x")));
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
      Add_Routine
        (T,
         (Routine      => Test_Standard_Char_Mapping_ASCII_Only'Access,
          Routine_Name => AUnit.Format ("standard: Char_To_Lower / Char_To_Upper map ASCII only")));
   end Register_Tests;

   procedure Test_ASCII_Unchanged_By_Case_Mapping (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Expect_Map ("Hello, World 123!", "hello, world 123!", Upper => False, Label => "ASCII lower");
      Expect_Map ("Hello, World 123!", "HELLO, WORLD 123!", Upper => True, Label => "ASCII upper");
      Expect_Map ("", "", Upper => False, Label => "empty lower");
      Expect_Map ("", "", Upper => True, Label => "empty upper");
   end Test_ASCII_Unchanged_By_Case_Mapping;

   --  The expectations every backend must meet, in code points.
   procedure Test_Shared_Expectations (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      --  "ÉCOLE" <-> "école"
      Expect_Map
        (Text ((16#C9#, 16#43#, 16#4F#, 16#4C#, 16#45#)),
         Text ((16#E9#, 16#63#, 16#6F#, 16#6C#, 16#65#)),
         Upper => False,
         Label => "ECOLE lower");
      Expect_Map
        (Text ((16#E9#, 16#63#, 16#6F#, 16#6C#, 16#65#)),
         Text ((16#C9#, 16#43#, 16#4F#, 16#4C#, 16#45#)),
         Upper => True,
         Label => "ecole upper");
      --  "ß" -> "SS" (full mapping, two code points)
      Expect_Map (Text ((1 => 16#DF#)), Text ((16#53#, 16#53#)), Upper => True, Label => "sharp s upper");
      --  "İ" (U+0130) -> U+0069 U+0307
      Expect_Map
        (Text ((1 => 16#130#)),
         Text ((16#69#, 16#307#)),
         Upper => False,
         Label => "dotted I lower");
      --  "ΟΔΥΣΣΕΥΣ" -> "οδυσσευς": the final sigma is U+03C2
      Expect_Map
        (Text ((16#39F#, 16#394#, 16#3A5#, 16#3A3#, 16#3A3#, 16#395#, 16#3A5#, 16#3A3#)),
         Text ((16#3BF#, 16#3B4#, 16#3C5#, 16#3C3#, 16#3C3#, 16#3B5#, 16#3C5#, 16#3C2#)),
         Upper => False,
         Label => "Odysseus lower");
      --  Greek "ΑΒΓΔ" <-> "αβγδ"
      Expect_Map
        (Text ((16#391#, 16#392#, 16#393#, 16#394#)),
         Text ((16#3B1#, 16#3B2#, 16#3B3#, 16#3B4#)),
         Upper => False,
         Label => "Greek lower");
      Expect_Map
        (Text ((16#3B1#, 16#3B2#, 16#3B3#, 16#3B4#)),
         Text ((16#391#, 16#392#, 16#393#, 16#394#)),
         Upper => True,
         Label => "Greek upper");
      --  Cyrillic "ПРИВЕТ" <-> "привет"
      Expect_Map
        (Text ((16#41F#, 16#420#, 16#418#, 16#412#, 16#415#, 16#422#)),
         Text ((16#43F#, 16#440#, 16#438#, 16#432#, 16#435#, 16#442#)),
         Upper => False,
         Label => "Cyrillic lower");
      Expect_Map
        (Text ((16#43F#, 16#440#, 16#438#, 16#432#, 16#435#, 16#442#)),
         Text ((16#41F#, 16#420#, 16#418#, 16#412#, 16#415#, 16#422#)),
         Upper => True,
         Label => "Cyrillic upper");
      --  Deseret U+10400 <-> U+10428: a supplementary-plane letter, which is a
      --  surrogate pair on wide_string.
      Expect_Map (Text ((1 => 16#10400#)), Text ((1 => 16#10428#)), Upper => False, Label => "Deseret lower");
      Expect_Map (Text ((1 => 16#10428#)), Text ((1 => 16#10400#)), Upper => True, Label => "Deseret upper");
   end Test_Shared_Expectations;

   procedure Test_Round_Trip (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
      Input   : constant Wide_Wide_String := Text ((16#C0#, 16#C9#, 16#CE#));
      Source  : constant String_Type := From_Wide_Wide_String (Input);
      Lowered : constant String_Type := To_Lower (Source);
      Back    : constant String_Type := To_Upper (Lowered);
   begin
      Assert (To_Wide_Wide_String (Back) = Input, "To_Upper (To_Lower (x)) /= x");
      Expect_Map
        (Input,
         Text ((16#E0#, 16#E9#, 16#EE#)),
         Upper => False,
         Label => "U+00C0 U+00C9 U+00CE lower");
      if Byte_Counting then
         Assert (UTF_8_Is_Valid (Bytes (Lowered)), "lower-case result is not valid UTF-8");
         Assert (UTF_8_Is_Valid (Bytes (Back)), "round-trip result is not valid UTF-8");
         Assert (Bytes (Back) = Bytes (Source), "round-trip bytes differ");
      end if;
   end Test_Round_Trip;

   --  Final_Sigma (SpecialCasing): a capital sigma at the end of a word lower-
   --  cases to U+03C2; elsewhere to U+03C3.
   procedure Test_Final_Sigma (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
      Omicron : constant Wide_Wide_Character := Cp (16#39F#);
      Delta_C : constant Wide_Wide_Character := Cp (16#394#);
      Sigma   : constant Wide_Wide_Character := Cp (16#3A3#);
      Alpha   : constant Wide_Wide_Character := Cp (16#391#);
      Beta    : constant Wide_Wide_Character := Cp (16#392#);
      Space   : constant Wide_Wide_Character := Cp (16#20#);
   begin
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
      C9  : constant Character := Character'Val (16#C9#);
      C0  : constant Character := Character'Val (16#C0#);
      C3  : constant Character := Character'Val (16#C3#);
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
         --  The egress decoder is algorithm R (one U+FFFD per maximal
         --  ill-formed subpart), the same model as the code-point boundary:
         --  an overlong sequence is never the code point it spells.
         Assert
           (To_Latin_1 (To_String_Type (Character'Val (16#E0#) & Character'Val (16#80#) & Character'Val (16#A9#)))
            = "???",
            "To_Latin_1: overlong E0 80 A9 decoded as A9");
         Assert
           (To_Latin_1 (To_String_Type (Character'Val (16#F0#) & Character'Val (16#80#) & Character'Val (16#80#)
                                        & Character'Val (16#AF#)))
            = "????",
            "To_Latin_1: overlong F0 80 80 AF decoded as /");
         --  An encoded surrogate is one U+FFFD per byte (three), not one for the
         --  three bytes.
         Assert (To_Latin_1 (To_String_Type (ED_A0_80)) = "???", "To_Latin_1: ED A0 80 is not three replacements");
         --  A truncated three-byte sequence is one maximal subpart (E2 82), then A.
         Assert
           (To_Latin_1 (To_String_Type (Character'Val (16#E2#) & Character'Val (16#82#) & "A")) = "?A",
            "To_Latin_1: truncated E2 82 is not one replacement");
         Assert
           (To_Wide_Wide_String (To_String_Type (E0_88_BA)) = (1 .. 3 => Cp (16#FFFD#)),
            "To_Wide_Wide_String: overlong E0 88 BA decoded as U+023A");
      end if;
   end Test_Standard_Overlong_And_Out_Of_Range_Kept;

   --  standard: a Character is one byte of UTF-8. Char_To_Lower / Char_To_Upper
   --  map A-Z and a-z only; a byte >= 16#80# is returned unchanged.
   procedure Test_Standard_Char_Mapping_ASCII_Only (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      if Byte_Counting then
         Assert (To_Lower (Character_Type'Val (16#41#)) = Character_Type'Val (16#61#), "To_Lower A");
         Assert (To_Upper (Character_Type'Val (16#7A#)) = Character_Type'Val (16#5A#), "To_Upper z");
         Assert (To_Lower (Character_Type'Val (16#C9#)) = Character_Type'Val (16#C9#), "To_Lower C9 changed");
         Assert (To_Lower (Character_Type'Val (16#C3#)) = Character_Type'Val (16#C3#), "To_Lower C3 changed");
         Assert (To_Upper (Character_Type'Val (16#E9#)) = Character_Type'Val (16#E9#), "To_Upper E9 changed");
         Assert (To_Upper (Character_Type'Val (16#A9#)) = Character_Type'Val (16#A9#), "To_Upper A9 changed");
      end if;
   end Test_Standard_Char_Mapping_ASCII_Only;

end Case_Mapping_Test;
