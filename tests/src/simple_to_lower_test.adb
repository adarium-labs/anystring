-------------------------------------------------------------------------------
--  Anystrings Tests - Simple_To_Lower Test Suite Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with String_Types;     use String_Types;

package body Simple_To_Lower_Test is

   --  Code point from its value; avoids non-ASCII source literals.
   function Cp (Code : Natural) return Wide_Wide_Character is
   begin
      return Wide_Wide_Character'Val (Code);
   end Cp;

   --  True on a backend whose Length counts UTF-8 bytes (standard): U+00E9
   --  is two bytes there and one code point everywhere else.
   Byte_Counting : constant Boolean :=
     Length (From_Wide_Wide_String (Wide_Wide_String'(1 => Cp (16#E9#)))) = 2;

   --  Map Input with Simple_To_Lower, then check the result against Expected
   --  in code points, and that Length and Code_Point_Length are unchanged.
   procedure Expect (Input : Wide_Wide_String; Expected : Wide_Wide_String; Label : String) is
      Source : constant String_Type := From_Wide_Wide_String (Input);
      Result : constant String_Type := Simple_To_Lower (Source);
   begin
      Assert (Length (Result) = Length (Source), Label & ": Length changed");
      Assert
        (Code_Point_Length (Result) = Code_Point_Length (Source),
         Label & ": code point count changed");
      Assert (To_Wide_Wide_String (Result) = Expected, Label & ": unexpected code points");
   end Expect;

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Simple_To_Lower Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine (T, (Routine => Test_ASCII'Access, Routine_Name => AUnit.Format ("ASCII lower-cases A-Z")));
      Add_Routine (T, (Routine => Test_Latin_1'Access, Routine_Name => AUnit.Format ("Latin-1 letters")));
      Add_Routine (T, (Routine => Test_Greek'Access, Routine_Name => AUnit.Format ("Greek capital sigma")));
      Add_Routine (T, (Routine => Test_Empty'Access, Routine_Name => AUnit.Format ("Empty string")));
      Add_Routine
        (T, (Routine => Test_Unchanged'Access, Routine_Name => AUnit.Format ("Lower-case and non-letters unchanged")));
      Add_Routine
        (T,
         (Routine      => Test_Dotted_I_And_Capital_Sharp_S'Access,
          Routine_Name => AUnit.Format ("U+0130 and U+1E9E simple mappings")));
      Add_Routine
        (T,
         (Routine      => Test_Supplementary_Plane'Access,
          Routine_Name => AUnit.Format ("Supplementary plane letter (Deseret)")));
      Add_Routine
        (T,
         (Routine      => Test_Generated_Samples'Access,
          Routine_Name => AUnit.Format ("Generated UCD samples: Q, U+00DD, Omega, Cyrillic, OHM, KELVIN")));
      Add_Routine
        (T,
         (Routine      => Test_Malformed_Bytes_Standard_Only'Access,
          Routine_Name => AUnit.Format ("standard: ill-formed bytes kept unchanged")));
   end Register_Tests;

   procedure Test_ASCII (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Expect ("ABC", "abc", "ABC");
      Expect ("Hello, World 123", "hello, world 123", "mixed ASCII");
   end Test_ASCII;

   procedure Test_Latin_1 (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Expect
        (Wide_Wide_String'(Cp (16#C9#), Cp (16#C0#)),
         Wide_Wide_String'(Cp (16#E9#), Cp (16#E0#)),
         "U+00C9 U+00C0");
   end Test_Latin_1;

   procedure Test_Greek (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Expect
        (Wide_Wide_String'(Cp (16#3A3#), Cp (16#391#)),
         Wide_Wide_String'(Cp (16#3C3#), Cp (16#3B1#)),
         "U+03A3 U+0391");
   end Test_Greek;

   procedure Test_Empty (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Expect ("", "", "empty");
   end Test_Empty;

   procedure Test_Unchanged (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Expect ("abc 123 !-_", "abc 123 !-_", "lower-case and non-letters");
      Expect
        (Wide_Wide_String'("abc 123 !-_") & Cp (16#E9#),
         Wide_Wide_String'("abc 123 !-_") & Cp (16#E9#),
         "lower-case Latin-1 letter");
   end Test_Unchanged;

   procedure Test_Dotted_I_And_Capital_Sharp_S (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      --  U+0130 -> U+0069 is a simple mapping (one code point to one).
      --  Its UTF-8 form shrinks from 2 bytes to 1, so on standard it is kept.
      if Byte_Counting then
         Expect (Wide_Wide_String'(1 => Cp (16#130#)), Wide_Wide_String'(1 => Cp (16#130#)), "U+0130 (bytes)");
         Expect (Wide_Wide_String'(1 => Cp (16#1E9E#)), Wide_Wide_String'(1 => Cp (16#1E9E#)), "U+1E9E (bytes)");
      else
         Expect (Wide_Wide_String'(1 => Cp (16#130#)), Wide_Wide_String'(1 => Cp (16#69#)), "U+0130 -> U+0069");
         Expect (Wide_Wide_String'(1 => Cp (16#1E9E#)), Wide_Wide_String'(1 => Cp (16#DF#)), "U+1E9E -> U+00DF");
      end if;
   end Test_Dotted_I_And_Capital_Sharp_S;

   procedure Test_Supplementary_Plane (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Expect
        (Wide_Wide_String'(1 => Cp (16#10400#)),
         Wide_Wide_String'(1 => Cp (16#10428#)),
         "U+10400 -> U+10428");
   end Test_Supplementary_Plane;

   procedure Test_Malformed_Bytes_Standard_Only (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      if Byte_Counting then
         --  Latin-1 bytes C9 C0 are not UTF-8: they are not lowered, and the
         --  byte length is kept.
         declare
            Raw    : constant String_Type :=
              To_String_Type (Character'Val (16#C9#) & Character'Val (16#C0#));
            Result : constant String_Type := Simple_To_Lower (Raw);
         begin
            Assert (Length (Result) = 2, "ill-formed bytes: Length changed");
            Assert (Character_Type'Pos (Element (Result, 1)) = 16#C9#, "ill-formed byte 1 changed");
            Assert (Character_Type'Pos (Element (Result, 2)) = 16#C0#, "ill-formed byte 2 changed");
         end;
      end if;
   end Test_Malformed_Bytes_Standard_Only;

   --  Known simple mappings (UnicodeData.txt, Unicode 15.1), read from the
   --  generated Anystrings_UCD_Case tables through Simple_To_Lower.
   procedure Test_Generated_Samples (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Expect (Wide_Wide_String'(1 => Cp (16#51#)), Wide_Wide_String'(1 => Cp (16#71#)), "Q -> q");
      Expect (Wide_Wide_String'(1 => Cp (16#DD#)), Wide_Wide_String'(1 => Cp (16#FD#)), "U+00DD -> U+00FD");
      Expect (Wide_Wide_String'(1 => Cp (16#3A9#)), Wide_Wide_String'(1 => Cp (16#3C9#)), "Omega -> omega");
      Expect (Wide_Wide_String'(1 => Cp (16#416#)), Wide_Wide_String'(1 => Cp (16#436#)), "Cyrillic ZHE -> zhe");
      --  OHM SIGN (3 bytes) -> omega (2 bytes), KELVIN SIGN (3) -> k (1): the
      --  byte length changes, so standard keeps them.
      if Byte_Counting then
         Expect (Wide_Wide_String'(1 => Cp (16#2126#)), Wide_Wide_String'(1 => Cp (16#2126#)), "OHM (bytes)");
         Expect (Wide_Wide_String'(1 => Cp (16#212A#)), Wide_Wide_String'(1 => Cp (16#212A#)), "KELVIN (bytes)");
      else
         Expect (Wide_Wide_String'(1 => Cp (16#2126#)), Wide_Wide_String'(1 => Cp (16#3C9#)), "OHM -> omega");
         Expect (Wide_Wide_String'(1 => Cp (16#212A#)), Wide_Wide_String'(1 => Cp (16#6B#)), "KELVIN -> k");
      end if;
   end Test_Generated_Samples;

end Simple_To_Lower_Test;
