-------------------------------------------------------------------------------
--  Standard_UTF_8_Bridge - From_UTF_8 body for the standard backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Anystrings_UTF_8_Validate;
with Standard_String_Operations;

package body Standard_UTF_8_Bridge is

   use Standard_UTF_8_Results;

   --  @relation FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010, FUNC-UTF8-011,
   --            NFR-UTF8-004, FUNC-CONV-001, FUNC-CONV-002
   function From_UTF_8_Standard
     (Source : String) return Standard_UTF_8_Results.UTF_8_Decode_Result
   is
      VR : constant Anystrings_UTF_8_Validate.Validate_Result :=
        Anystrings_UTF_8_Validate.Validate (Source);
   begin
      if not VR.Is_Ok then
         return Make_Error (VR.Error);
      end if;

      --  Per FUNC-CONV-001 (§6.1 Option A), the standard backend stores
      --  UTF-8 bytes verbatim. Since Source is validated as well-formed
      --  UTF-8, store it byte-identity. This preserves the round-trip
      --  invariant FUNC-UTF8-011: From_UTF_8 (To_UTF_8 (S)) = S, because
      --  To_UTF_8 is also byte-identity on this backend.
      return Make_Ok (Standard_String_Operations.To_Unbounded_String (Source));
   end From_UTF_8_Standard;

end Standard_UTF_8_Bridge;
