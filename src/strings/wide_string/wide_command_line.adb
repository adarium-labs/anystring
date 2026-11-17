--  Wide_Command_Line - body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
--
--  @summary
--  Body for the wide_string backend's Ada.Wide_Command_Line bridge. SPARK_Mode Off.
--
--  @description
--  Calls Ada.Command_Line and decodes the returned Standard.String as UTF-8
--  with the shared replacement decoder (Anystrings_UTF_8_Replace), then
--  stores it through Wide_String_Operations (Ada 2012 has no Wide_Command_Line).
--  Ada.Wide_Command_Line (Ada RM A.15.1) is Ada 2022 and unavailable under
--  -gnat2012; this is the encoding-equivalent Ada 2012 alternative.
--  Ada.Command_Line is not SPARK-provable; this body is SPARK_Mode Off.

with Anystrings_UTF_8_Replace;
with Wide_String_Operations;

package body Wide_Command_Line with SPARK_Mode => Off is

   --  @relation FUNC-CMDLINE-001
   function Argument_Count return Natural is
     (Ada.Command_Line.Argument_Count);

   --  Ingress: ill-formed UTF-8 becomes U+FFFD (algorithm R, shared unit);
   --  no library decoder runs, so a leading BOM is kept.
   --  @relation FUNC-CMDLINE-002, FUNC-CMDLINE-003, FUNC-CMDLINE-008
   function Argument
     (Number : Positive) return Ada.Strings.Wide_Unbounded.Unbounded_Wide_String
   is
     (Wide_String_Operations.From_Wide_Wide_String
        (Anystrings_UTF_8_Replace.Decode_Replacing (Ada.Command_Line.Argument (Number))));

   --  @relation FUNC-CMDLINE-004, FUNC-CMDLINE-008
   function Command_Name return Ada.Strings.Wide_Unbounded.Unbounded_Wide_String is
     (Wide_String_Operations.From_Wide_Wide_String
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

end Wide_Command_Line;
