--  String_Types.Command_Line - Command-line bridge re-exports
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
--
--  @summary
--  Child package of String_Types exposing the Ada.Command_Line bridge.
--
--  @description
--  Pure renames of the per-backend Standard_Command_Line implementation
--  package, so that consumers can opt in to the command-line API with
--  with String_Types.Command_Line; without forcing
--  Ada.Command_Line into the dependency closure of every
--  with String_Types;.
--
--  Public surface is identical across all five backends
--  (FUNC-FACADE-003), only the rename targets differ.
--
--  @relation FUNC-FACADE-002, FUNC-FACADE-003, FUNC-FACADE-004
--  @relation FUNC-CMDLINE-001, FUNC-CMDLINE-002, FUNC-CMDLINE-003,
--            FUNC-CMDLINE-004, FUNC-CMDLINE-005, FUNC-CMDLINE-006,
--            FUNC-CMDLINE-007, FUNC-CMDLINE-008, FUNC-CMDLINE-009

with Standard_Command_Line;

package String_Types.Command_Line with SPARK_Mode is

   function Argument_Count return Natural
     renames Standard_Command_Line.Argument_Count;

   function Argument (Number : Positive) return String_Type
     renames Standard_Command_Line.Argument;

   function Command_Name return String_Type
     renames Standard_Command_Line.Command_Name;

   subtype Exit_Status is Standard_Command_Line.Exit_Status;

   Success : constant Exit_Status := Standard_Command_Line.Success;
   Failure : constant Exit_Status := Standard_Command_Line.Failure;

   procedure Set_Exit_Status (Code : Exit_Status)
     renames Standard_Command_Line.Set_Exit_Status;

   procedure Set_Exit_Status (Code : Integer)
     renames Standard_Command_Line.Set_Exit_Status;

end String_Types.Command_Line;
