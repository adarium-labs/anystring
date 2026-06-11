--  Standard_Command_Line - Ada.Command_Line bridge for the standard backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
--
--  @summary
--  Thin bridge over Ada.Command_Line for the standard (Unbounded_String) backend.
--
--  @description
--  Hand-rolled package providing the command-line access API for the standard
--  backend.  Calls Ada.Command_Line.Argument and Ada.Command_Line.Command_Name
--  and converts the returned Standard.String values via
--  Ada.Strings.Unbounded.To_Unbounded_String (byte-identity per tech-spec §11.1).
--
--  Purpose: Expose the command-line access surface for String_Types renames.
--  Responsibilities:
--    * Argument_Count: delegates to Ada.Command_Line.Argument_Count.
--    * Argument:       delegates to Ada.Command_Line.Argument; converts via
--                      Ada.Strings.Unbounded.To_Unbounded_String.
--    * Command_Name:   delegates to Ada.Command_Line.Command_Name; same
--                      conversion; returns empty string when OS provides none.
--    * Exit_Status:    subtype of Ada.Command_Line.Exit_Status with
--                      Success/Failure constants.
--    * Set_Exit_Status: delegates to Ada.Command_Line.Set_Exit_Status.
--  External Effects: Reads Ada.Command_Line state; may set process exit status.
--  Thread Safety: Same as Ada.Command_Line (implementation-defined).
--  SPARK Status: Spec SPARK_Mode On; body SPARK_Mode Off (Ada.Command_Line
--                is not provable).
--
--  @relation FUNC-CMDLINE-001, FUNC-CMDLINE-002, FUNC-CMDLINE-003,
--            FUNC-CMDLINE-004, FUNC-CMDLINE-005, FUNC-CMDLINE-006,
--            FUNC-CMDLINE-007, FUNC-CMDLINE-008, FUNC-CMDLINE-009

with Ada.Command_Line;
with Ada.Strings.Unbounded;

package Standard_Command_Line with SPARK_Mode is

   --  @relation FUNC-CMDLINE-001
   function Argument_Count return Natural;

   --  @relation FUNC-CMDLINE-002, FUNC-CMDLINE-003, FUNC-CMDLINE-008
   function Argument (Number : Positive) return Ada.Strings.Unbounded.Unbounded_String;
   --  Raises Constraint_Error when Number not in 1 .. Argument_Count,
   --  mirroring Ada.Command_Line.Argument semantics (FUNC-CMDLINE-003).

   --  @relation FUNC-CMDLINE-004, FUNC-CMDLINE-008
   function Command_Name return Ada.Strings.Unbounded.Unbounded_String;
   --  Returns the empty Unbounded_String when the OS provides no command name.

   --  @relation FUNC-CMDLINE-005
   subtype Exit_Status is Ada.Command_Line.Exit_Status;

   Success : constant Exit_Status := Ada.Command_Line.Success;
   Failure : constant Exit_Status := Ada.Command_Line.Failure;

   --  @relation FUNC-CMDLINE-006
   procedure Set_Exit_Status (Code : Exit_Status);

   --  @relation FUNC-CMDLINE-007
   procedure Set_Exit_Status (Code : Integer);

end Standard_Command_Line;
