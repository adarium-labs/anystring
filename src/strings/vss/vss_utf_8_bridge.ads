-------------------------------------------------------------------------------
--  VSS_UTF_8_Bridge - From_UTF_8 wrapper for the vss backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Thin bridge package supplying From_UTF_8_VSS for the vss backend.
--
--  @description
--  VSS_Operations cannot return VSS_UTF_8_Results.UTF_8_Decode_Result
--  directly because VSS_UTF_8_Results depends on VSS_Operations
--  (transitively, via VSS.Strings), which would create a circular
--  dependency. This bridge package breaks the cycle.
--
--  VSS_Strings passes VSS_UTF_8_Bridge.From_UTF_8_VSS as the actual for the
--  From_UTF_8 formal subprogram. String_Types renames it.
--
--  Backend-specific note (vss / FUNC-UTF8-013):
--    The bridge validates the input with Anystrings_UTF_8_Validate first to
--    classify malformed input precisely, then constructs the Virtual_String
--    via VSS.Strings.Conversions.To_Virtual_String. The latter would raise
--    Ada.Strings.UTF_Encoding.Encoding_Error on invalid input, but the
--    validator guarantees this never happens on the success path. Any
--    unexpected exception is mapped to Invalid_Lead_Byte defensively.
--    Empty input returns Is_Ok = True with an empty string (FUNC-UTF8-009).
--    No NFC normalisation is performed (FUNC-UTF8-013).
--
--  Naming: suffixed _VSS to avoid aliasing risk when all five backends'
--  packages are simultaneously visible (e.g. during static analysis).
--
--  Requirements Coverage: FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010,
--                          FUNC-UTF8-011, FUNC-UTF8-013, NFR-UTF8-004,
--                          NFR-UTF8-005, NFR-UTF8-006

--  @relation FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010, FUNC-UTF8-011,
--            FUNC-UTF8-013, NFR-UTF8-004, NFR-UTF8-005

with VSS_UTF_8_Results;

package VSS_UTF_8_Bridge is

   --  @summary Decode a UTF-8 byte sequence into a Virtual_String result.
   --
   --  @description
   --  Total and non-raising (NFR-UTF8-004, NFR-UTF8-005). Validates the
   --  input with Anystrings_UTF_8_Validate; on success, constructs a
   --  Virtual_String via VSS.Strings.Conversions and wraps it in Make_Ok.
   --  On validation failure, returns Make_Error with the typed error
   --  category. Empty input returns Is_Ok = True with an empty
   --  Virtual_String (FUNC-UTF8-009). No normalisation is performed
   --  (FUNC-UTF8-013).
   --
   --  @param Source  UTF-8 byte sequence to decode.
   --  @return        VSS_UTF_8_Results.UTF_8_Decode_Result.
   --  @relation FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010, FUNC-UTF8-011,
   --            FUNC-UTF8-013, NFR-UTF8-004, NFR-UTF8-005
   function From_UTF_8_VSS
     (Source : String) return VSS_UTF_8_Results.UTF_8_Decode_Result;

end VSS_UTF_8_Bridge;
