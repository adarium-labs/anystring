-------------------------------------------------------------------------------
--  Anystrings Tests - Character Classification Test Suite Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with String_Types;     use String_Types;

package body Char_Classification_Test is

   --  Largest code point representable by the active Character_Type.
   --  Cached once because every Unicode-range test consults it.
   Max_Code_Point : constant Natural :=
     Character_Type'Pos (Character_Type'Last);

   --  Construct a Character_Type from a Unicode code point. Returns
   --  Character_Type'Val (0) if the code point exceeds the backend's
   --  representable range. The argument is non-static so that
   --  Character_Type'Val never triggers a compile-time check.
   function Make_Char (CP : Natural) return Character_Type
   is
      Safe_CP : Natural := CP;
   begin
      if Safe_CP > Max_Code_Point then
         Safe_CP := 0;
      end if;
      return Character_Type'Val (Safe_CP);
   end Make_Char;

   --  Run a digit assertion only if the active backend can represent CP.
   procedure Expect_Digit (CP : Natural; Label : String) is
   begin
      if CP <= Max_Code_Point then
         Assert (Is_Digit (Make_Char (CP)), Label & " should be a digit");
      end if;
   end Expect_Digit;

   --  Run a letter assertion only if the active backend can represent CP.
   procedure Expect_Letter (CP : Natural; Label : String) is
   begin
      if CP <= Max_Code_Point then
         Assert (Is_Letter (Make_Char (CP)), Label & " should be a letter");
      end if;
   end Expect_Letter;

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Character Classification Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine
        (T, (Routine      => Test_ASCII_Digits'Access,
             Routine_Name => AUnit.Format ("Is_Digit covers '0'..'9'")));
      Add_Routine
        (T, (Routine      => Test_ASCII_Letters'Access,
             Routine_Name => AUnit.Format ("Is_Letter covers 'a'..'z' / 'A'..'Z'")));
      Add_Routine
        (T, (Routine      => Test_ASCII_Alphanumeric'Access,
             Routine_Name => AUnit.Format ("Is_Alphanumeric matches digit | letter")));
      Add_Routine
        (T, (Routine      => Test_ASCII_Hex_Digits'Access,
             Routine_Name => AUnit.Format ("Is_Hex_Digit covers 0-9, a-f, A-F")));
      Add_Routine
        (T, (Routine      => Test_ASCII_Case'Access,
             Routine_Name => AUnit.Format ("To_Lower / To_Upper on ASCII letters")));
      Add_Routine
        (T, (Routine      => Test_ASCII_Control_And_Graphic'Access,
             Routine_Name => AUnit.Format ("Is_Control / Is_Graphic on ASCII")));
      Add_Routine
        (T, (Routine      => Test_ASCII_Whitespace'Access,
             Routine_Name => AUnit.Format ("Is_Whitespace covers SP/HT/LF/VT/FF/CR")));
      Add_Routine
        (T, (Routine      => Test_ASCII_Line_Terminator'Access,
             Routine_Name => AUnit.Format ("Is_Line_Terminator covers LF and CR")));
      Add_Routine
        (T, (Routine      => Test_ASCII_Case_Round_Trip'Access,
             Routine_Name => AUnit.Format ("To_Upper (To_Lower (C)) = To_Upper (C) for ASCII letters")));
      Add_Routine
        (T, (Routine      => Test_Latin_1_Supplement_Letter'Access,
             Routine_Name => AUnit.Format ("Is_Letter recognises 'e-acute' (U+00E9)")));
      Add_Routine
        (T, (Routine      => Test_Latin_1_Supplement_Case'Access,
             Routine_Name => AUnit.Format ("To_Lower (U+00C9) = U+00E9 on Latin-1+")));
      Add_Routine
        (T, (Routine      => Test_Unicode_Beyond_Latin_1'Access,
             Routine_Name => AUnit.Format ("Arabic-Indic digits & Greek case (Unicode backends)")));
   end Register_Tests;

   procedure Test_ASCII_Digits
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      for D in 0 .. 9 loop
         Assert (Is_Digit (Make_Char (Character'Pos ('0') + D)),
                 "Is_Digit should hold for '0'..'9'");
      end loop;
      Assert (not Is_Digit (Make_Char (Character'Pos ('a'))),
              "Is_Digit should not hold for 'a'");
      Assert (not Is_Digit (Make_Char (Character'Pos (' '))),
              "Is_Digit should not hold for space");
   end Test_ASCII_Digits;

   procedure Test_ASCII_Letters
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      for L in Character'Pos ('a') .. Character'Pos ('z') loop
         Assert (Is_Letter (Make_Char (L)),
                 "Is_Letter should hold for 'a'..'z'");
         Assert (Is_Lower (Make_Char (L)),
                 "Is_Lower should hold for 'a'..'z'");
      end loop;
      for L in Character'Pos ('A') .. Character'Pos ('Z') loop
         Assert (Is_Letter (Make_Char (L)),
                 "Is_Letter should hold for 'A'..'Z'");
         Assert (Is_Upper (Make_Char (L)),
                 "Is_Upper should hold for 'A'..'Z'");
      end loop;
      Assert (not Is_Letter (Make_Char (Character'Pos ('5'))),
              "Is_Letter should not hold for '5'");
      Assert (not Is_Lower (Make_Char (Character'Pos ('A'))),
              "Is_Lower should not hold for 'A'");
      Assert (not Is_Upper (Make_Char (Character'Pos ('a'))),
              "Is_Upper should not hold for 'a'");
   end Test_ASCII_Letters;

   procedure Test_ASCII_Alphanumeric
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Assert (Is_Alphanumeric (Make_Char (Character'Pos ('a'))),
              "Is_Alphanumeric should hold for 'a'");
      Assert (Is_Alphanumeric (Make_Char (Character'Pos ('Z'))),
              "Is_Alphanumeric should hold for 'Z'");
      Assert (Is_Alphanumeric (Make_Char (Character'Pos ('5'))),
              "Is_Alphanumeric should hold for '5'");
      Assert (not Is_Alphanumeric (Make_Char (Character'Pos (' '))),
              "Is_Alphanumeric should not hold for space");
      Assert (not Is_Alphanumeric (Make_Char (Character'Pos ('.'))),
              "Is_Alphanumeric should not hold for '.'");
   end Test_ASCII_Alphanumeric;

   procedure Test_ASCII_Hex_Digits
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      for D in 0 .. 9 loop
         Assert (Is_Hex_Digit (Make_Char (Character'Pos ('0') + D)),
                 "Is_Hex_Digit should hold for '0'..'9'");
      end loop;
      for L in 0 .. 5 loop
         Assert (Is_Hex_Digit (Make_Char (Character'Pos ('a') + L)),
                 "Is_Hex_Digit should hold for 'a'..'f'");
         Assert (Is_Hex_Digit (Make_Char (Character'Pos ('A') + L)),
                 "Is_Hex_Digit should hold for 'A'..'F'");
      end loop;
      Assert (not Is_Hex_Digit (Make_Char (Character'Pos ('g'))),
              "Is_Hex_Digit should not hold for 'g'");
      Assert (not Is_Hex_Digit (Make_Char (Character'Pos ('Z'))),
              "Is_Hex_Digit should not hold for 'Z'");
   end Test_ASCII_Hex_Digits;

   procedure Test_ASCII_Case
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      for L in 0 .. 25 loop
         declare
            Lo : constant Character_Type := Make_Char (Character'Pos ('a') + L);
            Hi : constant Character_Type := Make_Char (Character'Pos ('A') + L);
         begin
            Assert (To_Upper (Lo) = Hi,
                    "To_Upper should map lower ASCII letter to upper");
            Assert (To_Lower (Hi) = Lo,
                    "To_Lower should map upper ASCII letter to lower");
         end;
      end loop;
      Assert (To_Upper (Make_Char (Character'Pos ('5'))) =
                Make_Char (Character'Pos ('5')),
              "To_Upper should leave digits unchanged");
   end Test_ASCII_Case;

   procedure Test_ASCII_Control_And_Graphic
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Assert (Is_Control (Make_Char (16#0A#)),
              "LF (0x0A) should be a control character");
      Assert (not Is_Control (Make_Char (Character'Pos ('A'))),
              "'A' should not be a control character");
      Assert (Is_Graphic (Make_Char (Character'Pos ('A'))),
              "'A' should be graphic");
      Assert (not Is_Graphic (Make_Char (16#0A#)),
              "LF should not be graphic");
   end Test_ASCII_Control_And_Graphic;

   procedure Test_ASCII_Whitespace
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      for CP in 16#09# .. 16#0D# loop
         Assert (Is_Whitespace (Make_Char (CP)),
                 "Is_Whitespace should hold for HT/LF/VT/FF/CR");
      end loop;
      Assert (Is_Whitespace (Make_Char (16#20#)),
              "Is_Whitespace should hold for SPACE");
      Assert (not Is_Whitespace (Make_Char (Character'Pos ('A'))),
              "Is_Whitespace should not hold for 'A'");
   end Test_ASCII_Whitespace;

   procedure Test_ASCII_Line_Terminator
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Assert (Is_Line_Terminator (Make_Char (16#0A#)),
              "Is_Line_Terminator should hold for LF (0x0A)");
      Assert (Is_Line_Terminator (Make_Char (16#0D#)),
              "Is_Line_Terminator should hold for CR (0x0D)");
      Assert (not Is_Line_Terminator (Make_Char (Character'Pos ('A'))),
              "Is_Line_Terminator should not hold for 'A'");
      Assert (not Is_Line_Terminator (Make_Char (16#20#)),
              "Is_Line_Terminator should not hold for SPACE");
   end Test_ASCII_Line_Terminator;

   procedure Test_ASCII_Case_Round_Trip
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      for L in 0 .. 25 loop
         declare
            Lo : constant Character_Type := Make_Char (Character'Pos ('a') + L);
            Hi : constant Character_Type := Make_Char (Character'Pos ('A') + L);
         begin
            Assert (To_Upper (To_Lower (Hi)) = To_Upper (Hi),
                    "Round-trip To_Upper (To_Lower (C)) = To_Upper (C) for ASCII letters");
            Assert (To_Upper (To_Lower (Lo)) = To_Upper (Lo),
                    "Round-trip should also hold for already-lower letters");
         end;
      end loop;
   end Test_ASCII_Case_Round_Trip;

   procedure Test_Latin_1_Supplement_Letter
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      --  U+00E9 LATIN SMALL LETTER E WITH ACUTE — every backend's
      --  Character_Type covers at least U+0000..U+00FF.
      Assert (Is_Letter (Make_Char (16#00E9#)),
              "U+00E9 should be classified as a letter");
      Assert (Is_Lower (Make_Char (16#00E9#)),
              "U+00E9 should be lower-case");
      Assert (Is_Upper (Make_Char (16#00C9#)),
              "U+00C9 should be upper-case");
   end Test_Latin_1_Supplement_Letter;

   procedure Test_Latin_1_Supplement_Case
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Assert (To_Lower (Make_Char (16#00C9#)) = Make_Char (16#00E9#),
              "To_Lower (U+00C9) should equal U+00E9");
      Assert (To_Upper (Make_Char (16#00E9#)) = Make_Char (16#00C9#),
              "To_Upper (U+00E9) should equal U+00C9");
   end Test_Latin_1_Supplement_Case;

   procedure Test_Unicode_Beyond_Latin_1
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      --  Arabic-Indic digits U+0660..U+0669: skipped on standard backend
      --  (Latin-1 max = U+00FF) by Expect_Digit's guard.
      Expect_Digit (16#0660#, "U+0660 (Arabic-Indic ZERO)");
      Expect_Digit (16#0669#, "U+0669 (Arabic-Indic NINE)");

      --  Greek capital letter ALPHA (U+0391) → letter; also test case
      --  mapping to small ALPHA (U+03B1).
      Expect_Letter (16#0391#, "U+0391 (GREEK CAPITAL ALPHA)");
      if 16#0391# <= Max_Code_Point then
         Assert (To_Lower (Make_Char (16#0391#)) = Make_Char (16#03B1#),
                 "To_Lower (Greek ALPHA U+0391) should equal U+03B1");
      end if;

      --  Unicode-only line terminators (LS U+2028, PS U+2029, NEL U+0085)
      --  are recognised on Unicode-aware backends only — wide_string is
      --  treated as ASCII-only for line-terminator semantics, matching
      --  Is_Whitespace. The gate `Max_Code_Point > 16#FFFF#` selects
      --  wide_wide_string, uxstring, and vss.
      if Max_Code_Point > 16#FFFF# then
         Assert (Is_Line_Terminator (Make_Char (16#2028#)),
                 "U+2028 (LS) should be a line terminator on Unicode backends");
         Assert (Is_Line_Terminator (Make_Char (16#2029#)),
                 "U+2029 (PS) should be a line terminator on Unicode backends");
         Assert (Is_Line_Terminator (Make_Char (16#0085#)),
                 "U+0085 (NEL) should be a line terminator on Unicode backends");
      end if;
   end Test_Unicode_Beyond_Latin_1;

end Char_Classification_Test;
