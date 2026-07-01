--  VSS_WWS_Decode_Results - WWS_Decode_Results instance for vss
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

--  @summary
--  Instantiation of Anystrings_WWS_Decode_Results for VSS.Strings.Virtual_String.

with Anystrings_WWS_Decode_Results;
with VSS.Strings;
with VSS_Operations;

package VSS_WWS_Decode_Results is new
  Anystrings_WWS_Decode_Results
    (String_Type => VSS.Strings.Virtual_String,
     Null_String => VSS_Operations.Null_Virtual_String);
