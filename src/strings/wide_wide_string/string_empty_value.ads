-------------------------------------------------------------------------------
--  String_Empty_Value - the private String_Type of the wide_wide_string backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Declares the private wrapper over Unbounded_Wide_Wide_String that
--  String_Types re-exports as `String_Type`, with the empty value.
--
--  @description
--  The wrapper keeps the Ada unbounded type out of the public API. A
--  String_Type value can only be built or changed through the operations of
--  String_Types, and those sanitise code points: every non-scalar becomes
--  U+FFFD or is skipped (docs/text-model.md, section 9.6).
--
--  Why this unit and not String_Types itself: String_Types initialises
--  Empty_String from Null_String_Value while its specification elaborates, so
--  the body must be elaborated first (Elaborate_Body). The child
--  String_Empty_Value.Convert gives String_Types and its children access to
--  the unbounded value.
--
--  The full view is in a SPARK_Mode Off private part. The length contracts
--  are trusted and checked at run time by the test suite (assertions on).

with Ada.Strings.Wide_Wide_Unbounded;

package String_Empty_Value
  with SPARK_Mode
is

   pragma Elaborate_Body;

   type String_Type is private;

   function Length (Source : String_Type) return Natural
   with Global => null;

   function Null_String_Value return String_Type
   with Global => null, Post => Length (Null_String_Value'Result) = 0;

private
   pragma SPARK_Mode (Off);

   type String_Type is record
      Value : Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String;
   end record;

end String_Empty_Value;
