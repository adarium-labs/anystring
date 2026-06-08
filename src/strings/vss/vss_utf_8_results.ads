-------------------------------------------------------------------------------
--  VSS_UTF_8_Results - UTF_8_Results instance for the vss backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Instantiation of Anystrings_UTF_8_Results for VSS.Strings.Virtual_String.
--
--  @description
--  Instantiated alongside VSS_Strings so the discriminated result record
--  is written exactly once (Strategy A' — docs/tech-specs/utf8-boundary-api.md
--  §3). The type and its accessors are supplied as the UTF_8 formal package
--  actual when instantiating VSS_Strings, and re-exported via
--  string_types.ads.
--
--  VSS backend note (FUNC-UTF8-013):
--    VSS stores strings as validated UTF-8 internally and forbids surrogate
--    code points by construction. To_UTF_8 calls
--    VSS.Strings.Conversions.To_UTF_8_String directly — the result is
--    always well-formed UTF-8 without any pre-scan or substitution.
--    Conversely, From_UTF_8 validates the input first and wraps any
--    decoding failure as a typed Anystrings_UTF_8 error. No NFC
--    normalisation is applied either way; the caller is responsible for
--    normalisation before comparison if canonical equivalence is required.
--
--  Requirements Coverage: FUNC-UTF8-002, FUNC-UTF8-013, NFR-UTF8-006, NFR-UTF8-009

--  @relation FUNC-UTF8-002, FUNC-UTF8-013, NFR-UTF8-006, NFR-UTF8-009

with Anystrings_UTF_8_Results;
with VSS.Strings;

package VSS_UTF_8_Results is new Anystrings_UTF_8_Results
  (String_Type => VSS.Strings.Virtual_String,
   Null_String => VSS.Strings.Empty_Virtual_String);
