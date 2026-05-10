-------------------------------------------------------------------------------
--  Wide_Wide_UTF_8_Results - UTF_8_Results instance for wide_wide_string backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Instantiation of Anystrings.UTF_8_Results for Unbounded_Wide_Wide_String.
--
--  @description
--  Instantiated alongside Wide_Wide_Strings so the discriminated result record
--  is written exactly once (Strategy A' — docs/tech-specs/utf8-boundary-api.md §3).
--  The type and its accessors are supplied as the UTF_8 formal package actual
--  when instantiating Wide_Wide_Strings, and re-exported via string_types.ads.
--
--  Requirements Coverage: FUNC-UTF8-002, NFR-UTF8-006, NFR-UTF8-009
--
--  External Effects: None
--  Thread Safety: N/A (no state)
--  SPARK Status: Compatible

--  @relation FUNC-UTF8-002, NFR-UTF8-006, NFR-UTF8-009

with Anystrings_UTF_8_Results;
with Wide_Wide_String_Operations;

package Wide_Wide_UTF_8_Results is new Anystrings_UTF_8_Results
  (String_Type => Wide_Wide_String_Operations.Unbounded_Wide_Wide_String,
   Null_String => Wide_Wide_String_Operations.Null_Unbounded_Wide_Wide_String);
