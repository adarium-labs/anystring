-------------------------------------------------------------------------------
--  String_Types.Command_Line - Command-line bridge (bodies)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with UXString_Command_Line;

with UXString_Wrapper.Convert;

package body String_Types.Command_Line
  with SPARK_Mode => Off
is

   package Conv renames UXString_Wrapper.Convert;

   function Argument_Count return Natural
   is (UXString_Command_Line.Argument_Count);

   function Argument (Number : Positive) return String_Type
   is (Conv.From_UXString (UXString_Command_Line.Argument (Number)));

   function Command_Name return String_Type
   is (Conv.From_UXString (UXString_Command_Line.Command_Name));

   procedure Set_Exit_Status (Code : Exit_Status) is
   begin
      UXString_Command_Line.Set_Exit_Status (Code);
   end Set_Exit_Status;

   procedure Set_Exit_Status (Code : Integer) is
   begin
      UXString_Command_Line.Set_Exit_Status (Code);
   end Set_Exit_Status;

end String_Types.Command_Line;
