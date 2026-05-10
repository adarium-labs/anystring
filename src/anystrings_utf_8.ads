-------------------------------------------------------------------------------
--  Anystrings_UTF_8 - Shared UTF-8 boundary types (non-generic)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Non-generic, public types shared by every backend's UTF-8 boundary.
--
--  @description
--  Declares the closed enumeration of UTF-8 decode-error categories used by
--  the UTF_8_Decode_Result discriminated record (see Anystrings_UTF_8_Results).
--  Kept free of String_Type so it can be used both by the Anystrings generic
--  parameter list and by every backend's string_types.ads.
--
--  Requirements Coverage: FUNC-UTF8-001, NFR-UTF8-001, NFR-UTF8-003, NFR-UTF8-009
--
--  External Effects: None
--  Thread Safety: N/A (no state)
--  SPARK Status: Compatible

--  @relation FUNC-UTF8-001, NFR-UTF8-001, NFR-UTF8-003, NFR-UTF8-009

package Anystrings_UTF_8
  with SPARK_Mode
is

   --  @summary Closed enumeration of UTF-8 decode failure categories per RFC 3629.
   --
   --  @description
   --  Each variant maps to exactly one class of malformed byte sequence:
   --    Invalid_Lead_Byte      — first byte value not valid as a UTF-8 lead byte
   --                             (e.g., 16#80#..16#BF#, 16#FE#, 16#FF#).
   --    Truncated_Sequence     — lead byte implies a multi-byte sequence but the
   --                             input ends before the expected continuation bytes.
   --    Invalid_Continuation   — a continuation byte (10xxxxxx) was expected but a
   --                             non-continuation byte was found.
   --    Overlong_Encoding      — code point encoded with more bytes than necessary
   --                             (e.g., two-byte encoding of U+0000..U+007F).
   --    Surrogate_Code_Point   — code point in the surrogate range
   --                             U+D800..U+DFFF, which RFC 3629 forbids in UTF-8.
   --    Code_Point_Out_Of_Range — code point > U+10FFFF (beyond Unicode scalar
   --                              range). For the wide backend this variant is also
   --                              used for U+10000..U+10FFFF which are valid Unicode
   --                              scalars but unrepresentable in Wide_Character.
   --  @relation FUNC-UTF8-001, FUNC-UTF8-010
   type UTF_8_Decode_Error is
     (Invalid_Lead_Byte,
      Truncated_Sequence,
      Invalid_Continuation,
      Overlong_Encoding,
      Surrogate_Code_Point,
      Code_Point_Out_Of_Range);

end Anystrings_UTF_8;
