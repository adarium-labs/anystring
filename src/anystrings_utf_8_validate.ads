-------------------------------------------------------------------------------
--  Anystrings_UTF_8_Validate - Shared UTF-8 byte-sequence validator
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Internal (non-public) helper: validates a Standard.String as UTF-8 and
--  returns either Ok or the first error encountered per RFC 3629.
--
--  @description
--  All four backends share this single validation pass to avoid duplicating
--  ~80 lines of byte arithmetic. The function walks the byte sequence and
--  emits the FIRST error in this precedence order:
--
--    1. Invalid_Lead_Byte      — 10xxxxxx as lead, or >= F8 (5-byte sequence)
--    2. Truncated_Sequence     — multi-byte sequence ends before expected length
--    3. Invalid_Continuation  — non-10xxxxxx byte where continuation expected
--    4. Overlong_Encoding      — encodes a code point that fits in fewer bytes
--    5. Surrogate_Code_Point   — encoded scalar in U+D800..U+DFFF
--    6. Code_Point_Out_Of_Range — encoded scalar > U+10FFFF
--
--  Usage: call Validate (S). If the returned Boolean is True, S is well-formed
--  UTF-8; otherwise the error variant describes the first problem found.
--
--  This package is deliberately NOT generic (avoids instantiation overhead)
--  and has no public state (thread-safe, no elaboration concerns).
--
--  Requirements Coverage: FUNC-UTF8-010, NFR-UTF8-007

with Anystrings_UTF_8;

package Anystrings_UTF_8_Validate is

   --  Result of validation: either Ok (no error) or one of six error variants.
   type Validate_Result (Is_Ok : Boolean := True) is record
      case Is_Ok is
         when True =>
            null;

         when False =>
            Error : Anystrings_UTF_8.UTF_8_Decode_Error;
      end case;
   end record;

   --  @summary Validate Source as a UTF-8 byte sequence.
   --  @param Source  Any Standard.String interpreted as UTF-8 bytes.
   --  @return        Validate_Result with Is_Ok = True on success.
   --  @relation FUNC-UTF8-010
   function Validate (Source : String) return Validate_Result;

end Anystrings_UTF_8_Validate;
