-------------------------------------------------------------------------------
--  String_Types.Command_Line - Command-line bridge (bodies)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with String_Empty_Value.Convert;

package body String_Types.Command_Line with SPARK_Mode => Off is

   package Conv renames String_Empty_Value.Convert;

   function Argument (Number : Positive) return String_Type
   is (Conv.From_Unbounded (Wide_Wide_Command_Line.Argument (Number)));

   function Command_Name return String_Type
   is (Conv.From_Unbounded (Wide_Wide_Command_Line.Command_Name));

end String_Types.Command_Line;
