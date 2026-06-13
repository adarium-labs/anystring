--  Width_Helpers_Test — Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
--
--  @summary
--  AUnit test suite: Head_By_Width, Truncate_With_Ellipsis, Pad_To_Width
--  (FUNC-WIDTH-014, FUNC-WIDTH-015, FUNC-WIDTH-016).
--
--  @description
--  Edge cases covered per requirement:
--    Max_Cells = 0, exact-fit budget, oversize budget.
--    Pad_To_Width with Side = Left, Right, Both.
--  Uses §8.2 corpus (ASCII "hello", CJK "日本語").
--
--  SPARK Status: Not Applicable (test code).

with AUnit.Test_Cases;

package Width_Helpers_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   --  ---- Head_By_Width (FUNC-WIDTH-014) ----

   --  @relation FUNC-WIDTH-014
   procedure Test_Head_By_Width_Max_Cells_Zero
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-014
   procedure Test_Head_By_Width_Exact_Fit_Not_Truncated
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-014
   procedure Test_Head_By_Width_Oversize_Budget_Returns_Input
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-014
   procedure Test_Head_By_Width_CJK_Stays_Within_Budget
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  ---- Truncate_With_Ellipsis (FUNC-WIDTH-015) ----

   --  @relation FUNC-WIDTH-015
   procedure Test_Truncate_Fits_Returns_Input_Unchanged
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-015
   procedure Test_Truncate_Oversize_Width_Within_Budget
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-015
   procedure Test_Truncate_Max_Cells_Zero_Returns_Empty
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  ---- Pad_To_Width (FUNC-WIDTH-016) ----

   --  @relation FUNC-WIDTH-016
   procedure Test_Pad_Right_Reaches_Target_Width
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-016
   procedure Test_Pad_Left_Reaches_Target_Width
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-016
   procedure Test_Pad_Both_Centers_String
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-WIDTH-016
   procedure Test_Pad_Already_At_Or_Above_Target_Returns_Input
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end Width_Helpers_Test;
