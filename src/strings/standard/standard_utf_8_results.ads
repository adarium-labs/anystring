-------------------------------------------------------------------------------
--  Standard_UTF_8_Results - UTF_8_Results instance for the standard backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Instantiation of Anystrings.UTF_8_Results for Unbounded_String.
--
--  @description
--  This package is instantiated here (alongside Standard_Strings) so that the
--  discriminated result record is written exactly once (Strategy A' from
--  docs/tech-specs/utf8-boundary-api.md §3). The type and its accessors are
--  then supplied as the UTF_8 formal package actual when instantiating
--  Standard_Strings, and re-exported via string_types.ads.
--
--  Design choice: instantiation file separate from standard_strings.ads so
--  that string_types.ads can reference Standard_UTF_8_Results directly by
--  name for the subtype declaration (cleaner than a nested package rename).
--
--  Requirements Coverage: FUNC-UTF8-002, NFR-UTF8-006, NFR-UTF8-009
--
--  External Effects: None
--  Thread Safety: N/A (no state)
--  SPARK Status: Compatible

--  @relation FUNC-UTF8-002, NFR-UTF8-006, NFR-UTF8-009

with Anystrings_UTF_8_Results;
with Standard_String_Operations;

package Standard_UTF_8_Results is new
  Anystrings_UTF_8_Results
    (String_Type => Standard_String_Operations.Unbounded_String,
     Null_String => Standard_String_Operations.Null_Unbounded_String);
