--  Anystrings Tests - Width Core Test Suite Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
--
--  @summary
--  AUnit test suite: Display_Width, Grapheme_Count, Cluster_Length
--  (FUNC-WIDTH-003, FUNC-WIDTH-004, FUNC-WIDTH-010).
--
--  @description
--  Exercises the three scalar query functions on the §8.2 corpus:
--  ASCII, Latin-1 precomposed, CJK double-width, and emoji sequences.
--  Backend-agnostic: the same source compiles for all five backends
--  (FUNC-WIDTH-002).
--
--  SPARK Status: Not Applicable (test code).

with AUnit.Test_Cases;

package Width_Core_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   --  @relation FUNC-WIDTH-003
   procedure Test_Display_Width_Empty_Returns_Zero
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-003
   procedure Test_Display_Width_ASCII_One_Cell_Each
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-003
   procedure Test_Display_Width_Latin1_Precomposed
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-003
   procedure Test_Display_Width_CJK_Double_Width
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-003
   procedure Test_Display_Width_Emoji_Is_Two_Cells
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-004
   procedure Test_Grapheme_Count_Empty_Returns_Zero
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-004
   procedure Test_Grapheme_Count_ASCII_One_Per_Char
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-004
   procedure Test_Grapheme_Count_Multibyte_Is_One_Cluster
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-004
   procedure Test_Grapheme_Count_CJK_Three_Clusters
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-010
   procedure Test_Cluster_Length_Agrees_With_Grapheme_Count
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end Width_Core_Test;
