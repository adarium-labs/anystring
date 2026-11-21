-------------------------------------------------------------------------------
--  Anystrings Tests - Latin_1_Count_Probe
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Replaced_Count of To_Latin_1_If_Possible on raw bytes, as a seam.
--
--  @description
--  To_Latin_1_If_Possible and its Latin_1_Conv_Result exist on standard, wide_string
--  and wide_wide_string only, so a test that names them cannot compile on uxstring
--  or vss. The body is chosen by the GPR from STRING_TYPE: probe_standard/ checks the
--  count, probe_stub/ (every other backend) reports True without checking.
package Latin_1_Count_Probe is

   --  True when To_Latin_1_If_Possible of Raw reports Expected replacements and is
   --  Lossy (standard). Always True on the other backends.
   function Replaced_Count_Matches (Raw : String; Expected : Natural) return Boolean;

end Latin_1_Count_Probe;
