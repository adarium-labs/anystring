--  UXString_WWS_Decode_Results - WWS_Decode_Results instance for uxstring
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

--  @summary
--  Instantiation of Anystrings_WWS_Decode_Results for UXStrings.UXString.

with Anystrings_WWS_Decode_Results;
with UXString_Operations;
with UXStrings;

package UXString_WWS_Decode_Results is new
  Anystrings_WWS_Decode_Results
    (String_Type => UXStrings.UXString,
     Null_String => UXString_Operations.Null_UXString);
