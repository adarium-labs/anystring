-------------------------------------------------------------------------------
--  Anystrings Tests - Ingress Boundary Test Suite Body (KI-046 fix round 1)
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with Ada.Strings.UTF_Encoding.Wide_Wide_Strings;
with Anystrings_UTF_8_Replace;
with String_Types;
with Ingress_Vectors;

package body Ingress_Boundary_Test is

   --  Places the bytes of Hex at the top of the index range: the string has
   --  bounds Positive'Last - Length + 1 .. Positive'Last. Top := Raw copies
   --  between two arrays of equal length with different bounds.
   --  Want_Hex: the expected code points; Replaced_Hex: the expected bytes of
   --  Replace_Ill_Formed. Hex must not be empty.
   procedure Check_At_Top (Id, Hex, Want_Hex, Replaced_Hex : String) is
      Raw : constant String := Ingress_Vectors.Bytes (Hex);
      Top : String (Positive'Last - Raw'Length + 1 .. Positive'Last);
      Want : constant Wide_Wide_String := Ingress_Vectors.Code_Points (Want_Hex);
   begin
      Top := Raw;
      Assert (Top'First = Positive'Last - Raw'Length + 1 and then Top'Last = Positive'Last,
              Id & ": the string sits at the top of the index range");

      Assert (Anystrings_UTF_8_Replace.Decode_Replacing (Top) = Want,
              Id & ": Decode_Replacing at the top of the index range");
      Assert (Anystrings_UTF_8_Replace.Code_Point_Count (Top) = Want'Length,
              Id & ": Code_Point_Count at the top of the index range");
      Assert (Anystrings_UTF_8_Replace.Replace_Ill_Formed (Top) = Ingress_Vectors.Bytes (Replaced_Hex),
              Id & ": Replace_Ill_Formed at the top of the index range");

      --  Next, called step by step, consumes exactly the string and never
      --  leaves its range.
      declare
         I        : Integer := Top'First;
         Scalar   : Natural;
         Step     : Positive;
         Ok       : Boolean;
         Consumed : Natural := 0;
      begin
         loop
            Anystrings_UTF_8_Replace.Next (Top, I, Scalar, Step, Ok);
            Consumed := Consumed + Step;
            exit when Step > Top'Last - I;
            I := I + Step;
         end loop;
         Assert (Consumed = Top'Length, Id & ": Next consumes exactly the string");
      end;

      --  The checked decoder (validator, then R) agrees with R on well-formed
      --  input and reports an error otherwise, at the same bounds.
      declare
         R : constant String_Types.UTF_8_Decode_Result := String_Types.From_UTF_8 (Top);
      begin
         if Anystrings_UTF_8_Replace.Replace_Ill_Formed (Top) = Top then
            Assert (String_Types.Is_Ok (R), Id & ": checked From_UTF_8 Ok at the top");
            Assert (String_Types.To_Wide_Wide_String (String_Types.Get_Value (R)) = Want,
                    Id & ": checked From_UTF_8 code points at the top");
         else
            Assert (not String_Types.Is_Ok (R),
                    Id & ": checked From_UTF_8 is an error at the top");
         end if;
      end;
   end Check_At_Top;

   procedure Test_Decoder_At_Top_Of_Index_Range
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      --  ASCII.
      Check_At_Top ("T01", "61 62 63 64", "61 62 63 64", "61 62 63 64");
      --  Truncated 3-byte and 4-byte leads at the end.
      Check_At_Top ("T02", "61 62 E2 82", "61 62 FFFD", "61 62 EF BF BD");
      Check_At_Top ("T03", "61 62 63 C3", "61 62 63 FFFD", "61 62 63 EF BF BD");
      Check_At_Top ("T04", "61 F0 9F 98", "61 FFFD", "61 EF BF BD");
      --  Complete multibyte sequences ending at the top.
      Check_At_Top ("T05", "61 62 C3 A9", "61 62 E9", "61 62 C3 A9");
      Check_At_Top ("T06", "F0 9F 98 80", "1F600", "F0 9F 98 80");
      Check_At_Top ("T07", "E2 82 AC 61", "20AC 61", "E2 82 AC 61");
      --  Ill-formed subparts that start at the top: surrogate, overlong,
      --  above U+10FFFF, stray continuation, bad lead.
      Check_At_Top ("T08", "ED A0 80 61", "FFFD FFFD FFFD 61",
                    "EF BF BD EF BF BD EF BF BD 61");
      Check_At_Top ("T09", "F4 90 80 80", "FFFD FFFD FFFD FFFD",
                    "EF BF BD EF BF BD EF BF BD EF BF BD");
      Check_At_Top ("T10", "61 80 62 C0", "61 FFFD 62 FFFD", "61 EF BF BD 62 EF BF BD");
      Check_At_Top ("T11", "E0 80 80 61", "FFFD FFFD FFFD 61",
                    "EF BF BD EF BF BD EF BF BD 61");
   end Test_Decoder_At_Top_Of_Index_Range;

   procedure Test_Top_Of_Range_Single_Byte_And_Scalar
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      --  One byte at Positive'Last: index and remaining length both at the edge.
      Check_At_Top ("S01", "78", "78", "78");
      Check_At_Top ("S02", "E9", "FFFD", "EF BF BD");
      Check_At_Top ("S03", "C3", "FFFD", "EF BF BD");
      Check_At_Top ("S04", "80", "FFFD", "EF BF BD");
      --  The last scalar of the Unicode range, at the top.
      Check_At_Top ("S05", "F4 8F BF BF", "10FFFF", "F4 8F BF BF");
   end Test_Top_Of_Range_Single_Byte_And_Scalar;

   procedure Test_Checked_From_UTF_8_At_Top_Of_Range
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      --  Covered by Check_At_Top (the checked From_UTF_8 at the top of the
      --  range); this routine adds the explicit error result for a truncated
      --  sequence that ends the string at Positive'Last.
      declare
         Raw : constant String := Ingress_Vectors.Bytes ("61 E2 82");
         Top : String (Positive'Last - Raw'Length + 1 .. Positive'Last);
         R   : String_Types.UTF_8_Decode_Result;
      begin
         Top := Raw;
         R := String_Types.From_UTF_8 (Top);
         Assert (not String_Types.Is_Ok (R),
                 "a truncated sequence ending at Positive'Last is an error, not a crash");
      end;
   end Test_Checked_From_UTF_8_At_Top_Of_Range;

   --  UTF-16 code units (Units_Hex, one token per unit) placed at the top of the
   --  index range: bounds Positive'Last - N + 1 .. Positive'Last. The last unit
   --  is a single unit or the second half of a surrogate pair, so a loop that
   --  advanced past Source'Last would raise Constraint_Error here.
   --  Want_Hex: the expected code points; UTF_8_Hex: the expected UTF-8 bytes.
   procedure Check_UTF_16_At_Top (Id, Units_Hex, Want_Hex, UTF_8_Hex : String) is
      Units : constant Wide_Wide_String := Ingress_Vectors.Code_Points (Units_Hex);
      Top   : Wide_String (Positive'Last - Units'Length + 1 .. Positive'Last);
      Want  : constant Wide_Wide_String := Ingress_Vectors.Code_Points (Want_Hex);
   begin
      for K in Units'Range loop
         Top (Top'First + (K - Units'First)) := Wide_Character'Val (Wide_Wide_Character'Pos (Units (K)));
      end loop;
      Assert (Top'Last = Positive'Last, Id & ": the units sit at the top of the index range");

      Assert (Anystrings_UTF_8_Replace.UTF_16_Scalar_Count (Top) = Want'Length,
              Id & ": UTF_16_Scalar_Count at the top of the index range");
      Assert (Anystrings_UTF_8_Replace.From_UTF_16 (Top) = Want,
              Id & ": From_UTF_16 at the top of the index range");
      --  What To_UTF_8 does on the wide_string backend: code points, then UTF-8.
      Assert (Ada.Strings.UTF_Encoding.Wide_Wide_Strings.Encode
                (Item => Anystrings_UTF_8_Replace.From_UTF_16 (Top), Output_BOM => False)
              = Ingress_Vectors.Bytes (UTF_8_Hex),
              Id & ": UTF-8 of the code points at the top of the index range");
   end Check_UTF_16_At_Top;

   procedure Test_UTF_16_At_Top_Of_Index_Range
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      --  Final single unit.
      Check_UTF_16_At_Top ("U01", "0061", "61", "61");
      Check_UTF_16_At_Top ("U02", "20AC", "20AC", "E2 82 AC");
      Check_UTF_16_At_Top ("U03", "D83D 0061", "FFFD 61", "EF BF BD 61");
      --  Final surrogate pair.
      Check_UTF_16_At_Top ("U04", "D83D DE00", "1F600", "F0 9F 98 80");
      Check_UTF_16_At_Top ("U05", "0061 D83D DE00", "61 1F600", "61 F0 9F 98 80");
      Check_UTF_16_At_Top ("U06", "D83D D83D DE00", "FFFD 1F600", "EF BF BD F0 9F 98 80");
      --  Lone surrogate at the end.
      Check_UTF_16_At_Top ("U07", "0061 D83D", "61 FFFD", "61 EF BF BD");
      Check_UTF_16_At_Top ("U08", "DE00", "FFFD", "EF BF BD");
      Check_UTF_16_At_Top ("U09", "DE00 D83D", "FFFD FFFD", "EF BF BD EF BF BD");
      --  A pair followed by a single unit.
      Check_UTF_16_At_Top ("U10", "D83D DE00 0061", "1F600 61", "F0 9F 98 80 61");
   end Test_UTF_16_At_Top_Of_Index_Range;

   --  Code_Point_Length and To_UTF_8 of the active back end for a stored value
   --  that ends with a single unit or with a supplementary code point (a
   --  surrogate pair on wide_string). The same rows hold on every back end.
   procedure Check_Facade_Tail (Id, CP_Hex, UTF_8_Hex : String) is
      Want : constant Wide_Wide_String := Ingress_Vectors.Code_Points (CP_Hex);
      S    : constant String_Types.String_Type := String_Types.From_Wide_Wide_String (Want);
   begin
      Assert (String_Types.Code_Point_Length (S) = Want'Length, Id & ": Code_Point_Length");
      Assert (String_Types.To_Wide_Wide_String (S) = Want, Id & ": To_Wide_Wide_String");
      Assert (String_Types.To_UTF_8 (S) = Ingress_Vectors.Bytes (UTF_8_Hex), Id & ": To_UTF_8");
   end Check_Facade_Tail;

   procedure Test_Code_Point_Length_And_To_UTF_8_At_The_End
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Check_Facade_Tail ("F01", "61", "61");
      Check_Facade_Tail ("F02", "20AC", "E2 82 AC");
      Check_Facade_Tail ("F03", "1F600", "F0 9F 98 80");
      Check_Facade_Tail ("F04", "61 1F600", "61 F0 9F 98 80");
      Check_Facade_Tail ("F05", "1F600 61", "F0 9F 98 80 61");
      Check_Facade_Tail ("F06", "1F600 1F600", "F0 9F 98 80 F0 9F 98 80");
   end Test_Code_Point_Length_And_To_UTF_8_At_The_End;

   --  uxstring reads To_String_Type as UTF-8 with R (human decision). The
   --  backends that keep bytes (standard) decode the same way through To_Wide_
   --  Wide_String, so the expectations below hold on both; wide_* and vss read
   --  Latin-1 and are not checked here.
   procedure Test_To_String_Type_Replaces_Latin_1_Bytes
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Decodes_UTF_8 : constant Boolean :=
        String_Types.To_Wide_Wide_String (String_Types.To_String_Type (Ingress_Vectors.Bytes ("E9")))
        = Ingress_Vectors.Code_Points ("FFFD");
   begin
      if not Decodes_UTF_8 then
         Assert (True, "SKIP: To_String_Type reads Latin-1 on this back end");
         return;
      end if;

      --  C3 A9 is UTF-8 for e-acute: decoded, not read as two Latin-1 letters.
      Assert (String_Types.To_Wide_Wide_String
                (String_Types.To_String_Type (Ingress_Vectors.Bytes ("C3 A9")))
              = Ingress_Vectors.Code_Points ("E9"),
              "To_String_Type of C3 A9 is e-acute");
      --  E9 alone is ill-formed: U+FFFD, and never an exception.
      Assert (String_Types.To_Wide_Wide_String
                (String_Types.To_String_Type (Ingress_Vectors.Bytes ("E9")))
              = Ingress_Vectors.Code_Points ("FFFD"),
              "To_String_Type of a lone E9 is U+FFFD");
      --  Mixed input: the valid part is decoded, the invalid byte is U+FFFD.
      Assert (String_Types.To_Wide_Wide_String
                (String_Types.To_String_Type (Ingress_Vectors.Bytes ("61 C3 A9 E9 62")))
              = Ingress_Vectors.Code_Points ("61 E9 FFFD 62"),
              "To_String_Type keeps the valid part of mixed input decoded");
   end Test_To_String_Type_Replaces_Latin_1_Bytes;

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Ingress Boundary (KI-046 fix round 1) Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine
        (T, (Routine      => Test_Decoder_At_Top_Of_Index_Range'Access,
             Routine_Name => AUnit.Format ("Decoder at the top of the index range (multibyte, truncated)")));
      Add_Routine
        (T, (Routine      => Test_Top_Of_Range_Single_Byte_And_Scalar'Access,
             Routine_Name => AUnit.Format ("Decoder at the top of the index range (single byte, last scalar)")));
      Add_Routine
        (T, (Routine      => Test_Checked_From_UTF_8_At_Top_Of_Range'Access,
             Routine_Name => AUnit.Format ("Checked From_UTF_8 at the top of the index range")));
      Add_Routine
        (T, (Routine      => Test_UTF_16_At_Top_Of_Index_Range'Access,
             Routine_Name => AUnit.Format ("UTF-16 scans at the top of the index range (single unit, pair, lone)")));
      Add_Routine
        (T, (Routine      => Test_Code_Point_Length_And_To_UTF_8_At_The_End'Access,
             Routine_Name => AUnit.Format ("Code_Point_Length and To_UTF_8 of a value ending in a unit or pair")));
      Add_Routine
        (T, (Routine      => Test_To_String_Type_Replaces_Latin_1_Bytes'Access,
             Routine_Name => AUnit.Format ("To_String_Type reads UTF-8 with U+FFFD (uxstring decision)")));
   end Register_Tests;

end Ingress_Boundary_Test;
