-------------------------------------------------------------------------------
--  String_Empty_Value - the empty String_Type and its length (wide_string)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Bodies of String_Empty_Value. SPARK_Mode is Off: see the specification.

package body String_Empty_Value
  with SPARK_Mode => Off
is

   function Length (Source : String_Type) return Natural
   is (Wide_String_Operations.Length (Source));

   function Null_String_Value return String_Type
   is (Wide_String_Operations.To_Unbounded_Wide_String (String'("")));

end String_Empty_Value;
