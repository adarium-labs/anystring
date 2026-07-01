--  Standard_WWS_Bridge - Wide_Wide_String -> Unbounded_String checked bridge
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

--  @summary
--  Hosts the Report_As_Error variant of the WWS ingress boundary so that
--  Standard_String_Operations remains free of any dependency on
--  Standard_WWS_Decode_Results (which itself is instantiated with
--  Standard_String_Operations.Unbounded_String and would otherwise create
--  a circular unit dependency). Mirrors the design of Standard_UTF_8_Bridge.

with Standard_WWS_Decode_Results;

package Standard_WWS_Bridge is

   --  @summary Encode a Wide_Wide_String as UTF-8 storage, reporting the
   --  first invalid code-point as a structured failure.
   --
   --  @description
   --  Total; never raises. On success returns Make_Ok wrapping the encoded
   --  Unbounded_String. On the first invalid code-point (surrogate or
   --  value > U+10FFFF), returns Make_Error carrying the failure kind,
   --  1-based index (relative to Source'First), and offending
   --  Wide_Wide_Character.
   function From_Wide_Wide_String_Standard_Checked
     (Source : Wide_Wide_String) return Standard_WWS_Decode_Results.WWS_Decode_Result;

end Standard_WWS_Bridge;
