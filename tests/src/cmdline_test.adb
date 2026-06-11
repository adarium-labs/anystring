--  Anystrings Tests - Command-Line Bridge Test Suite Body
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with String_Types;     use String_Types;

package body Cmdline_Test is

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Command-Line Bridge Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine
        (T, (Routine      => Test_Argument_Count_Is_Natural'Access,
             Routine_Name => AUnit.Format ("Argument_Count is Natural in 0..1024")));
      Add_Routine
        (T, (Routine      => Test_Argument_Indexed_Access_Does_Not_Raise'Access,
             Routine_Name => AUnit.Format ("Argument (I) for I in 1..Argument_Count does not raise")));
      Add_Routine
        (T, (Routine      => Test_Argument_Out_Of_Range_Raises'Access,
             Routine_Name => AUnit.Format ("Argument (Argument_Count + 1) raises Constraint_Error")));
      Add_Routine
        (T, (Routine      => Test_Argument_Positive_Last_Raises'Access,
             Routine_Name => AUnit.Format ("Argument (Positive'Last) raises Constraint_Error")));
      Add_Routine
        (T, (Routine      => Test_Command_Name_Does_Not_Raise'Access,
             Routine_Name => AUnit.Format ("Command_Name returns without raising")));
      Add_Routine
        (T, (Routine      => Test_Set_Exit_Status_Named_Constant'Access,
             Routine_Name => AUnit.Format ("Set_Exit_Status with named constant does not raise")));
      Add_Routine
        (T, (Routine      => Test_Set_Exit_Status_Integer_Overload'Access,
             Routine_Name => AUnit.Format ("Set_Exit_Status with Integer overload does not raise")));
   end Register_Tests;

   --  -----------------------------------------------------------------------
   --  Class 1: Argument_Count baseline (FUNC-CMDLINE-001)
   --  -----------------------------------------------------------------------

   procedure Test_Argument_Count_Is_Natural
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Count : constant Natural := Argument_Count;
   begin
      Assert (Count in 0 .. 1_024,
              "Argument_Count should be in 0 .. 1024 (sanity bound)");
   end Test_Argument_Count_Is_Natural;

   --  -----------------------------------------------------------------------
   --  Class 2: Indexed argument access — call-path exercise (FUNC-CMDLINE-002)
   --  Per tech-spec §11.5 the strict cross-check against Ada.Command_Line is
   --  dropped; assert only non-raising and a valid String_Type return value.
   --  -----------------------------------------------------------------------

   procedure Test_Argument_Indexed_Access_Does_Not_Raise
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Count : constant Natural := Argument_Count;
   begin
      for I in 1 .. Count loop
         declare
            Result : constant String_Type := Argument (I);
         begin
            Assert (Length (Result) >= 0,
                    "Argument should return a valid String_Type for in-range index");
         end;
      end loop;
   end Test_Argument_Indexed_Access_Does_Not_Raise;

   --  -----------------------------------------------------------------------
   --  Class 3: Out-of-range raises Constraint_Error (FUNC-CMDLINE-003)
   --  -----------------------------------------------------------------------

   procedure Test_Argument_Out_Of_Range_Raises
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Raised : Boolean := False;
   begin
      begin
         declare
            Unused : constant String_Type := Argument (Argument_Count + 1);
            pragma Unreferenced (Unused);
         begin
            null;
         end;
      exception
         when Constraint_Error =>
            Raised := True;
      end;
      Assert (Raised,
              "Argument (Argument_Count + 1) should raise Constraint_Error");
   end Test_Argument_Out_Of_Range_Raises;

   procedure Test_Argument_Positive_Last_Raises
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Raised : Boolean := False;
   begin
      begin
         declare
            Unused : constant String_Type := Argument (Positive'Last);
            pragma Unreferenced (Unused);
         begin
            null;
         end;
      exception
         when Constraint_Error =>
            Raised := True;
      end;
      Assert (Raised,
              "Argument (Positive'Last) should raise Constraint_Error");
   end Test_Argument_Positive_Last_Raises;

   --  -----------------------------------------------------------------------
   --  Class 4: Command_Name non-raising (FUNC-CMDLINE-004)
   --  -----------------------------------------------------------------------

   procedure Test_Command_Name_Does_Not_Raise
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Cmd_Name : constant String_Type := Command_Name;
   begin
      Assert (Length (Cmd_Name) >= 0,
              "Command_Name should return a valid String_Type without raising");
   end Test_Command_Name_Does_Not_Raise;

   --  -----------------------------------------------------------------------
   --  Class 5: Exit-status calls do not raise (FUNC-CMDLINE-005, 006, 007)
   --  Ada.Command_Line.Get_Exit_Status is absent from this GNAT distribution;
   --  tests verify call-site type correctness and absence of runtime errors.
   --  Set_Exit_Status (Success) restores state so the runner exits clean.
   --  -----------------------------------------------------------------------

   procedure Test_Set_Exit_Status_Named_Constant
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Raised : Boolean := False;
   begin
      begin
         Set_Exit_Status (Failure);
         Set_Exit_Status (Success);
      exception
         when others =>
            Raised := True;
      end;
      Assert (not Raised,
              "Set_Exit_Status with named constants should not raise");
   end Test_Set_Exit_Status_Named_Constant;

   procedure Test_Set_Exit_Status_Integer_Overload
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Specific_Code : constant Integer := 42;
      Raised        : Boolean          := False;
   begin
      begin
         Set_Exit_Status (Specific_Code);
         Set_Exit_Status (Success);
      exception
         when others =>
            Raised := True;
      end;
      Assert (not Raised,
              "Set_Exit_Status (Integer) overload should not raise");
   end Test_Set_Exit_Status_Integer_Overload;

end Cmdline_Test;
