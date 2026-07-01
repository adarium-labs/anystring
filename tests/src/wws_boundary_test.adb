--  Anystrings Tests - Wide_Wide_String Boundary Test Suite Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with String_Types;     use String_Types;

package body WWS_Boundary_Test is

   --  The backend's chosen substitute for surrogate / out-of-range /
   --  malformed inputs (U+FFFD on Unicode-capable backends; ASCII '?' on
   --  the byte-oriented standard backend).
   Sub : constant Wide_Wide_Character := Invalid_Substitute_Codepoint;

   --  Round-trip a Wide_Wide_String through the backend and assert equality.
   procedure Assert_Round_Trip (W : Wide_Wide_String; Label : String) is
      S       : constant String_Type      := From_Wide_Wide_String (W);
      Decoded : constant Wide_Wide_String := To_Wide_Wide_String (S);
   begin
      Assert (Decoded = W,
              Label & ": To_Wide_Wide_String (From_Wide_Wide_String (W)) shall equal W");
   end Assert_Round_Trip;

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Wide_Wide_String Boundary Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine
        (T, (Routine      => Test_Empty_String_Round_Trip'Access,
             Routine_Name => AUnit.Format ("Empty Wide_Wide_String round-trips losslessly")));
      Add_Routine
        (T, (Routine      => Test_ASCII_Round_Trip'Access,
             Routine_Name => AUnit.Format ("ASCII Wide_Wide_String round-trips losslessly")));
      Add_Routine
        (T, (Routine      => Test_BMP_Non_ASCII_Round_Trip'Access,
             Routine_Name => AUnit.Format ("BMP non-ASCII code-points round-trip losslessly")));
      Add_Routine
        (T, (Routine      => Test_Supplementary_Plane_Round_Trip'Access,
             Routine_Name => AUnit.Format ("Supplementary-plane code-points round-trip losslessly")));
      Add_Routine
        (T, (Routine      => Test_Surrogate_In_Wide_Wide_Becomes_FFFD'Access,
             Routine_Name => AUnit.Format ("Surrogate in Wide_Wide_String input becomes U+FFFD")));
      Add_Routine
        (T, (Routine      => Test_Out_Of_Range_Wide_Wide_Becomes_FFFD'Access,
             Routine_Name => AUnit.Format ("Out-of-range Wide_Wide_Character becomes U+FFFD")));
      Add_Routine
        (T, (Routine      => Test_Empty_Wide_Wide_String_Round_Trip'Access,
             Routine_Name => AUnit.Format ("To_Wide_Wide_String on Empty_String returns empty")));
      Add_Routine
        (T, (Routine      => Test_Truncated_Multi_Unit_Encoding_Decodes_To_FFFD'Access,
             Routine_Name => AUnit.Format ("Truncated multi-unit encoding decodes to U+FFFD")));
   end Register_Tests;

   procedure Test_Empty_String_Round_Trip
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Empty_W : constant Wide_Wide_String := "";
   begin
      Assert_Round_Trip (Empty_W, "Empty Wide_Wide_String");
   end Test_Empty_String_Round_Trip;

   procedure Test_ASCII_Round_Trip
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      W : constant Wide_Wide_String := "hello";
   begin
      Assert_Round_Trip (W, "ASCII 'hello'");
   end Test_ASCII_Round_Trip;

   procedure Test_BMP_Non_ASCII_Round_Trip
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  "café" = c, a, f, e-acute (U+00E9).
      W_Cafe : constant Wide_Wide_String :=
        Wide_Wide_Character'Val (Character'Pos ('c'))
        & Wide_Wide_Character'Val (Character'Pos ('a'))
        & Wide_Wide_Character'Val (Character'Pos ('f'))
        & Wide_Wide_Character'Val (16#00E9#);

      --  CJK Unified Ideograph U+4E2D.
      W_Zhong : constant Wide_Wide_String := [Wide_Wide_Character'Val (16#4E2D#)];

      --  Greek alpha + beta: U+03B1 U+03B2.
      W_Greek : constant Wide_Wide_String :=
        Wide_Wide_Character'Val (16#03B1#) & Wide_Wide_Character'Val (16#03B2#);
   begin
      Assert_Round_Trip (W_Cafe, "BMP 'cafe' (with U+00E9)");
      Assert_Round_Trip (W_Zhong, "BMP CJK U+4E2D");
      Assert_Round_Trip (W_Greek, "BMP Greek U+03B1 U+03B2");
   end Test_BMP_Non_ASCII_Round_Trip;

   procedure Test_Supplementary_Plane_Round_Trip
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  U+1F30D EARTH GLOBE EUROPE-AFRICA.
      W_Earth : constant Wide_Wide_String := [Wide_Wide_Character'Val (16#1F30D#)];

      --  U+13000 EGYPTIAN HIEROGLYPH A001.
      W_Hiero : constant Wide_Wide_String := [Wide_Wide_Character'Val (16#13000#)];

      --  Mixed: ASCII 'A' + supplementary + ASCII 'B'.
      W_Mixed : constant Wide_Wide_String :=
        Wide_Wide_Character'Val (Character'Pos ('A'))
        & Wide_Wide_Character'Val (16#1F30D#)
        & Wide_Wide_Character'Val (Character'Pos ('B'));
   begin
      Assert_Round_Trip (W_Earth, "Supplementary U+1F30D");
      Assert_Round_Trip (W_Hiero, "Supplementary U+13000");
      Assert_Round_Trip (W_Mixed, "Mixed ASCII + supplementary");
   end Test_Supplementary_Plane_Round_Trip;

   procedure Test_Surrogate_In_Wide_Wide_Becomes_FFFD
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      W_With_High_Surrogate : constant Wide_Wide_String :=
        [Wide_Wide_Character'Val (16#D800#)];
      W_With_Low_Surrogate  : constant Wide_Wide_String :=
        [Wide_Wide_Character'Val (16#DFFF#)];
      W_With_Pair           : constant Wide_Wide_String :=
        Wide_Wide_Character'Val (16#D800#)
        & Wide_Wide_Character'Val (16#DC00#);

      Decoded_High : constant Wide_Wide_String :=
        To_Wide_Wide_String (From_Wide_Wide_String (W_With_High_Surrogate));
      Decoded_Low  : constant Wide_Wide_String :=
        To_Wide_Wide_String (From_Wide_Wide_String (W_With_Low_Surrogate));
      Decoded_Pair : constant Wide_Wide_String :=
        To_Wide_Wide_String (From_Wide_Wide_String (W_With_Pair));
   begin
      Assert (Decoded_High = [Sub],
              "High surrogate U+D800 in WW input shall normalise to the "
              & "backend substitute");
      Assert (Decoded_Low = [Sub],
              "Low surrogate U+DFFF in WW input shall normalise to the "
              & "backend substitute");
      Assert (Decoded_Pair = (Sub & Sub),
              "Surrogate pair in WW input shall normalise to two backend "
              & "substitutes");
   end Test_Surrogate_In_Wide_Wide_Becomes_FFFD;

   procedure Test_Out_Of_Range_Wide_Wide_Becomes_FFFD
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Wide_Wide_Character'Last is U+7FFFFFFF, but the Unicode scalar
      --  range is U+0000..U+10FFFF. Values outside that range must
      --  normalise to U+FFFD through the boundary.
      W_Out_Of_Range : constant Wide_Wide_String :=
        [Wide_Wide_Character'Val (16#11_0000#)];

      Decoded : constant Wide_Wide_String :=
        To_Wide_Wide_String (From_Wide_Wide_String (W_Out_Of_Range));
   begin
      Assert (Decoded = [Sub],
              "Wide_Wide_Character > U+10FFFF shall normalise to the "
              & "backend substitute");
   end Test_Out_Of_Range_Wide_Wide_Becomes_FFFD;

   procedure Test_Empty_Wide_Wide_String_Round_Trip
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Empty_S : constant String_Type      := Empty_String;
      Decoded : constant Wide_Wide_String := To_Wide_Wide_String (Empty_S);
   begin
      Assert (Decoded'Length = 0,
              "To_Wide_Wide_String (Empty_String) shall return an empty Wide_Wide_String");
   end Test_Empty_Wide_Wide_String_Round_Trip;

   procedure Test_Truncated_Multi_Unit_Encoding_Decodes_To_FFFD
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Encode the supplementary code-point U+1F30D. On backends that
      --  store sub-code-point units (standard = UTF-8 bytes,
      --  wide_string = UTF-16 code units), the resulting String_Type has
      --  more than one element. Slicing to keep only the first element
      --  produces a malformed encoding:
      --    standard:   a lone 4-byte UTF-8 lead byte (0xF0).
      --    wide_string: a lone high UTF-16 surrogate (0xD83C).
      --  Both shall decode to U+FFFD.
      --  On code-point backends (wide_wide_string, uxstring, vss) a
      --  supplementary code-point already fits in one unit; the test is
      --  vacuously satisfied and skipped.
      W : constant Wide_Wide_String := [Wide_Wide_Character'Val (16#1F30D#)];
      S : constant String_Type      := From_Wide_Wide_String (W);
   begin
      if Length (S) = 1 then
         Assert (True,
                 "SKIP: backend stores supplementary code-points as a single "
                 & "unit; truncation does not produce a malformed encoding");
      else
         declare
            Truncated : constant String_Type      := Slice (S, 1, 1);
            Decoded   : constant Wide_Wide_String := To_Wide_Wide_String (Truncated);
         begin
            Assert (Decoded'Length = 1 and then Decoded (Decoded'First) = Sub,
                    "Truncated multi-unit encoding shall decode to a single "
                    & "backend substitute");
         end;
      end if;
   end Test_Truncated_Multi_Unit_Encoding_Decodes_To_FFFD;

end WWS_Boundary_Test;
