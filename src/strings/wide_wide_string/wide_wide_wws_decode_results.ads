--  Wide_Wide_WWS_Decode_Results - WWS_Decode_Results instance for wide_wide_string
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

--  @summary
--  Instantiation of Anystrings_WWS_Decode_Results for Unbounded_Wide_Wide_String.

with Anystrings_WWS_Decode_Results;
with Wide_Wide_String_Operations;

package Wide_Wide_WWS_Decode_Results is new
  Anystrings_WWS_Decode_Results
    (String_Type => Wide_Wide_String_Operations.Unbounded_Wide_Wide_String,
     Null_String => Wide_Wide_String_Operations.Null_Unbounded_Wide_Wide_String);
