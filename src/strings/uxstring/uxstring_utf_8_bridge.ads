-------------------------------------------------------------------------------
--  UXString_UTF_8_Bridge - From_UTF_8 wrapper for the uxstring backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Thin bridge package supplying From_UTF_8_UXString for the uxstring backend.
--
--  @description
--  UXString_Operations cannot return UXString_UTF_8_Results.UTF_8_Decode_Result
--  directly because UXString_UTF_8_Results depends on UXString_Operations
--  (transitively, via UXStrings), which would create a circular dependency.
--  This bridge package breaks the cycle.
--
--  UXString_Strings passes UXString_UTF_8_Bridge.From_UTF_8_UXString as
--  the actual for the From_UTF_8 formal subprogram. String_Types renames it.
--
--  Backend-specific note (uxstring / FUNC-UTF8-013):
--    UXStrings stores data as UTF-8 internally. Decoding is performed via
--    UXStrings.From_UTF_8, which raises Constraint_Error on ill-formed
--    input. This bridge catches any exception and returns Make_Error with
--    Malformed_Byte_Sequence, satisfying the non-raising contract
--    (NFR-UTF8-004, NFR-UTF8-005). No NFC or NFC normalisation is applied
--    after a successful decode; the caller must normalise if canonical
--    comparison is required (FUNC-UTF8-013).
--    Empty input returns Is_Ok = True with an empty UXString (FUNC-UTF8-009).
--
--  Naming: suffixed _UXString to avoid aliasing risk when all four backends'
--  packages are simultaneously visible (e.g. during static analysis).
--
--  Responsibilities:
--    * Declare From_UTF_8_UXString returning UXString_UTF_8_Results.UTF_8_Decode_Result.
--
--  Requirements Coverage: FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010,
--                          FUNC-UTF8-011, FUNC-UTF8-013, NFR-UTF8-004,
--                          NFR-UTF8-005, NFR-UTF8-006
--
--  External Effects: None
--  Thread Safety: Stateless; safe to call from multiple tasks simultaneously.
--  SPARK Status: Not applicable (UXString is not SPARK-clean; body uses
--                exception handling).

--  @relation FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010, FUNC-UTF8-011,
--            FUNC-UTF8-013, NFR-UTF8-004, NFR-UTF8-005

with UXString_UTF_8_Results;

package UXString_UTF_8_Bridge is

   --  @summary Decode a UTF-8 byte sequence into a UXString result.
   --
   --  @description
   --  Total and non-raising (NFR-UTF8-004, NFR-UTF8-005). Calls
   --  UXStrings.From_UTF_8 inside an exception handler. On success, wraps
   --  the UXString in Make_Ok. On any exception (Constraint_Error from the
   --  UXStrings runtime), returns Make_Error (Malformed_Byte_Sequence).
   --  Empty input returns Is_Ok = True with an empty UXString (FUNC-UTF8-009).
   --  No normalisation is performed (FUNC-UTF8-013).
   --
   --  Naming: suffixed _UXString to avoid aliasing risk when all four backends'
   --  packages are simultaneously visible.
   --
   --  @param Source  UTF-8 byte sequence to decode.
   --  @return        UXString_UTF_8_Results.UTF_8_Decode_Result.
   --  @relation FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010, FUNC-UTF8-011,
   --            FUNC-UTF8-013, NFR-UTF8-004, NFR-UTF8-005
   function From_UTF_8_UXString
     (Source : String) return UXString_UTF_8_Results.UTF_8_Decode_Result;

end UXString_UTF_8_Bridge;
