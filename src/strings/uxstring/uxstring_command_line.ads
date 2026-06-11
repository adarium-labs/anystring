--  UXString_Command_Line - Command_Line bridge for the uxstring backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
--
--  @summary
--  Thin bridge over Ada.Command_Line for the uxstring backend.
--
--  @description
--  Hand-rolled package providing the command-line access API for the
--  uxstring backend.  Calls Ada.Command_Line.Argument and
--  Ada.Command_Line.Command_Name and decodes the returned Standard.String
--  as UTF-8 via UXStrings.From_UTF_8 — the explicit UTF-8 ingestion entry
--  point, not the Latin-1 To_String_Type path (per tech-spec §11.1).
--
--  Purpose: Expose the command-line access surface for String_Types renames.
--  Responsibilities:
--    * Argument_Count: delegates to Ada.Command_Line.Argument_Count.
--    * Argument:       delegates to Ada.Command_Line.Argument; decodes result
--                      as UTF-8 via UXStrings.From_UTF_8.
--    * Command_Name:   same.
--    * Exit_Status:    subtype of Ada.Command_Line.Exit_Status (§11.4).
--    * Set_Exit_Status: delegates to Ada.Command_Line.Set_Exit_Status.
--  External Effects: Reads Ada.Command_Line state; may set exit status.
--  Thread Safety: Same as Ada.Command_Line (implementation-defined).
--  SPARK Status: Spec SPARK_Mode On; body SPARK_Mode Off.
--
--  @relation FUNC-CMDLINE-001, FUNC-CMDLINE-002, FUNC-CMDLINE-003,
--            FUNC-CMDLINE-004, FUNC-CMDLINE-005, FUNC-CMDLINE-006,
--            FUNC-CMDLINE-007, FUNC-CMDLINE-008, FUNC-CMDLINE-009

with Ada.Command_Line;
with UXStrings;

package UXString_Command_Line with SPARK_Mode is

   --  @relation FUNC-CMDLINE-001
   function Argument_Count return Natural;

   --  @relation FUNC-CMDLINE-002, FUNC-CMDLINE-003, FUNC-CMDLINE-008
   function Argument (Number : Positive) return UXStrings.UXString;
   --  Raises Constraint_Error when Number not in 1 .. Argument_Count.

   --  @relation FUNC-CMDLINE-004, FUNC-CMDLINE-008
   function Command_Name return UXStrings.UXString;

   --  @relation FUNC-CMDLINE-005
   subtype Exit_Status is Ada.Command_Line.Exit_Status;

   Success : constant Exit_Status := Ada.Command_Line.Success;
   Failure : constant Exit_Status := Ada.Command_Line.Failure;

   --  @relation FUNC-CMDLINE-006
   procedure Set_Exit_Status (Code : Exit_Status);

   --  @relation FUNC-CMDLINE-007
   procedure Set_Exit_Status (Code : Integer);

end UXString_Command_Line;
