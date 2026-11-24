-------------------------------------------------------------------------------
--  String_Empty_Value.Convert - unwrap and wrap Unbounded_Wide_Wide_String (bodies)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

package body String_Empty_Value.Convert
  with SPARK_Mode => Off
is

   function To_Unbounded (Source : String_Type) return Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String
   is (Source.Value);

   function From_Unbounded (Source : Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String) return String_Type
   is ((Value => Source));

end String_Empty_Value.Convert;
