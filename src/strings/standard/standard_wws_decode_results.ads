--  Standard_WWS_Decode_Results - WWS_Decode_Results instance for standard
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

--  @summary
--  Instantiation of Anystrings_WWS_Decode_Results for Unbounded_String.
--
--  @description
--  Instantiated here (alongside Standard_Strings) so the discriminated
--  result record is written exactly once. The type and its accessors
--  are then supplied as the WWS formal package actual when instantiating
--  Standard_Strings, and re-exported via string_types.ads.
--
--  External Effects: None
--  Thread Safety: N/A (no state)
--  SPARK Status: Compatible

with Anystrings_WWS_Decode_Results;
with Standard_String_Operations;

package Standard_WWS_Decode_Results is new
  Anystrings_WWS_Decode_Results
    (String_Type => Standard_String_Operations.Unbounded_String,
     Null_String => Standard_String_Operations.Null_Unbounded_String);
