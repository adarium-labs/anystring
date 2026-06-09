-------------------------------------------------------------------------------
--  Anystrings Tests - String Extension Operations Test Suite Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with String_Types;     use String_Types;

package body String_Extension_Test is

   --  Convenience: build a String_Type from a Latin-1 literal.
   function S (Item : String) return String_Type
   is (To_String_Type (Item));

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("String Extension Operations Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine
        (T, (Routine      => Test_Index_From_Basic'Access,
             Routine_Name => AUnit.Format ("Index_From returns correct positions")));
      Add_Routine
        (T, (Routine      => Test_Index_From_Past_End'Access,
             Routine_Name => AUnit.Format ("Index_From past end returns 0")));
      Add_Routine
        (T, (Routine      => Test_Index_Reverse_Basic'Access,
             Routine_Name => AUnit.Format ("Index_Reverse finds last occurrence")));
      Add_Routine
        (T, (Routine      => Test_Replace_Multiple'Access,
             Routine_Name => AUnit.Format ("Replace substitutes all occurrences")));
      Add_Routine
        (T, (Routine      => Test_Replace_Empty_Pattern'Access,
             Routine_Name => AUnit.Format ("Replace with empty Pattern is a no-op")));
      Add_Routine
        (T, (Routine      => Test_Replace_Not_Found'Access,
             Routine_Name => AUnit.Format ("Replace with missing Pattern is a no-op")));
      Add_Routine
        (T, (Routine      => Test_Replace_Empty_By'Access,
             Routine_Name => AUnit.Format ("Replace with empty By deletes Pattern")));
      Add_Routine
        (T, (Routine      => Test_Head_Pad'Access,
             Routine_Name => AUnit.Format ("Head right-pads when shorter than Count")));
      Add_Routine
        (T, (Routine      => Test_Head_Truncate'Access,
             Routine_Name => AUnit.Format ("Head truncates when longer than Count")));
      Add_Routine
        (T, (Routine      => Test_Tail_Pad'Access,
             Routine_Name => AUnit.Format ("Tail left-pads when shorter than Count")));
      Add_Routine
        (T, (Routine      => Test_Tail_Truncate'Access,
             Routine_Name => AUnit.Format ("Tail truncates from left when longer than Count")));
      Add_Routine
        (T, (Routine      => Test_Replace_Multi_Byte'Access,
             Routine_Name => AUnit.Format ("Replace on Latin-1 supplement (cafe acute -> cafe)")));
   end Register_Tests;

   procedure Test_Index_From_Basic
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Src : constant String_Type := S ("aXbXc");
      Pat : constant String_Type := S ("X");
   begin
      Assert (Index_From (Src, Pat, 1) = 2,
              "Index_From (""aXbXc"", ""X"", 1) should be 2");
      Assert (Index_From (Src, Pat, 3) = 4,
              "Index_From (""aXbXc"", ""X"", 3) should be 4");
      Assert (Index_From (Src, Pat, 5) = 0,
              "Index_From (""aXbXc"", ""X"", 5) should be 0");
   end Test_Index_From_Basic;

   procedure Test_Index_From_Past_End
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Src : constant String_Type := S ("abc");
      Pat : constant String_Type := S ("a");
   begin
      Assert (Index_From (Src, Pat, 99) = 0,
              "Index_From past end should return 0, not raise");
      Assert (Index_From (Src, S (""), 1) = 0,
              "Index_From with empty Pattern should return 0");
   end Test_Index_From_Past_End;

   procedure Test_Index_Reverse_Basic
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Assert (Index_Reverse (S ("aXbXc"), S ("X")) = 4,
              "Index_Reverse (""aXbXc"", ""X"") should be 4");
      Assert (Index_Reverse (S ("abc"), S ("X")) = 0,
              "Index_Reverse with missing Pattern should be 0");
      Assert (Index_Reverse (S ("aaaa"), S ("aa")) = 3,
              "Index_Reverse (""aaaa"", ""aa"") should be 3 (last starting position)");
      Assert (Index_Reverse (S (""), S ("a")) = 0,
              "Index_Reverse on empty Source should be 0");
   end Test_Index_Reverse_Basic;

   procedure Test_Replace_Multiple
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Assert (Replace (S ("foo bar foo"), S ("foo"), S ("baz")) = S ("baz bar baz"),
              "Replace should substitute every occurrence of foo with baz");
      Assert (Replace (S ("aaa"), S ("a"), S ("bb")) = S ("bbbbbb"),
              "Replace one->two-char with three occurrences should yield 6 chars");
   end Test_Replace_Multiple;

   procedure Test_Replace_Empty_Pattern
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Assert (Replace (S ("abc"), S (""), S ("x")) = S ("abc"),
              "Replace with empty Pattern should leave Source unchanged (no infinite loop)");
   end Test_Replace_Empty_Pattern;

   procedure Test_Replace_Not_Found
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Assert (Replace (S ("abc"), S ("z"), S ("x")) = S ("abc"),
              "Replace with missing Pattern should leave Source unchanged");
      Assert (Replace (S ("ab"), S ("abc"), S ("z")) = S ("ab"),
              "Replace when Pattern is longer than Source should leave Source unchanged");
   end Test_Replace_Not_Found;

   procedure Test_Replace_Empty_By
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Assert (Replace (S ("a-b-c"), S ("-"), S ("")) = S ("abc"),
              "Replace with empty By should delete every occurrence of Pattern");
   end Test_Replace_Empty_By;

   procedure Test_Head_Pad
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Assert (Head (S ("abc"), 5, '.') = S ("abc.."),
              "Head should right-pad with '.' to reach Count");
      Assert (Head (S (""), 3, 'x') = S ("xxx"),
              "Head on empty Source should produce Count copies of Pad");
   end Test_Head_Pad;

   procedure Test_Head_Truncate
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Assert (Head (S ("abcdef"), 3, '.') = S ("abc"),
              "Head should truncate to Count when Source is longer");
      Assert (Head (S ("abc"), 0, '.') = Empty_String,
              "Head with Count = 0 should return Empty_String");
   end Test_Head_Truncate;

   procedure Test_Tail_Pad
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Assert (Tail (S ("abc"), 5, '.') = S ("..abc"),
              "Tail should left-pad with '.' to reach Count");
      Assert (Tail (S (""), 3, 'x') = S ("xxx"),
              "Tail on empty Source should produce Count copies of Pad");
   end Test_Tail_Pad;

   procedure Test_Tail_Truncate
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Assert (Tail (S ("abcdef"), 3, '.') = S ("def"),
              "Tail should truncate from the left to Count when Source is longer");
      Assert (Tail (S ("abc"), 0, '.') = Empty_String,
              "Tail with Count = 0 should return Empty_String");
   end Test_Tail_Truncate;

   procedure Test_Replace_Multi_Byte
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Latin-1 supplement: U+00E9 LATIN SMALL LETTER E WITH ACUTE.
      --  Every backend's Character_Type covers at least U+0000..U+00FF, so
      --  this test runs against all five backends. We build the
      --  e-acute character directly via Character_Type'Val to avoid
      --  any backend-specific encoding rules at the String -> String_Type
      --  boundary (uxstring's To_String_Type expects UTF-8, while standard
      --  and wide* expect Latin-1 bytes).
      E_Acute : constant Character_Type := Character_Type'Val (16#00E9#);
      Source  : constant String_Type := S ("caf") & From_Character (E_Acute);
      Pattern : constant String_Type := From_Character (E_Acute);
      By      : constant String_Type := S ("e");
   begin
      Assert (Replace (Source, Pattern, By) = S ("cafe"),
              "Replace (caf+e-acute, e-acute, e) should yield 'cafe' on every backend");
   end Test_Replace_Multi_Byte;

end String_Extension_Test;
