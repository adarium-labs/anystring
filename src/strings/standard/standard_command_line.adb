--  Standard_Command_Line - body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
--
--  @summary
--  Body for the standard backend's Ada.Command_Line bridge. SPARK_Mode Off.
--
--  @description
--  Delegates to Ada.Command_Line, converting Standard.String results via
--  Ada.Strings.Unbounded.To_Unbounded_String (byte identity).
--  Ada.Command_Line is not SPARK-provable; this body is SPARK_Mode Off while
--  the spec retains SPARK_Mode On (per tech-spec §7).

package body Standard_Command_Line with SPARK_Mode => Off is

   --  @relation FUNC-CMDLINE-001
   function Argument_Count return Natural is
     (Ada.Command_Line.Argument_Count);

   --  @relation FUNC-CMDLINE-002, FUNC-CMDLINE-003, FUNC-CMDLINE-008
   function Argument (Number : Positive) return Ada.Strings.Unbounded.Unbounded_String is
     (Ada.Strings.Unbounded.To_Unbounded_String (Ada.Command_Line.Argument (Number)));

   --  @relation FUNC-CMDLINE-004, FUNC-CMDLINE-008
   function Command_Name return Ada.Strings.Unbounded.Unbounded_String is
     (Ada.Strings.Unbounded.To_Unbounded_String (Ada.Command_Line.Command_Name));

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

end Standard_Command_Line;
