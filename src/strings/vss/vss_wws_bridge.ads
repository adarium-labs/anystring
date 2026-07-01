--  VSS_WWS_Bridge - Wide_Wide_String -> Virtual_String checked bridge
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

with VSS_WWS_Decode_Results;

package VSS_WWS_Bridge is

   function From_Wide_Wide_String_VSS_Checked
     (Source : Wide_Wide_String) return VSS_WWS_Decode_Results.WWS_Decode_Result;

end VSS_WWS_Bridge;
