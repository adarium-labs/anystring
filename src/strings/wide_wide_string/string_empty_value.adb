-------------------------------------------------------------------------------
--  String_Empty_Value - the private String_Type of the wide_wide_string backend (bodies)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

package body String_Empty_Value
  with SPARK_Mode => Off
is

   function Length (Source : String_Type) return Natural
   is (Ada.Strings.Wide_Wide_Unbounded.Length (Source.Value));

   function Null_String_Value return String_Type
   is ((Value => Ada.Strings.Wide_Wide_Unbounded.Null_Unbounded_Wide_Wide_String));

end String_Empty_Value;
