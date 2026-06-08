-------------------------------------------------------------------------------
--  VSS_UTF_8_Bridge - From_UTF_8 body for the vss backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Anystrings_UTF_8;
with Anystrings_UTF_8_Validate;
with VSS.Strings;
with VSS.Strings.Conversions;

package body VSS_UTF_8_Bridge is

   use VSS_UTF_8_Results;

   --  @relation FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010, FUNC-UTF8-011,
   --            FUNC-UTF8-013, NFR-UTF8-004, NFR-UTF8-005
   function From_UTF_8_VSS
     (Source : String) return VSS_UTF_8_Results.UTF_8_Decode_Result
   is
      VR : constant Anystrings_UTF_8_Validate.Validate_Result :=
        Anystrings_UTF_8_Validate.Validate (Source);
   begin
      if not VR.Is_Ok then
         return Make_Error (VR.Error);
      end if;

      --  Source is well-formed UTF-8. VSS.Strings.Conversions.To_Virtual_String
      --  cannot raise here, but we still guard defensively to honour the
      --  total/non-raising contract.
      declare
         Result : constant VSS.Strings.Virtual_String :=
           VSS.Strings.Conversions.To_Virtual_String (Source);
      begin
         return Make_Ok (Result);
      end;
   exception
      when others =>
         return Make_Error (Anystrings_UTF_8.Invalid_Lead_Byte);
   end From_UTF_8_VSS;

end VSS_UTF_8_Bridge;
