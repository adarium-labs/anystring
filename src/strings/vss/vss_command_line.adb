-------------------------------------------------------------------------------
--  VSS_Command_Line - body for the vss backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Body for the vss backend's Ada.Command_Line bridge.
--
--  @description
--  Delegates to Ada.Command_Line and ingests the returned Standard.String as
--  UTF-8 with the shared replacement decoder (Anystrings_UTF_8_Replace).  On
--  Linux/macOS the Ada runtime passes argv bytes through unchanged, so the
--  string is already
--  UTF-8 from the shell.  Ada.Wide_Wide_Command_Line (Ada RM A.15.1) would
--  be more general but is not provided by GNAT 15.x; this UTF-8-decode path
--  is the encoding-equivalent workaround mirroring the wide / wide_wide
--  backends.  SPARK_Mode Off because Ada.Command_Line is not SPARK-provable.
--
--  @relation FUNC-CMDLINE-001, FUNC-CMDLINE-002, FUNC-CMDLINE-003,
--            FUNC-CMDLINE-004, FUNC-CMDLINE-005, FUNC-CMDLINE-006,
--            FUNC-CMDLINE-007, FUNC-CMDLINE-008, FUNC-CMDLINE-009

with Ada.Command_Line;
with Anystrings_UTF_8_Replace;
with VSS_Operations;

package body VSS_Command_Line with SPARK_Mode => Off is

   --  @relation FUNC-CMDLINE-001
   function Argument_Count return Natural is
     (Ada.Command_Line.Argument_Count);

   --  @relation FUNC-CMDLINE-002, FUNC-CMDLINE-003, FUNC-CMDLINE-008
   function Argument (Number : Positive) return VSS.Strings.Virtual_String is
     (VSS_Operations.From_Wide_Wide_String
        (Anystrings_UTF_8_Replace.Decode_Replacing (Ada.Command_Line.Argument (Number))));

   --  @relation FUNC-CMDLINE-004, FUNC-CMDLINE-008
   function Command_Name return VSS.Strings.Virtual_String is
     (VSS_Operations.From_Wide_Wide_String
        (Anystrings_UTF_8_Replace.Decode_Replacing (Ada.Command_Line.Command_Name)));

   --  @relation FUNC-CMDLINE-006
   procedure Set_Exit_Status (Code : Exit_Status) is
   begin
      Ada.Command_Line.Set_Exit_Status (Code);
   end Set_Exit_Status;

   --  @relation FUNC-CMDLINE-007
   procedure Set_Exit_Status (Code : Integer) is
   begin
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Exit_Status (Code));
   end Set_Exit_Status;

end VSS_Command_Line;
