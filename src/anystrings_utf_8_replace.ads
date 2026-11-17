-------------------------------------------------------------------------------
--  Anystrings_UTF_8_Replace - Shared U+FFFD replacement decoder (algorithm R)
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Total UTF-8 decoding with U+FFFD replacement: the one algorithm used by
--  every ingress path (command line, environment, checked From_UTF_8, Text_IO).
--
--  @description
--  Algorithm R is the Unicode Standard section 3.9 "U+FFFD Substitution of
--  Maximal Subparts" (Table 3-7): one U+FFFD per maximal ill-formed subpart.
--  The byte sequences accepted are exactly those of Anystrings_UTF_8_Validate,
--  so this unit replaces what the validator rejects and nothing else. A
--  leading U+FEFF is an ordinary scalar and is kept.
--
--  No library decoder is used on an ingress path: Ada.Strings.UTF_Encoding
--  strips a leading byte order mark and raises on ill-formed input.

package Anystrings_UTF_8_Replace
  with SPARK_Mode => On
is

   --  @summary One scalar, or one maximal ill-formed subpart, starting at Index.
   --  @description Step is the number of bytes consumed (Index + Step is the
   --  next index). Scalar is the decoded code point, or U+FFFD when not
   --  Well_Formed. A well-formed scalar is never a surrogate and never above
   --  U+10FFFF.
   procedure Next
     (Source      : String;
      Index       : Positive;
      Scalar      : out Natural;
      Step        : out Positive;
      Well_Formed : out Boolean)
   with
     Pre  => Index in Source'Range,
     Post => Step <= Source'Last - Index + 1
             and then (if Well_Formed
                       then Scalar <= 16#10_FFFF#
                            and then Scalar not in 16#D800# .. 16#DFFF#
                       else Scalar = 16#FFFD#);

   --  @summary Number of code points Decode_Replacing (Source) produces.
   --  @description Linear, allocation-free.
   function Code_Point_Count (Source : String) return Natural
   with Post => Code_Point_Count'Result <= Source'Length;

   --  @summary Decode Source, replacing each maximal ill-formed subpart by U+FFFD.
   --  @description Total; never raises. Decode_Replacing (Source)'Length =
   --  Code_Point_Count (Source).
   function Decode_Replacing (Source : String) return Wide_Wide_String
   with Post => Decode_Replacing'Result'Length <= Source'Length;

   --  @summary Source with each ill-formed subpart replaced by the three bytes
   --  EF BF BD (the UTF-8 encoding of U+FFFD). Equal to Source when Source is
   --  well formed.
   function Replace_Ill_Formed (Source : String) return String
   with
     Pre  => Source'Length <= Natural'Last / 3,
     Post => Replace_Ill_Formed'Result'Length <= 3 * Source'Length;

   --  @summary UTF-16 code units of Source. A surrogate or a value above
   --  U+10FFFF is replaced by U+FFFD first (policy P); a leading U+FEFF is kept.
   function To_UTF_16 (Source : Wide_Wide_String) return Wide_String
   with Post => To_UTF_16'Result'Length <= 2 * Source'Length;

end Anystrings_UTF_8_Replace;
