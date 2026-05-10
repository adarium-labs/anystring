-------------------------------------------------------------------------------
--  UXString_UTF_8_Results - UTF_8_Results instance for uxstring backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Instantiation of Anystrings.UTF_8_Results for UXStrings.UXString.
--
--  @description
--  Instantiated alongside UXString_Strings so the discriminated result record
--  is written exactly once (Strategy A' — docs/tech-specs/utf8-boundary-api.md §3).
--  The type and its accessors are supplied as the UTF_8 formal package actual
--  when instantiating UXString_Strings, and re-exported via string_types.ads.
--
--  UXString backend note (FUNC-UTF8-013):
--    UXStrings stores strings internally as UTF-8. The To_UTF_8 encoder
--    calls UXStrings.To_UTF_8 directly, which is always well-formed by
--    construction — no surrogate substitution or pre-scan is required.
--    Conversely, From_UTF_8 calls UXStrings.From_UTF_8 and wraps any
--    encoding exception as Malformed_Byte_Sequence. No NFC/NFC normalisation
--    is performed either way; the caller is responsible for normalisation
--    before comparison if canonical equivalence is required (FUNC-UTF8-013).
--
--  Requirements Coverage: FUNC-UTF8-002, FUNC-UTF8-013, NFR-UTF8-006, NFR-UTF8-009
--
--  External Effects: None
--  Thread Safety: N/A (no state)
--  SPARK Status: Not applicable (UXString is not SPARK-clean)

--  @relation FUNC-UTF8-002, FUNC-UTF8-013, NFR-UTF8-006, NFR-UTF8-009

with Anystrings_UTF_8_Results;
with UXStrings; use UXStrings;

package UXString_UTF_8_Results is new Anystrings_UTF_8_Results
  (String_Type => UXString,
   Null_String => Null_UXString);
