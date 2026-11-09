-------------------------------------------------------------------------------
--  UXString_Wrapper.Convert - unwrap and wrap UXStrings.UXString (bodies)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

package body UXString_Wrapper.Convert
  with SPARK_Mode => Off
is

   function To_UXString (Source : String_Type) return UXStrings.UXString
   is (Source.Value);

   function From_UXString (Source : UXStrings.UXString) return String_Type
   is ((Value => Source));

end UXString_Wrapper.Convert;
