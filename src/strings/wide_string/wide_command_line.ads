--  Wide_Command_Line - Ada.Wide_Command_Line bridge for the wide_string backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
--
--  @summary
--  Thin bridge over Ada.Wide_Command_Line for the wide_string backend.
--
--  @description
--  Hand-rolled package providing the command-line access API for the
--  wide_string backend.  Calls Ada.Wide_Command_Line.Argument and
--  Ada.Wide_Command_Line.Command_Name (Ada RM A.15.1) — the OS-decoded
--  Wide_String is wrapped via
--  Ada.Strings.Wide_Unbounded.To_Unbounded_Wide_String.  No intermediate
--  Standard.String round-trip; no Latin-1 widening (per tech-spec §11.1).
--
--  Purpose: Expose the command-line access surface for String_Types renames.
--  Responsibilities:
--    * Argument_Count: delegates to Ada.Wide_Command_Line.Argument_Count.
--    * Argument:       delegates to Ada.Wide_Command_Line.Argument; wraps
--                      result as Unbounded_Wide_String directly.
--    * Command_Name:   delegates to Ada.Wide_Command_Line.Command_Name; same.
--    * Exit_Status:    subtype of Ada.Command_Line.Exit_Status (per §11.4,
--                      exit-status path is identical across all five backends).
--    * Set_Exit_Status: delegates to Ada.Command_Line.Set_Exit_Status.
--  External Effects: Reads Ada.Wide_Command_Line state; may set exit status.
--  Thread Safety: Same as Ada.Wide_Command_Line (implementation-defined).
--  SPARK Status: Spec SPARK_Mode On; body SPARK_Mode Off.
--
--  @relation FUNC-CMDLINE-001, FUNC-CMDLINE-002, FUNC-CMDLINE-003,
--            FUNC-CMDLINE-004, FUNC-CMDLINE-005, FUNC-CMDLINE-006,
--            FUNC-CMDLINE-007, FUNC-CMDLINE-008, FUNC-CMDLINE-009

with Ada.Command_Line;
with Ada.Strings.Wide_Unbounded;

package Wide_Command_Line with SPARK_Mode is

   --  @relation FUNC-CMDLINE-001
   function Argument_Count return Natural;

   --  @relation FUNC-CMDLINE-002, FUNC-CMDLINE-003, FUNC-CMDLINE-008
   function Argument (Number : Positive) return Ada.Strings.Wide_Unbounded.Unbounded_Wide_String;
   --  Raises Constraint_Error when Number not in 1 .. Argument_Count.

   --  @relation FUNC-CMDLINE-004, FUNC-CMDLINE-008
   function Command_Name return Ada.Strings.Wide_Unbounded.Unbounded_Wide_String;

   --  @relation FUNC-CMDLINE-005
   subtype Exit_Status is Ada.Command_Line.Exit_Status;

   Success : constant Exit_Status := Ada.Command_Line.Success;
   Failure : constant Exit_Status := Ada.Command_Line.Failure;

   --  @relation FUNC-CMDLINE-006
   procedure Set_Exit_Status (Code : Exit_Status);

   --  @relation FUNC-CMDLINE-007
   procedure Set_Exit_Status (Code : Integer);

end Wide_Command_Line;
