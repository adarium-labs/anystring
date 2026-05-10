-------------------------------------------------------------------------------
--  Standard_UTF_8_Bridge - From_UTF_8 wrapper for the standard backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Thin bridge package supplying From_UTF_8_Standard for the standard backend.
--
--  @description
--  Standard_String_Operations cannot return Standard_UTF_8_Results.UTF_8_Decode_Result
--  directly because Standard_UTF_8_Results depends on Standard_String_Operations,
--  which would create a circular dependency. This separate bridge package breaks
--  that cycle: it withs both Standard_String_Operations (for To_UTF_8) and
--  Standard_UTF_8_Results (for the result type), and declares the one function
--  that bridges between them.
--
--  Standard_Strings passes Standard_UTF_8_Bridge.From_UTF_8_Standard as the
--  actual for the From_UTF_8 formal subprogram. String_Types renames it.
--
--  Responsibilities:
--    * Declare From_UTF_8_Standard returning Standard_UTF_8_Results.UTF_8_Decode_Result.
--
--  Requirements Coverage: FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010,
--                          FUNC-UTF8-011, NFR-UTF8-004, NFR-UTF8-006
--
--  External Effects: None
--  Thread Safety: Stateless; safe to call from multiple tasks simultaneously.
--  SPARK Status: Not applicable (bridge package; body uses GNAT runtime).

--  @relation FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010, FUNC-UTF8-011, NFR-UTF8-004

with Standard_UTF_8_Results;

package Standard_UTF_8_Bridge is

   --  @summary Decode a UTF-8 byte sequence into a Standard backend result.
   --
   --  @description
   --  Total and non-raising (NFR-UTF8-004, NFR-UTF8-005). Runs the shared
   --  six-variant UTF-8 validator first. On failure, returns
   --  Standard_UTF_8_Results.Make_Error (Reason). On success, decodes to
   --  Latin-1; code points > U+00FF that are valid UTF-8 but unrepresentable
   --  as a single Latin-1 byte are substituted with '?' (16#3F#) — this lossy
   --  case never occurs on the round-trip domain (surrogate-free strings
   --  produced by To_UTF_8 from this backend), so FUNC-UTF8-011 holds.
   --  Empty input returns Is_Ok = True with an empty string (FUNC-UTF8-009).
   --
   --  Naming: suffixed _Standard to avoid aliasing risk when all four backends'
   --  packages are simultaneously visible (e.g., in cross-backend test harnesses).
   --
   --  @param Source  UTF-8 byte sequence to decode.
   --  @return        Standard_UTF_8_Results.UTF_8_Decode_Result.
   --  @relation FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010, FUNC-UTF8-011, NFR-UTF8-004
   function From_UTF_8_Standard (Source : String) return Standard_UTF_8_Results.UTF_8_Decode_Result;

end Standard_UTF_8_Bridge;
