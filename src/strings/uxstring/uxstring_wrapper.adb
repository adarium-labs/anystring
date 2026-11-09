-------------------------------------------------------------------------------
--  UXString_Wrapper - the private String_Type of the uxstring backend (bodies)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

package body UXString_Wrapper
  with SPARK_Mode => Off
is

   function Length (Source : String_Type) return Natural
   is (UXStrings.Length (Source.Value));

   function Null_String_Value return String_Type
   is ((Value => UXStrings.Null_UXString));

end UXString_Wrapper;
