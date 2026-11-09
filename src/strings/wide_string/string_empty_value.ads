-------------------------------------------------------------------------------
--  String_Empty_Value - the empty String_Type and its length (wide_string)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Source of the empty value behind String_Types.Empty_String.
--
--  @description
--  String_Types initialises its public constant Empty_String by calling
--  Null_String_Value while its specification elaborates. A body declared in
--  string_types.adb is not elaborated yet at that point. The function lives
--  here instead, and Elaborate_Body makes the binder elaborate this body
--  before String_Types.
--
--  The body is SPARK_Mode => Off. Length and Null_String_Value carry their
--  contracts as trusted postconditions, checked at run time by the test
--  suite, which is built with assertions enabled.

with Wide_String_Operations;

package String_Empty_Value
  with SPARK_Mode
is

   pragma Elaborate_Body;

   subtype String_Type is Wide_String_Operations.Unbounded_Wide_String;

   function Length (Source : String_Type) return Natural
   with Global => null;

   function Null_String_Value return String_Type
   with Global => null, Post => Length (Null_String_Value'Result) = 0;

end String_Empty_Value;
