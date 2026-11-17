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
--
--  Bounds: any String bounds are accepted (Index formals are Integer and only
--  ever take values in Source'Range). The arithmetic is written so that it
--  cannot overflow: a remaining length is always Source'Last - Index with
--  Index in Source'Range, a difference of two bounded integers that is itself
--  within Natural.
--
--  Verification status: this specification is SPARK_Mode On, so gnatprove
--  checks the contracts below for their own well-formedness only. The body is
--  SPARK_Mode Off and gnatprove does not analyse it, so the contracts are NOT
--  proved against the body. The body is evidenced by the boundary tests
--  (Ingress_Boundary_Test, which includes strings whose bounds are near
--  Positive'Last) and by the property gate (Ingress_Replace_Test).
--
--  Resource conditions: no function here raises an exception for an argument
--  that satisfies its precondition, except Storage_Error when the result
--  (a String or Wide_Wide_String sized by the input) cannot be allocated.

package Anystrings_UTF_8_Replace
  with SPARK_Mode => On
is

   --  @summary One scalar, or one maximal ill-formed subpart, starting at Index.
   --  @description Step is the number of bytes consumed (Index + Step is the
   --  next index, or Source'Last + 1 when the subpart ends the string). Scalar
   --  is the decoded code point, or U+FFFD when not Well_Formed. A well-formed
   --  scalar is never a surrogate and never above U+10FFFF.
   procedure Next
     (Source      : String;
      Index       : Integer;
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
   --  @description Linear and allocation-free.
   function Code_Point_Count (Source : String) return Natural
   with
     Post => Code_Point_Count'Result <= Source'Length;

   --  @summary Decode Source, replacing each maximal ill-formed subpart by U+FFFD.
   --  @description Decode_Replacing (Source)'Length = Code_Point_Count (Source).
   --  Allocates the result (Storage_Error if that fails).
   function Decode_Replacing (Source : String) return Wide_Wide_String
   with
     Post => Decode_Replacing'Result'Length <= Source'Length;

   --  @summary Source with each ill-formed subpart replaced by the three bytes
   --  EF BF BD (the UTF-8 encoding of U+FFFD). Equal to Source when Source is
   --  well formed.
   --  @description Pre keeps 3 * Source'Length within Natural, so the Post is
   --  overflow-free. Allocates the result (Storage_Error if that fails).
   function Replace_Ill_Formed (Source : String) return String
   with
     Pre  => Source'Length <= Natural'Last / 3,
     Post => Replace_Ill_Formed'Result'Length <= 3 * Source'Length;

   --  @summary Number of code points From_UTF_16 (Source) produces.
   --  @description A high surrogate followed by a low surrogate is one code
   --  point; every other unit (a lone surrogate included) is one. Linear and
   --  allocation-free. Source may end at Positive'Last.
   function UTF_16_Scalar_Count (Source : Wide_String) return Natural
   with
     Post => UTF_16_Scalar_Count'Result <= Source'Length;

   --  @summary Code points of a UTF-16 string. A valid surrogate pair is one
   --  code point; a lone surrogate is U+FFFD; every other unit is itself.
   --  @description From_UTF_16 (Source)'Length = UTF_16_Scalar_Count (Source).
   --  Total (it never raises for any Wide_String); Source may end at
   --  Positive'Last. Allocates the result (Storage_Error if that fails).
   function From_UTF_16 (Source : Wide_String) return Wide_Wide_String
   with
     Post => From_UTF_16'Result'Length <= Source'Length;

   --  @summary UTF-16 code units of Source. A surrogate or a value above
   --  U+10FFFF is replaced by U+FFFD first (policy P); a leading U+FEFF is kept.
   --  @description Pre keeps 2 * Source'Length within Natural, so the Post is
   --  overflow-free. Allocates the result (Storage_Error if that fails).
   function To_UTF_16 (Source : Wide_Wide_String) return Wide_String
   with
     Pre  => Source'Length <= Natural'Last / 2,
     Post => To_UTF_16'Result'Length <= 2 * Source'Length;

end Anystrings_UTF_8_Replace;
