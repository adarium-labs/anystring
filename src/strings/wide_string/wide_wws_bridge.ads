--  Wide_WWS_Bridge - Wide_Wide_String -> Unbounded_Wide_String checked bridge
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

with Wide_WWS_Decode_Results;

package Wide_WWS_Bridge is

   function From_Wide_Wide_String_Wide_Checked
     (Source : Wide_Wide_String) return Wide_WWS_Decode_Results.WWS_Decode_Result;

end Wide_WWS_Bridge;
