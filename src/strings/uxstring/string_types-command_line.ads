-------------------------------------------------------------------------------
--  String_Types.Command_Line - Command-line bridge
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Child package of String_Types exposing the Ada.Command_Line bridge.
--
--  @description
--  Thin wrappers over the per-backend UXString_Command_Line implementation
--  package (String_Type is a private wrapper on this backend, so the
--  subprograms cannot be plain renames). Consumers opt in with
--  with String_Types.Command_Line; without forcing Ada.Command_Line into the
--  dependency closure of every with String_Types;.
--
--  Public surface is identical across all five backends
--  (FUNC-FACADE-003), only the implementation differs.
--
--  @relation FUNC-FACADE-002, FUNC-FACADE-003, FUNC-FACADE-004
--  @relation FUNC-CMDLINE-001, FUNC-CMDLINE-002, FUNC-CMDLINE-003,
--            FUNC-CMDLINE-004, FUNC-CMDLINE-005, FUNC-CMDLINE-006,
--            FUNC-CMDLINE-007, FUNC-CMDLINE-008, FUNC-CMDLINE-009

with Ada.Command_Line;

package String_Types.Command_Line with SPARK_Mode => Off is

   function Argument_Count return Natural;

   function Argument (Number : Positive) return String_Type;

   function Command_Name return String_Type;

   subtype Exit_Status is Ada.Command_Line.Exit_Status;

   Success : constant Exit_Status := Ada.Command_Line.Success;
   Failure : constant Exit_Status := Ada.Command_Line.Failure;

   procedure Set_Exit_Status (Code : Exit_Status);

   procedure Set_Exit_Status (Code : Integer);

end String_Types.Command_Line;
