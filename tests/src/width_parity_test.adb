--  Width_Parity_Test — Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
--
--  Corpus: "héllo 日本語"
--    UTF-8: 68 C3A9 6C6C6F 20 E697A5 E69CAC E8AA9E  (16 bytes)
--    Display_Width = 12   (héllo=5, space=1, 日本語=6)
--    Grapheme_Count = 9   (5 + 1 + 3)

with AUnit.Assertions;   use AUnit.Assertions;
with AUnit.Test_Cases;   use AUnit.Test_Cases;
with String_Types;       use String_Types;
with String_Types.Width; use String_Types.Width;

package body Width_Parity_Test is

   --  "héllo 日本語" as UTF-8 bytes.
   Corpus_Bytes : constant String :=
     "h"
     & Character'Val (16#C3#) & Character'Val (16#A9#)   --  é (U+00E9)
     & "llo "
     & Character'Val (16#E6#) & Character'Val (16#97#) & Character'Val (16#A5#)  --  日
     & Character'Val (16#E6#) & Character'Val (16#9C#) & Character'Val (16#AC#)  --  本
     & Character'Val (16#E8#) & Character'Val (16#AA#) & Character'Val (16#9E#); --  語

   function Corpus return String_Type is
   begin
      return Get_Value_Or (From_UTF_8 (Corpus_Bytes), Empty_String);
   end Corpus;

   --  ---- Name / Register ----

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Width Parity Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine (T,
         (Routine      => Test_All_Width_Symbols_Callable_On_Mixed_Corpus'Access,
          Routine_Name =>
            AUnit.Format ("All width symbols callable on héllo+CJK corpus (parity)")));
   end Register_Tests;

   --  FUNC-WIDTH-002: every public symbol in String_Types.Width resolves and
   --  returns a coherent value on the mixed corpus.
   procedure Test_All_Width_Symbols_Callable_On_Mixed_Corpus
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S  : constant String_Type := Corpus;

      --  FUNC-WIDTH-003: Display_Width
      W  : constant Natural := Display_Width (S);

      --  FUNC-WIDTH-004: Grapheme_Count
      GC : constant Natural := Grapheme_Count (S);

      --  FUNC-WIDTH-010: Cluster_Length (alias for Grapheme_Count)
      CL : constant Natural := Cluster_Length (S);

      --  FUNC-WIDTH-005: Graphemes iterable view
      Concat : String_Type := Empty_String;

      --  FUNC-WIDTH-011: Cluster_Element (1-based; 9 clusters total)
      G1 : constant Grapheme := Cluster_Element (S, 1);

      --  FUNC-WIDTH-012: Cluster_Slice (clusters 1..3 = "héll")
      Sub : constant String_Type := Cluster_Slice (S, 1, 3);

      --  FUNC-WIDTH-013: Cluster_Head / Cluster_Tail
      Hd : constant String_Type := Cluster_Head (S, 3);
      Tl : constant String_Type := Cluster_Tail (S, 3);

      --  FUNC-WIDTH-014: Head_By_Width
      HR : constant Width_Slice_Result := Head_By_Width (S, 10);

      --  FUNC-WIDTH-015: Truncate_With_Ellipsis
      TR : constant String_Type := Truncate_With_Ellipsis (S, 8);

      --  FUNC-WIDTH-016: Pad_To_Width (Right, Left, Both)
      PR : constant String_Type := Pad_To_Width (S, 20, ' ', Right);
      PL : constant String_Type := Pad_To_Width (S, 20, ' ', Left);
      PB : constant String_Type := Pad_To_Width (S, 20, ' ', Both);

   begin
      --  ---- scalar queries ----
      Assert (W = 12,  "Display_Width (corpus) expected 12");
      Assert (GC = 9,  "Grapheme_Count (corpus) expected 9");
      Assert (CL = 9,  "Cluster_Length (corpus) expected 9");

      --  ---- Graphemes concat identity (FUNC-WIDTH-005) ----
      for G of Graphemes (S) loop
         Concat := Concat & G.Slice;
      end loop;
      Assert (Concat = S, "Graphemes slice concat must reproduce the corpus");

      --  ---- cluster indexing ----
      Assert (G1.Width >= 1,
              "Cluster_Element (corpus, 1).Width must be >= 1");
      Assert (Cluster_Length (Sub) = 3,
              "Cluster_Slice (corpus, 1, 3) must have 3 clusters");
      Assert (Cluster_Length (Hd) = 3,
              "Cluster_Head (corpus, 3) must have 3 clusters");
      Assert (Cluster_Length (Tl) = 3,
              "Cluster_Tail (corpus, 3) must have 3 clusters");

      --  ---- width-budget helpers ----
      Assert (HR.Width <= 10,
              "Head_By_Width result.Width must be <= 10");
      Assert (Display_Width (TR) <= 8,
              "Truncate_With_Ellipsis result must have Display_Width <= 8");
      Assert (Display_Width (PR) = 20,
              "Pad_To_Width Right must produce Display_Width = 20");
      Assert (Display_Width (PL) = 20,
              "Pad_To_Width Left must produce Display_Width = 20");
      Assert (Display_Width (PB) = 20,
              "Pad_To_Width Both must produce Display_Width = 20");

      --  ---- Default_Ellipsis is a valid String_Type ----
      Assert (Display_Width (Default_Ellipsis) >= 1,
              "Default_Ellipsis must have Display_Width >= 1");
   end Test_All_Width_Symbols_Callable_On_Mixed_Corpus;

end Width_Parity_Test;
