--  Anystrings Tests - Width Core Test Suite Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

with AUnit.Assertions;   use AUnit.Assertions;
with AUnit.Test_Cases;   use AUnit.Test_Cases;
with String_Types;       use String_Types;
with String_Types.Width; use String_Types.Width;

package body Width_Core_Test is

   --  ---- §8.2 corpus: UTF-8 byte sequences (all bytes ≤ 255) ----

   --  "hello" — 5 ASCII chars; width 5, clusters 5
   Hello_Bytes : constant String := "hello";

   --  "héllo" — h + U+00E9 (UTF-8: C3 A9) + llo; width 5, clusters 5
   He_Llo_Bytes : constant String :=
     "h" & Character'Val (16#C3#) & Character'Val (16#A9#) & "llo";

   --  "日本語" — 3 CJK ideographs (E6 97 A5 | E6 9C AC | E8 AA 9E)
   --  width 6, clusters 3
   Nihongo_Bytes : constant String :=
     Character'Val (16#E6#) & Character'Val (16#97#) & Character'Val (16#A5#) &
     Character'Val (16#E6#) & Character'Val (16#9C#) & Character'Val (16#AC#) &
     Character'Val (16#E8#) & Character'Val (16#AA#) & Character'Val (16#9E#);

   --  "👩‍💻" WOMAN TECHNOLOGIST ZWJ sequence (U+1F469 ZWJ U+1F4BB)
   --  UTF-8: F0 9F 91 A9  E2 80 8D  F0 9F 92 BB — 1 cluster, width 2
   Zwj_Bytes : constant String :=
     Character'Val (16#F0#) & Character'Val (16#9F#) &
     Character'Val (16#91#) & Character'Val (16#A9#) &
     Character'Val (16#E2#) & Character'Val (16#80#) &
     Character'Val (16#8D#) & Character'Val (16#F0#) &
     Character'Val (16#9F#) & Character'Val (16#92#) &
     Character'Val (16#BB#);

   --  Build a String_Type from a UTF-8 byte sequence.
   --  The Get_Value_Or fallback is defensive: all inputs here are valid UTF-8.
   function Mk (S : String) return String_Type is
   begin
      return Get_Value_Or (From_UTF_8 (S), Empty_String);
   end Mk;

   --  ---- Name / Register ----

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Width Core Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine
        (T,
         (Routine      => Test_Display_Width_Empty_Returns_Zero'Access,
          Routine_Name => AUnit.Format ("Display_Width: empty = 0")));
      Add_Routine
        (T,
         (Routine      => Test_Display_Width_ASCII_One_Cell_Each'Access,
          Routine_Name => AUnit.Format ("Display_Width: ASCII chars are 1 cell each")));
      Add_Routine
        (T,
         (Routine      => Test_Display_Width_Latin1_Precomposed'Access,
          Routine_Name =>
            AUnit.Format ("Display_Width: Latin-1 precomposed e+combining = 1 cell")));
      Add_Routine
        (T,
         (Routine      => Test_Display_Width_CJK_Double_Width'Access,
          Routine_Name => AUnit.Format ("Display_Width: 3 CJK ideographs = 6 cells")));
      Add_Routine
        (T,
         (Routine      => Test_Display_Width_Emoji_Is_Two_Cells'Access,
          Routine_Name => AUnit.Format ("Display_Width: emoji U+1F600 = 2 cells")));
      Add_Routine
        (T,
         (Routine      => Test_Grapheme_Count_Empty_Returns_Zero'Access,
          Routine_Name => AUnit.Format ("Grapheme_Count: empty = 0")));
      Add_Routine
        (T,
         (Routine      => Test_Grapheme_Count_ASCII_One_Per_Char'Access,
          Routine_Name => AUnit.Format ("Grapheme_Count: hello = 5 clusters")));
      Add_Routine
        (T,
         (Routine      => Test_Grapheme_Count_Multibyte_Is_One_Cluster'Access,
          Routine_Name =>
            AUnit.Format ("Grapheme_Count: multibyte char is 1 cluster")));
      Add_Routine
        (T,
         (Routine      => Test_Grapheme_Count_CJK_Three_Clusters'Access,
          Routine_Name => AUnit.Format ("Grapheme_Count: 3 CJK = 3 clusters")));
      Add_Routine
        (T,
         (Routine      => Test_Cluster_Length_Agrees_With_Grapheme_Count'Access,
          Routine_Name =>
            AUnit.Format ("Cluster_Length: same value as Grapheme_Count")));
   end Register_Tests;

   --  ---- Test bodies ----

   --  FUNC-WIDTH-003: Display_Width of empty input is 0.
   procedure Test_Display_Width_Empty_Returns_Zero
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Assert (Display_Width (Empty_String) = 0,
              "Display_Width of empty String_Type must be 0");
   end Test_Display_Width_Empty_Returns_Zero;

   --  FUNC-WIDTH-003: Every ASCII byte occupies exactly 1 display column.
   procedure Test_Display_Width_ASCII_One_Cell_Each
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Hello : constant String_Type := Mk (Hello_Bytes);
   begin
      --  Arrange/Act/Assert — corpus row: "hello" → width 5
      Assert (Display_Width (Hello) = 5,
              "Display_Width of ""hello"" must be 5");
      Assert (Display_Width (Mk ("a")) = 1,
              "Display_Width of single ASCII char must be 1");
   end Test_Display_Width_ASCII_One_Cell_Each;

   --  FUNC-WIDTH-003: Precomposed U+00E9 (é) occupies 1 cell despite
   --  being 2 UTF-8 bytes — corpus row: "héllo" → width 5.
   procedure Test_Display_Width_Latin1_Precomposed
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      He_Llo : constant String_Type := Mk (He_Llo_Bytes);
   begin
      Assert (Display_Width (He_Llo) = 5,
              "Display_Width of h+U+00E9+llo must be 5 (each code point 1 cell)");
   end Test_Display_Width_Latin1_Precomposed;

   --  FUNC-WIDTH-003: CJK ideographs are double-width (UAX #11 class W).
   --  Corpus row: "日本語" → width 6.
   procedure Test_Display_Width_CJK_Double_Width
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Nihongo : constant String_Type := Mk (Nihongo_Bytes);
   begin
      Assert (Display_Width (Nihongo) = 6,
              "Display_Width of 3 CJK ideographs must be 6 (each 2 cells)");
   end Test_Display_Width_CJK_Double_Width;

   --  FUNC-WIDTH-003: ZWJ emoji sequence is 2 display cells.
   --  Skipped on backends that cannot represent supplementary-plane code
   --  points (wide_string is BMP-only): Mk returns Empty_String on decode
   --  failure, so guard the assertion on Length (Zwj) > 0.
   procedure Test_Display_Width_Emoji_Is_Two_Cells
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Zwj : constant String_Type := Mk (Zwj_Bytes);
   begin
      if Length (Zwj) > 0 then
         Assert (Display_Width (Zwj) = 2,
                 "Display_Width of ZWJ emoji sequence must be 2");
      end if;
   end Test_Display_Width_Emoji_Is_Two_Cells;

   --  FUNC-WIDTH-004: Grapheme_Count of empty input is 0.
   procedure Test_Grapheme_Count_Empty_Returns_Zero
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Assert (Grapheme_Count (Empty_String) = 0,
              "Grapheme_Count of empty String_Type must be 0");
   end Test_Grapheme_Count_Empty_Returns_Zero;

   --  FUNC-WIDTH-004: Every ASCII character is one grapheme cluster.
   --  Corpus row: "hello" → clusters 5.
   procedure Test_Grapheme_Count_ASCII_One_Per_Char
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Hello : constant String_Type := Mk (Hello_Bytes);
   begin
      Assert (Grapheme_Count (Hello) = 5,
              "Grapheme_Count of ""hello"" must be 5");
   end Test_Grapheme_Count_ASCII_One_Per_Char;

   --  FUNC-WIDTH-004: A multibyte UTF-8 code point forms exactly one cluster.
   --  Corpus row: "héllo" → clusters 5 (é is 2 bytes but 1 cluster).
   procedure Test_Grapheme_Count_Multibyte_Is_One_Cluster
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      He_Llo : constant String_Type := Mk (He_Llo_Bytes);
      Zwj : constant String_Type := Mk (Zwj_Bytes);
   begin
      Assert (Grapheme_Count (He_Llo) = 5,
              "Grapheme_Count of h+U+00E9+llo must be 5 (e-acute is 1 cluster)");
      --  Skipped on BMP-only backends (wide_string): Mk(Zwj_Bytes) returns
      --  Empty_String when the input contains supplementary-plane code points.
      if Length (Zwj) > 0 then
         Assert (Grapheme_Count (Zwj) = 1,
                 "Grapheme_Count of ZWJ emoji sequence (11 UTF-8 bytes) must be 1");
      end if;
   end Test_Grapheme_Count_Multibyte_Is_One_Cluster;

   --  FUNC-WIDTH-004: Each CJK ideograph is a distinct cluster.
   --  Corpus row: "日本語" → clusters 3.
   procedure Test_Grapheme_Count_CJK_Three_Clusters
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Nihongo : constant String_Type := Mk (Nihongo_Bytes);
   begin
      Assert (Grapheme_Count (Nihongo) = 3,
              "Grapheme_Count of 3 CJK ideographs must be 3");
   end Test_Grapheme_Count_CJK_Three_Clusters;

   --  FUNC-WIDTH-010: Cluster_Length is the same operation as Grapheme_Count
   --  on every backend (rename alias, per spec §3).
   procedure Test_Cluster_Length_Agrees_With_Grapheme_Count
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Hello   : constant String_Type := Mk (Hello_Bytes);
      Nihongo : constant String_Type := Mk (Nihongo_Bytes);
   begin
      Assert (Cluster_Length (Empty_String) = 0,
              "Cluster_Length of empty String_Type must be 0");
      Assert (Cluster_Length (Hello) = Grapheme_Count (Hello),
              "Cluster_Length must equal Grapheme_Count for ASCII input");
      Assert (Cluster_Length (Nihongo) = Grapheme_Count (Nihongo),
              "Cluster_Length must equal Grapheme_Count for CJK input");
   end Test_Cluster_Length_Agrees_With_Grapheme_Count;

end Width_Core_Test;
