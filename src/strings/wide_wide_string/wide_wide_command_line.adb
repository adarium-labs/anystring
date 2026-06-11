--  Wide_Wide_Command_Line - body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
--
--  @summary
--  Body for the wide_wide_string backend's Ada.Wide_Wide_Command_Line bridge.
--  SPARK_Mode Off.
--
--  @description
--  Calls Ada.Command_Line and decodes the returned Standard.String as UTF-8
--  via Ada.Strings.UTF_Encoding.Wide_Wide_Strings.Decode (Ada 2012, ARM A.4.11).
--  Ada.Wide_Wide_Command_Line (Ada RM A.15.1) is Ada 2022 and unavailable under
--  -gnat2012; this is the encoding-equivalent Ada 2012 alternative.
--  Ada.Command_Line is not SPARK-provable; this body is SPARK_Mode Off.

with Ada.Strings.UTF_Encoding.Wide_Wide_Strings;

package body Wide_Wide_Command_Line with SPARK_Mode => Off is

   --  @relation FUNC-CMDLINE-001
   function Argument_Count return Natural is
     (Ada.Command_Line.Argument_Count);

   --  @relation FUNC-CMDLINE-002, FUNC-CMDLINE-003, FUNC-CMDLINE-008
   function Argument
     (Number : Positive)
      return Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String
   is
     (Ada.Strings.Wide_Wide_Unbounded.To_Unbounded_Wide_Wide_String
        (Ada.Strings.UTF_Encoding.Wide_Wide_Strings.Decode
           (Ada.Command_Line.Argument (Number))));

   --  @relation FUNC-CMDLINE-004, FUNC-CMDLINE-008
   function Command_Name
     return Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String
   is
     (Ada.Strings.Wide_Wide_Unbounded.To_Unbounded_Wide_Wide_String
        (Ada.Strings.UTF_Encoding.Wide_Wide_Strings.Decode
           (Ada.Command_Line.Command_Name)));

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

end Wide_Wide_Command_Line;
