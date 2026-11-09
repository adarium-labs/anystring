-------------------------------------------------------------------------------
--  Anystrings Tests - Length Contracts Test Suite Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with String_Types;     use String_Types;

package body Length_Contracts_Test is

   --  Single Latin-1 byte 0xE9 (e-acute): one unit on every backend.
   Latin_1_E_Acute : constant String := [1 => Character'Val (16#E9#)];

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Length Contracts Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine
        (T, (Routine      => Test_Empty_String'Access,
             Routine_Name => AUnit.Format ("Empty_String has length 0 and Is_Empty holds")));
      Add_Routine
        (T, (Routine      => Test_Concat_Lengths'Access,
             Routine_Name => AUnit.Format ("& overloads add lengths, empty operands included")));
      Add_Routine
        (T, (Routine      => Test_Concat_Function_Forms'Access,
             Routine_Name => AUnit.Format ("Concat, Append_Character, Prepend_Character add lengths")));
      Add_Routine
        (T, (Routine      => Test_Append_Lengths'Access,
             Routine_Name => AUnit.Format ("Append grows Source by Length (New_Item)")));
      Add_Routine
        (T, (Routine      => Test_Slice_Lengths'Access,
             Routine_Name => AUnit.Format ("Slice length: full, inner, empty and High < Low")));
      Add_Routine
        (T, (Routine      => Test_Slice_Out_Of_Range_Raises'Access,
             Routine_Name => AUnit.Format ("Slice past Length raises")));
      Add_Routine
        (T, (Routine      => Test_To_String_Type_Length'Access,
             Routine_Name => AUnit.Format ("To_String_Type preserves length (ASCII)")));
      Add_Routine
        (T, (Routine      => Test_To_Latin_1_Length'Access,
             Routine_Name => AUnit.Format ("To_Latin_1 result starts at 1 and has Length (ASCII)")));
   end Register_Tests;

   procedure Test_Empty_String
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Assert (Length (Empty_String) = 0, "Length (Empty_String) must be 0");
      Assert (Is_Empty (Empty_String), "Is_Empty (Empty_String) must be True");
      Assert (not Is_Empty (To_String_Type ("a")), "Is_Empty of non-empty must be False");
   end Test_Empty_String;

   procedure Test_Concat_Lengths
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Ab    : constant String_Type := To_String_Type ("ab");
      Cde   : constant String_Type := To_String_Type ("cde");
      Empty : constant String_Type := Empty_String;
   begin
      Assert (Length (Ab & Cde) = 5, "String_Type & String_Type");
      Assert (Length (Ab & Empty) = 2, "String_Type & empty String_Type");
      Assert (Length (Empty & Cde) = 3, "empty String_Type & String_Type");
      Assert (Length (Empty & Empty) = 0, "empty & empty");
      Assert (Length (Ab & 'x') = 3, "String_Type & Character");
      Assert (Length (Empty & 'x') = 1, "empty & Character");
      Assert (Length ('x' & Ab) = 3, "Character & String_Type");
      Assert (Length ('x' & Empty) = 1, "Character & empty");
      Assert (Length (Ab & String'("xyz")) = 5, "String_Type & Latin-1 String");
      Assert (Length (Ab & String'("")) = 2, "String_Type & empty Latin-1 String");
      Assert (Length (Ab & Latin_1_E_Acute) = 3, "String_Type & one Latin-1 byte");
      Assert (Length (String'("xyz") & Ab) = 5, "Latin-1 String & String_Type");
      Assert (Length (String'("") & Empty) = 0, "empty Latin-1 String & empty");
      Assert (Length (Latin_1_E_Acute & Ab) = 3, "one Latin-1 byte & String_Type");
   end Test_Concat_Lengths;

   procedure Test_Concat_Function_Forms
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Ab    : constant String_Type := To_String_Type ("ab");
      Cde   : constant String_Type := To_String_Type ("cde");
      Empty : constant String_Type := Empty_String;
   begin
      Assert (Length (Concat (Ab, Cde)) = 5, "Concat");
      Assert (Length (Concat (Empty, Empty)) = 0, "Concat of empties");
      Assert (Length (Append_Character (Ab, 'x')) = 3, "Append_Character");
      Assert (Length (Append_Character (Empty, 'x')) = 1, "Append_Character to empty");
      Assert (Length (Prepend_Character ('x', Ab)) = 3, "Prepend_Character");
      Assert (Length (Prepend_Character ('x', Empty)) = 1, "Prepend_Character to empty");
   end Test_Concat_Function_Forms;

   procedure Test_Append_Lengths
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Source : String_Type := To_String_Type ("ab");
   begin
      Append (Source, To_String_Type ("cde"));
      Assert (Length (Source) = 5, "Append adds Length (New_Item)");
      Append (Source, Empty_String);
      Assert (Length (Source) = 5, "Append of empty leaves Length unchanged");
      Append (Source, To_String_Type ("f"));
      Assert (Length (Source) = 6, "second Append adds one");
   end Test_Append_Lengths;

   procedure Test_Slice_Lengths
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Src : constant String_Type := To_String_Type ("abcde");
   begin
      Assert (Length (Slice (Src, 1, 5)) = 5, "full range");
      Assert (Length (Slice (Src, 2, 4)) = 3, "inner range");
      Assert (Length (Slice (Src, 5, 5)) = 1, "single element");
      Assert (Length (Slice (Src, 3, 2)) = 0, "High < Low is empty");
      Assert (Length (Slice (Src, 6, 5)) = 0, "empty range at end");
      Assert (Length (Slice (Empty_String, 1, 0)) = 0, "empty source");
   end Test_Slice_Lengths;

   procedure Test_Slice_Out_Of_Range_Raises
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Src    : constant String_Type := To_String_Type ("abc");
      Len    : Natural := 0;
      Raised : Boolean := False;
   begin
      begin
         Len := Length (Slice (Src, 1, 4));
      exception
         when others =>
            Raised := True;
      end;
      Assert (Raised, "Slice with High > Length must raise (length" & Natural'Image (Len) & ")");
   end Test_Slice_Out_Of_Range_Raises;

   procedure Test_To_String_Type_Length
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Assert (Length (To_String_Type ("hello")) = 5, "ASCII input keeps its length");
      Assert (Length (To_String_Type ("")) = 0, "empty input has length 0");
   end Test_To_String_Type_Length;

   procedure Test_To_Latin_1_Length
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Src : constant String_Type := To_String_Type ("hello");
      Lat : constant String := To_Latin_1 (Src);
   begin
      Assert (Lat'First = 1, "To_Latin_1 result must start at 1");
      Assert (Lat'Length = Length (Src), "To_Latin_1 result length must equal Length (ASCII)");
   end Test_To_Latin_1_Length;

end Length_Contracts_Test;
