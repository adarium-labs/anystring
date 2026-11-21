-------------------------------------------------------------------------------
--  Anystrings Tests - Latin_1_Count_Probe (standard body)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with String_Types; use String_Types;

package body Latin_1_Count_Probe is

   function Replaced_Count_Matches (Raw : String; Expected : Natural) return Boolean is
      Result : constant Latin_1_Conv_Result := To_Latin_1_If_Possible (To_String_Type (Raw));
   begin
      return Get_Replaced_Count (Result) = Expected and then not Is_Ok (Result);
   end Replaced_Count_Matches;

end Latin_1_Count_Probe;
