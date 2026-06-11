--  Anystrings_Conv - Shared non-generic conversion result type
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0

--  @summary
--  Non-generic public type carrying the outcome of a lossy-detection
--  Latin-1 conversion (FUNC-CONV-008, NFR-CONV-005).
--
--  @description
--  Mirrors the placement pattern of Anystrings_UTF_8_Results: a
--  non-generic, public, SPARK-clean package reachable from
--  src/anystrings.ads (the generic) and from every backend's
--  string_types.ads.
--
--  Unlike UTF_8_Decode_Result, this type is NOT generic in String_Type
--  — the conversion result always carries Latin-1 bytes regardless of
--  which backend produced it.  A single non-generic package therefore
--  suffices; no formal-package wrapper is required.
--
--  @relation FUNC-CONV-008, NFR-CONV-001, NFR-CONV-002, NFR-CONV-005

with Ada.Strings.Unbounded;

package Anystrings_Conv with SPARK_Mode is

   --  @summary Status of a Latin-1 conversion.
   --
   --  @description
   --  Ok    — every code point in the source was representable in
   --          Latin-1 (U+0000..U+00FF) and was emitted as the
   --          corresponding single byte.
   --  Lossy — at least one code point fell outside U+0000..U+00FF and
   --          was replaced by '?' (16#3F#).  Replaced_Count records
   --          how many such substitutions occurred.
   type Latin_1_Conv_Status is (Ok, Lossy);

   --  @summary Outcome of To_Latin_1_If_Possible.
   --
   --  @description
   --  Status         — Ok iff Replaced_Count = 0.
   --  Value          — the Latin-1 byte sequence as Unbounded_String
   --                   (with '?' substitutions in the Lossy case).
   --                   Use Get_Value (R) to extract a Standard.String.
   --  Replaced_Count — number of code points replaced by '?'.
   --
   --  Unbounded_String is used rather than String to avoid the
   --  unconstrained-array-in-record restriction.
   --  @relation FUNC-CONV-008
   type Latin_1_Conv_Result is record
      Status         : Latin_1_Conv_Status;
      Value          : Ada.Strings.Unbounded.Unbounded_String;
      Replaced_Count : Natural;
   end record;

   --  @summary True iff every code point was representable in Latin-1.
   --  @relation FUNC-CONV-008
   function Is_Ok (R : Latin_1_Conv_Result) return Boolean
   is (R.Status = Ok);

   --  @summary Extract the Latin-1 byte sequence as a Standard.String.
   --
   --  @description
   --  Total; never raises.  Returns the underlying bytes verbatim,
   --  including any '?' substitutions in the Lossy case.
   --  @relation FUNC-CONV-008
   function Get_Value (R : Latin_1_Conv_Result) return String
   is (Ada.Strings.Unbounded.To_String (R.Value));

   --  @summary How many code points were replaced by '?'.
   --
   --  @description
   --  Returns 0 when Status = Ok; otherwise the number of replacements
   --  performed.  Useful for callers that want a fast lossy check
   --  without unpacking the discriminator.
   --  @relation FUNC-CONV-008
   function Get_Replaced_Count (R : Latin_1_Conv_Result) return Natural
   is (R.Replaced_Count);

end Anystrings_Conv;
