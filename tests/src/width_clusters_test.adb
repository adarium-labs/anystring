--  Width_Clusters_Test — Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

with AUnit.Assertions;   use AUnit.Assertions;
with AUnit.Test_Cases;   use AUnit.Test_Cases;
with String_Types;       use String_Types;
with String_Types.Width; use String_Types.Width;

package body Width_Clusters_Test is

   --  ---- §8.2 corpus helpers ----

   --  "hello" — 5 ASCII clusters, Display_Width 5
   Hello_Bytes : constant String := "hello";

   --  "日本語" — 3 CJK clusters (E6 97 A5 | E6 9C AC | E8 AA 9E), Display_Width 6
   Nihongo_Bytes : constant String :=
     Character'Val (16#E6#) & Character'Val (16#97#) & Character'Val (16#A5#) &
     Character'Val (16#E6#) & Character'Val (16#9C#) & Character'Val (16#AC#) &
     Character'Val (16#E8#) & Character'Val (16#AA#) & Character'Val (16#9E#);

   --  Build a String_Type from a UTF-8 byte sequence (all inputs here are valid).
   function Mk (S : String) return String_Type is
   begin
      return Get_Value_Or (From_UTF_8 (S), Empty_String);
   end Mk;

   --  ---- Name / Register ----

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Width Cluster Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine (T,
         (Routine      => Test_Graphemes_Empty_Input_No_Iterations'Access,
          Routine_Name => AUnit.Format ("Graphemes: empty input yields no iterations")));
      Add_Routine (T,
         (Routine      => Test_Graphemes_Concat_Reproduces_Input'Access,
          Routine_Name => AUnit.Format ("Graphemes: slice concat reproduces original")));
      Add_Routine (T,
         (Routine      => Test_Graphemes_CJK_Width_And_Code_Points'Access,
          Routine_Name => AUnit.Format ("Graphemes: each CJK cluster width=2, code_points=1")));
      Add_Routine (T,
         (Routine      => Test_Cluster_Element_First_And_Last_ASCII'Access,
          Routine_Name => AUnit.Format ("Cluster_Element: first and last of ASCII string")));
      Add_Routine (T,
         (Routine      => Test_Cluster_Element_CJK_Each_Two_Cells'Access,
          Routine_Name => AUnit.Format ("Cluster_Element: every CJK cluster is 2 cells")));
      Add_Routine (T,
         (Routine      => Test_Cluster_Slice_Full_Range_Equals_Input'Access,
          Routine_Name => AUnit.Format ("Cluster_Slice: 1..N equals original string")));
      Add_Routine (T,
         (Routine      => Test_Cluster_Slice_To_Zero_Returns_Empty'Access,
          Routine_Name => AUnit.Format ("Cluster_Slice: To_Cluster=0 returns Empty_String")));
      Add_Routine (T,
         (Routine      => Test_Cluster_Head_Zero_Returns_Empty'Access,
          Routine_Name => AUnit.Format ("Cluster_Head: Count=0 returns Empty_String")));
      Add_Routine (T,
         (Routine      => Test_Cluster_Head_Exceeds_Length_Returns_Input'Access,
          Routine_Name => AUnit.Format ("Cluster_Head: Count > length returns S unchanged")));
      Add_Routine (T,
         (Routine      => Test_Cluster_Tail_Zero_Returns_Empty'Access,
          Routine_Name => AUnit.Format ("Cluster_Tail: Count=0 and Count>length boundaries")));
      Add_Routine (T,
         (Routine      => Test_Cluster_Head_Tail_CJK_Prefix_Suffix'Access,
          Routine_Name => AUnit.Format ("Cluster_Head/Tail: prefix and suffix on CJK")));
   end Register_Tests;

   --  ---- Grapheme iterator (FUNC-WIDTH-005) ----

   --  FUNC-WIDTH-005: iterating over Empty_String produces no Grapheme records.
   procedure Test_Graphemes_Empty_Input_No_Iterations
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Count : Natural := 0;
   begin
      for G of Graphemes (Empty_String) loop
         Count := Count + G.Code_Points;
      end loop;
      Assert (Count = 0,
              "Graphemes on empty input must yield zero iterations");
   end Test_Graphemes_Empty_Input_No_Iterations;

   --  FUNC-WIDTH-005: concatenating all G.Slice values reproduces the original.
   procedure Test_Graphemes_Concat_Reproduces_Input
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S      : constant String_Type := Mk (Hello_Bytes);
      Result : String_Type          := Empty_String;
   begin
      for G of Graphemes (S) loop
         Result := Result & G.Slice;
      end loop;
      Assert (Result = S,
              "Concatenated Grapheme slices must reproduce the original string");
   end Test_Graphemes_Concat_Reproduces_Input;

   --  FUNC-WIDTH-005: CJK cluster iteration — each cluster has Width=2, Code_Points=1.
   procedure Test_Graphemes_CJK_Width_And_Code_Points
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S           : constant String_Type := Mk (Nihongo_Bytes);
      Total_Width : Natural              := 0;
      Cluster_Cnt : Natural              := 0;
   begin
      for G of Graphemes (S) loop
         Total_Width := Total_Width + G.Width;
         Cluster_Cnt := Cluster_Cnt + 1;
         Assert (G.Width = 2,
                 "Each CJK ideograph cluster must have Width = 2");
         Assert (G.Code_Points = 1,
                 "Each CJK ideograph must be exactly 1 code point");
      end loop;
      Assert (Cluster_Cnt = 3,  "Nihongo (3 CJK ideographs) must yield 3 grapheme clusters");
      Assert (Total_Width = 6,  "Total width of 3 CJK clusters must be 6");
   end Test_Graphemes_CJK_Width_And_Code_Points;

   --  ---- Cluster_Element (FUNC-WIDTH-011) ----

   --  FUNC-WIDTH-011: Cluster_Element (S, 1) is 'h', Cluster_Element (S, 5) is 'o'.
   procedure Test_Cluster_Element_First_And_Last_ASCII
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S  : constant String_Type := Mk (Hello_Bytes);   --  5 clusters
      G1 : constant Grapheme    := Cluster_Element (S, 1);
      G5 : constant Grapheme    := Cluster_Element (S, 5);
   begin
      Assert (G1.Slice = To_String_Type (String'("h")),
              "Cluster_Element (hello, 1).Slice must be 'h'");
      Assert (G5.Slice = To_String_Type (String'("o")),
              "Cluster_Element (hello, 5).Slice must be 'o'");
      Assert (G1.Width = 1,
              "ASCII 'h' must have display width 1");
   end Test_Cluster_Element_First_And_Last_ASCII;

   --  FUNC-WIDTH-011: every CJK cluster has Width=2.
   procedure Test_Cluster_Element_CJK_Each_Two_Cells
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S  : constant String_Type := Mk (Nihongo_Bytes);  --  3 clusters
      G1 : constant Grapheme    := Cluster_Element (S, 1);
      G3 : constant Grapheme    := Cluster_Element (S, 3);
   begin
      Assert (G1.Width = 2, "First CJK cluster (Nihongo[1]) must have display width 2");
      Assert (G3.Width = 2, "Third CJK cluster (Nihongo[3]) must have display width 2");
      Assert (G1.Code_Points = 1, "CJK ideograph is 1 code point");
   end Test_Cluster_Element_CJK_Each_Two_Cells;

   --  ---- Cluster_Slice (FUNC-WIDTH-012) ----

   --  FUNC-WIDTH-012: Cluster_Slice (S, 1, Cluster_Length (S)) = S.
   procedure Test_Cluster_Slice_Full_Range_Equals_Input
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S   : constant String_Type := Mk (Hello_Bytes);
      CL  : constant Natural     := Cluster_Length (S);
      Sub : constant String_Type := Cluster_Slice (S, 1, CL);
   begin
      Assert (Sub = S,
              "Cluster_Slice (S, 1, Cluster_Length) must equal S");
      --  Middle slice: clusters 2..4 of "hello" = "ell"
      Assert (Cluster_Slice (S, 2, 4) = To_String_Type (String'("ell")),
              "Cluster_Slice (hello, 2, 4) must be 'ell'");
   end Test_Cluster_Slice_Full_Range_Equals_Input;

   --  FUNC-WIDTH-012: To_Cluster = 0 is the empty-range convention → Empty_String.
   procedure Test_Cluster_Slice_To_Zero_Returns_Empty
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S   : constant String_Type := Mk (Hello_Bytes);
      Sub : constant String_Type := Cluster_Slice (S, 1, 0);
   begin
      Assert (Sub = Empty_String,
              "Cluster_Slice with To_Cluster = 0 must return Empty_String");
   end Test_Cluster_Slice_To_Zero_Returns_Empty;

   --  ---- Cluster_Head / Cluster_Tail (FUNC-WIDTH-013) ----

   --  FUNC-WIDTH-013: Count = 0 → Empty_String (both functions).
   procedure Test_Cluster_Head_Zero_Returns_Empty
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S : constant String_Type := Mk (Hello_Bytes);
   begin
      Assert (Cluster_Head (S, 0) = Empty_String,
              "Cluster_Head (S, 0) must return Empty_String");
      Assert (Cluster_Head (Empty_String, 0) = Empty_String,
              "Cluster_Head (empty, 0) must return Empty_String");
   end Test_Cluster_Head_Zero_Returns_Empty;

   --  FUNC-WIDTH-013: Count >= Cluster_Length → S unchanged (no exception).
   procedure Test_Cluster_Head_Exceeds_Length_Returns_Input
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S  : constant String_Type := Mk (Hello_Bytes);   --  5 clusters
      CL : constant Natural     := Cluster_Length (S);
   begin
      Assert (Cluster_Head (S, CL) = S,
              "Cluster_Head (S, Cluster_Length) must return S unchanged");
      Assert (Cluster_Head (S, CL + 10) = S,
              "Cluster_Head (S, Count > length) must return S unchanged");
   end Test_Cluster_Head_Exceeds_Length_Returns_Input;

   --  FUNC-WIDTH-013: Cluster_Tail Count = 0 and Count > length boundaries.
   procedure Test_Cluster_Tail_Zero_Returns_Empty
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S  : constant String_Type := Mk (Hello_Bytes);
      CL : constant Natural     := Cluster_Length (S);
   begin
      Assert (Cluster_Tail (S, 0) = Empty_String,
              "Cluster_Tail (S, 0) must return Empty_String");
      Assert (Cluster_Tail (S, CL + 1) = S,
              "Cluster_Tail (S, Count > length) must return S unchanged");
   end Test_Cluster_Tail_Zero_Returns_Empty;

   --  FUNC-WIDTH-013: Cluster_Head/Tail on CJK produce correct prefix/suffix.
   procedure Test_Cluster_Head_Tail_CJK_Prefix_Suffix
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S    : constant String_Type := Mk (Nihongo_Bytes);  --  3 clusters
      Head : constant String_Type := Cluster_Head (S, 2);
      Tail : constant String_Type := Cluster_Tail (S, 2);
   begin
      Assert (Cluster_Length (Head) = 2,
              "Cluster_Head (Nihongo, 2) must contain exactly 2 clusters");
      Assert (Cluster_Length (Tail) = 2,
              "Cluster_Tail (Nihongo, 2) must contain exactly 2 clusters");
      --  Head ends before the last cluster; Tail starts after the first.
      Assert (Cluster_Element (Head, 1).Width = 2,
              "First cluster of Head must have width 2 (CJK)");
      Assert (Cluster_Element (Tail, 2).Width = 2,
              "Second cluster of Tail must have width 2 (CJK)");
   end Test_Cluster_Head_Tail_CJK_Prefix_Suffix;

end Width_Clusters_Test;
