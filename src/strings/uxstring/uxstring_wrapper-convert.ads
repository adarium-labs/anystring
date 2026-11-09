-------------------------------------------------------------------------------
--  UXString_Wrapper.Convert - unwrap and wrap UXStrings.UXString
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Conversions between the private String_Type and UXStrings.UXString, for the
--  bodies of String_Types and its children.
--
--  @description
--  SPARK_Mode is Off: the profiles mention UXStrings.UXString. Elaborate_Body
--  lets a child of String_Types call the functions while its own
--  specification elaborates.

with UXStrings;

package UXString_Wrapper.Convert
  with SPARK_Mode => Off
is

   pragma Elaborate_Body;

   function To_UXString (Source : String_Type) return UXStrings.UXString;

   function From_UXString (Source : UXStrings.UXString) return String_Type;

end UXString_Wrapper.Convert;
