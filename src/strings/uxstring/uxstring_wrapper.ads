-------------------------------------------------------------------------------
--  UXString_Wrapper - the private String_Type of the uxstring backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Declares the private wrapper over UXStrings.UXString that String_Types
--  re-exports as `String_Type`, with the empty value.
--
--  @description
--  Why this type is not declared in String_Types itself:
--  1. `String_Types.Empty_String` must be a constant (a function default such
--     as `Msg : Failure_Text := Empty_String` in a record with a predicated
--     subtype makes GNAT copy the function result into the component without
--     Adjust, then finalize the temporary: the UXString buffer is freed twice).
--     A constant of a private type cannot be initialised in the visible part of
--     the package that declares the type, but it can in another package.
--  2. The full view is a record holding a UXStrings.UXString. It is in a
--     SPARK_Mode Off private part: UXStrings.UXString has an Iterable aspect
--     whose functions read globals, which GNATprove rejects in SPARK units that
--     mention the type.
--
--  Length and Null_String_Value live here for the same reason as
--  String_Empty_Value on the other backends: String_Types initialises
--  `Empty_String` from Null_String_Value while its specification elaborates,
--  so the body must be elaborated first (Elaborate_Body). The bodies are
--  SPARK_Mode Off; the postcondition is trusted and checked at run time by the
--  test suite, which is built with assertions enabled.
--
--  The child package UXString_Wrapper.Convert gives String_Types and its
--  children access to the UXString inside.

private with UXStrings;

package UXString_Wrapper
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
      Value : UXStrings.UXString;
   end record;

end UXString_Wrapper;
