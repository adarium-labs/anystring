-------------------------------------------------------------------------------
--  String_Empty_Value.Convert - unwrap and wrap Unbounded_Wide_Wide_String
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Conversions between the private String_Type and Unbounded_Wide_Wide_String,
--  for the bodies of String_Types and its children.
--
--  @description
--  Only the bodies use these functions. The specifications of String_Types
--  never mention the unbounded type, so a client cannot build a String_Type
--  from an unbounded value except through the API.
--
--  SPARK_Mode is Off: the profiles mention Unbounded_Wide_Wide_String.
--  Elaborate_Body lets a child of String_Types call the functions while its
--  own specification elaborates.

with Ada.Strings.Wide_Wide_Unbounded;

package String_Empty_Value.Convert
  with SPARK_Mode => Off
is

   pragma Elaborate_Body;

   function To_Unbounded (Source : String_Type) return Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String;

   function From_Unbounded (Source : Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String) return String_Type;

end String_Empty_Value.Convert;
