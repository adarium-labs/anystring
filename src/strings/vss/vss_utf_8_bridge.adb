-------------------------------------------------------------------------------
--  VSS_UTF_8_Bridge - From_UTF_8 body for the vss backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Anystrings_UTF_8_Replace;
with Anystrings_UTF_8_Validate;
with VSS_Operations;

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

      --  Source is well-formed UTF-8: decode with the shared path, which keeps a
      --  leading BOM. No library conversion is called (To_Virtual_String rejects
      --  ill-formed input and is not used on ingress).
      return Make_Ok
        (VSS_Operations.From_Wide_Wide_String
           (Anystrings_UTF_8_Replace.Decode_Replacing (Source)));
   end From_UTF_8_VSS;

end VSS_UTF_8_Bridge;
