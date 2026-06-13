--  Width_Clusters_Test — Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
--
--  @summary
--  AUnit test suite: Grapheme iterator, Cluster_Element, Cluster_Slice,
--  Cluster_Head / Cluster_Tail (FUNC-WIDTH-005, FUNC-WIDTH-011,
--  FUNC-WIDTH-012, FUNC-WIDTH-013).
--
--  @description
--  Boundary cases exercised per requirement:
--    Empty input, Count = 0, Count > Cluster_Length (saturation).
--  All tests use the §8.2 corpus (ASCII "hello", CJK "日本語") so the
--  same source compiles for all five backends (FUNC-WIDTH-002).
--
--  SPARK Status: Not Applicable (test code).

with AUnit.Test_Cases;

package Width_Clusters_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   --  ---- Grapheme iterator (FUNC-WIDTH-005) ----

   --  @relation FUNC-WIDTH-005
   procedure Test_Graphemes_Empty_Input_No_Iterations
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-005
   procedure Test_Graphemes_Concat_Reproduces_Input
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-005
   procedure Test_Graphemes_CJK_Width_And_Code_Points
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  ---- Cluster_Element (FUNC-WIDTH-011) ----

   --  @relation FUNC-WIDTH-011
   procedure Test_Cluster_Element_First_And_Last_ASCII
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-011
   procedure Test_Cluster_Element_CJK_Each_Two_Cells
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  ---- Cluster_Slice (FUNC-WIDTH-012) ----

   --  @relation FUNC-WIDTH-012
   procedure Test_Cluster_Slice_Full_Range_Equals_Input
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-012
   procedure Test_Cluster_Slice_To_Zero_Returns_Empty
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  ---- Cluster_Head / Cluster_Tail (FUNC-WIDTH-013) ----

   --  @relation FUNC-WIDTH-013
   procedure Test_Cluster_Head_Zero_Returns_Empty
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-013
   procedure Test_Cluster_Head_Exceeds_Length_Returns_Input
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-013
   procedure Test_Cluster_Tail_Zero_Returns_Empty
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-013
   procedure Test_Cluster_Head_Tail_CJK_Prefix_Suffix
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end Width_Clusters_Test;
