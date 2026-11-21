-------------------------------------------------------------------------------
--  Anystrings Tests - Latin_1_Count_Probe (stub body, non-standard backends)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

package body Latin_1_Count_Probe is

   --  To_Latin_1_If_Possible is not part of this backend's String_Types; the
   --  count is checked on standard only (probe_standard/).
   function Replaced_Count_Matches (Raw : String; Expected : Natural) return Boolean is
      pragma Unreferenced (Raw, Expected);
   begin
      return True;
   end Replaced_Count_Matches;

end Latin_1_Count_Probe;
