--  Width_Helpers_Test — Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

with AUnit.Assertions;   use AUnit.Assertions;
with AUnit.Test_Cases;   use AUnit.Test_Cases;
with String_Types;       use String_Types;
with String_Types.Width; use String_Types.Width;

package body Width_Helpers_Test is

   --  ---- §8.2 corpus helpers ----

   --  "hello" — Display_Width 5, Cluster_Length 5
   Hello_Bytes : constant String := "hello";

   --  "hi" — Display_Width 2, Cluster_Length 2
   Hi_Bytes : constant String := "hi";

   --  "日本語" — Display_Width 6, Cluster_Length 3
   Nihongo_Bytes : constant String :=
     Character'Val (16#E6#) & Character'Val (16#97#) & Character'Val (16#A5#) &
     Character'Val (16#E6#) & Character'Val (16#9C#) & Character'Val (16#AC#) &
     Character'Val (16#E8#) & Character'Val (16#AA#) & Character'Val (16#9E#);

   function Mk (S : String) return String_Type is
   begin
      return Get_Value_Or (From_UTF_8 (S), Empty_String);
   end Mk;

   --  ---- Name / Register ----

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Width Helpers Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine (T,
         (Routine      => Test_Head_By_Width_Max_Cells_Zero'Access,
          Routine_Name => AUnit.Format ("Head_By_Width: Max_Cells=0 yields empty result")));
      Add_Routine (T,
         (Routine      => Test_Head_By_Width_Exact_Fit_Not_Truncated'Access,
          Routine_Name => AUnit.Format ("Head_By_Width: exact-fit budget not truncated")));
      Add_Routine (T,
         (Routine      => Test_Head_By_Width_Oversize_Budget_Returns_Input'Access,
          Routine_Name => AUnit.Format ("Head_By_Width: oversize budget returns S unchanged")));
      Add_Routine (T,
         (Routine      => Test_Head_By_Width_CJK_Stays_Within_Budget'Access,
          Routine_Name => AUnit.Format ("Head_By_Width: CJK width <= budget")));
      Add_Routine (T,
         (Routine      => Test_Truncate_Fits_Returns_Input_Unchanged'Access,
          Routine_Name => AUnit.Format ("Truncate_With_Ellipsis: fits returns S unchanged")));
      Add_Routine (T,
         (Routine      => Test_Truncate_Oversize_Width_Within_Budget'Access,
          Routine_Name => AUnit.Format ("Truncate_With_Ellipsis: oversize result fits budget")));
      Add_Routine (T,
         (Routine      => Test_Truncate_Max_Cells_Zero_Returns_Empty'Access,
          Routine_Name => AUnit.Format ("Truncate_With_Ellipsis: Max_Cells=0 returns empty")));
      Add_Routine (T,
         (Routine      => Test_Pad_Right_Reaches_Target_Width'Access,
          Routine_Name => AUnit.Format ("Pad_To_Width Right: result width = Target_Cells")));
      Add_Routine (T,
         (Routine      => Test_Pad_Left_Reaches_Target_Width'Access,
          Routine_Name => AUnit.Format ("Pad_To_Width Left: result width = Target_Cells")));
      Add_Routine (T,
         (Routine      => Test_Pad_Both_Centers_String'Access,
          Routine_Name => AUnit.Format ("Pad_To_Width Both: result width = Target_Cells")));
      Add_Routine (T,
         (Routine      => Test_Pad_Already_At_Or_Above_Target_Returns_Input'Access,
          Routine_Name => AUnit.Format ("Pad_To_Width: >= target returns S unchanged")));
   end Register_Tests;

   --  ---- Head_By_Width (FUNC-WIDTH-014) ----

   --  FUNC-WIDTH-014: Max_Cells = 0 → Result = Empty, Width = 0, Truncated = True.
   procedure Test_Head_By_Width_Max_Cells_Zero
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S : constant String_Type       := Mk (Hello_Bytes);
      R : constant Width_Slice_Result := Head_By_Width (S, 0);
   begin
      Assert (R.Result = Empty_String,
              "Head_By_Width Max_Cells=0: Result must be Empty_String");
      Assert (R.Width = 0,
              "Head_By_Width Max_Cells=0: Width must be 0");
      Assert (R.Truncated,
              "Head_By_Width Max_Cells=0 on non-empty S: Truncated must be True");
   end Test_Head_By_Width_Max_Cells_Zero;

   --  FUNC-WIDTH-014: budget = Display_Width (S) → Result = S, Truncated = False.
   procedure Test_Head_By_Width_Exact_Fit_Not_Truncated
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S : constant String_Type       := Mk (Hello_Bytes);  --  width 5
      R : constant Width_Slice_Result := Head_By_Width (S, 5);
   begin
      Assert (R.Result = S,
              "Head_By_Width exact-fit: Result must equal S");
      Assert (R.Width = 5,
              "Head_By_Width exact-fit: Width must be 5");
      Assert (not R.Truncated,
              "Head_By_Width exact-fit: Truncated must be False");
   end Test_Head_By_Width_Exact_Fit_Not_Truncated;

   --  FUNC-WIDTH-014: budget >> Display_Width (S) → Result = S, Truncated = False.
   procedure Test_Head_By_Width_Oversize_Budget_Returns_Input
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S : constant String_Type       := Mk (Hello_Bytes);
      R : constant Width_Slice_Result := Head_By_Width (S, 100);
   begin
      Assert (R.Result = S,
              "Head_By_Width oversize budget: Result must equal S");
      Assert (not R.Truncated,
              "Head_By_Width oversize budget: Truncated must be False");
      Assert (R.Width <= 100,
              "Head_By_Width: Result.Width must not exceed Max_Cells");
   end Test_Head_By_Width_Oversize_Budget_Returns_Input;

   --  FUNC-WIDTH-014: CJK budget test — result must stay within cell budget.
   procedure Test_Head_By_Width_CJK_Stays_Within_Budget
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  "日本語" width=6; budget=4 → at most 2 full-width chars (width=4)
      S : constant String_Type       := Mk (Nihongo_Bytes);
      R : constant Width_Slice_Result := Head_By_Width (S, 4);
   begin
      Assert (R.Width <= 4,
              "Head_By_Width CJK budget=4: Width must be <= 4");
      Assert (R.Truncated,
              "Head_By_Width CJK budget=4: Truncated must be True");
      Assert (Display_Width (R.Result) = R.Width,
              "Head_By_Width: Result.Width must equal Display_Width (Result)");
   end Test_Head_By_Width_CJK_Stays_Within_Budget;

   --  ---- Truncate_With_Ellipsis (FUNC-WIDTH-015) ----

   --  FUNC-WIDTH-015: Display_Width (S) <= Max_Cells → return S unchanged.
   procedure Test_Truncate_Fits_Returns_Input_Unchanged
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S : constant String_Type := Mk (Hello_Bytes);  --  width 5
   begin
      Assert (Truncate_With_Ellipsis (S, 5) = S,
              "Truncate_With_Ellipsis fits: must return S unchanged at exact width");
      Assert (Truncate_With_Ellipsis (S, 10) = S,
              "Truncate_With_Ellipsis fits: must return S unchanged at larger budget");
   end Test_Truncate_Fits_Returns_Input_Unchanged;

   --  FUNC-WIDTH-015: Display_Width (S) > Max_Cells → result width <= Max_Cells.
   procedure Test_Truncate_Oversize_Width_Within_Budget
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S : constant String_Type := Mk (Hello_Bytes);    --  width 5
      R : constant String_Type := Truncate_With_Ellipsis (S, 4);
      E : constant Natural     := Display_Width (Default_Ellipsis);
   begin
      Assert (Display_Width (R) <= 4,
              "Truncate_With_Ellipsis oversize: result width must be <= Max_Cells");
      Assert (Display_Width (R) >= E,
              "Truncate_With_Ellipsis oversize: result must contain at least the ellipsis");
   end Test_Truncate_Oversize_Width_Within_Budget;

   --  FUNC-WIDTH-015: Max_Cells < Display_Width (Ellipsis) → Empty_String.
   procedure Test_Truncate_Max_Cells_Zero_Returns_Empty
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S : constant String_Type := Mk (Hello_Bytes);
   begin
      Assert (Truncate_With_Ellipsis (S, 0) = Empty_String,
              "Truncate_With_Ellipsis Max_Cells=0: must return Empty_String");
   end Test_Truncate_Max_Cells_Zero_Returns_Empty;

   --  ---- Pad_To_Width (FUNC-WIDTH-016) ----

   --  FUNC-WIDTH-016: Side = Right → result width = Target_Cells, S is prefix.
   procedure Test_Pad_Right_Reaches_Target_Width
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S : constant String_Type := Mk (Hi_Bytes);     --  width 2
      R : constant String_Type := Pad_To_Width (S, 5, ' ', Right);
   begin
      Assert (Display_Width (R) = 5,
              "Pad_To_Width Right: Display_Width must equal Target_Cells");
      Assert (Starts_With (R, S),
              "Pad_To_Width Right: result must start with original string");
   end Test_Pad_Right_Reaches_Target_Width;

   --  FUNC-WIDTH-016: Side = Left → result width = Target_Cells, S is suffix.
   procedure Test_Pad_Left_Reaches_Target_Width
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S : constant String_Type := Mk (Hi_Bytes);
      R : constant String_Type := Pad_To_Width (S, 5, ' ', Left);
   begin
      Assert (Display_Width (R) = 5,
              "Pad_To_Width Left: Display_Width must equal Target_Cells");
      Assert (Ends_With (R, S),
              "Pad_To_Width Left: result must end with original string");
   end Test_Pad_Left_Reaches_Target_Width;

   --  FUNC-WIDTH-016: Side = Both → result width = Target_Cells, S is interior.
   procedure Test_Pad_Both_Centers_String
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S : constant String_Type := Mk (Hi_Bytes);     --  width 2, target 6
      R : constant String_Type := Pad_To_Width (S, 6, ' ', Both);
   begin
      Assert (Display_Width (R) = 6,
              "Pad_To_Width Both: Display_Width must equal Target_Cells");
      Assert (Contains (R, S),
              "Pad_To_Width Both: result must contain the original string");
   end Test_Pad_Both_Centers_String;

   --  FUNC-WIDTH-016: Display_Width (S) >= Target_Cells → S returned unchanged.
   procedure Test_Pad_Already_At_Or_Above_Target_Returns_Input
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S : constant String_Type := Mk (Hello_Bytes);   --  width 5
   begin
      Assert (Pad_To_Width (S, 5, ' ', Right) = S,
              "Pad_To_Width: exact-fit target must return S unchanged");
      Assert (Pad_To_Width (S, 3, ' ', Right) = S,
              "Pad_To_Width: target < Display_Width must return S unchanged");
   end Test_Pad_Already_At_Or_Above_Target_Returns_Input;

end Width_Helpers_Test;
