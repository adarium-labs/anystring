--  UXString_WWS_Bridge - Wide_Wide_String -> UXString checked bridge
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

with UXString_WWS_Decode_Results;

package UXString_WWS_Bridge is

   function From_Wide_Wide_String_UXString_Checked
     (Source : Wide_Wide_String) return UXString_WWS_Decode_Results.WWS_Decode_Result;

end UXString_WWS_Bridge;
