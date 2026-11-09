-------------------------------------------------------------------------------
--  String_Empty_Value - the empty String_Type and its length (vss)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Bodies of String_Empty_Value. SPARK_Mode is Off: see the specification.

with VSS_Operations;

package body String_Empty_Value
  with SPARK_Mode => Off
is

   function Length (Source : String_Type) return Natural
   is (VSS_Operations.Length (Source));

   function Null_String_Value return String_Type
   is (VSS_Operations.To_Virtual_String (String'("")));

end String_Empty_Value;
