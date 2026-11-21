-------------------------------------------------------------------------------
--  Anystrings_UTF_8_Case - Case mapping of UTF-8 storage (shared walker)
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Case mapping of a String that holds UTF-8, in two exact passes, for the
--  standard backend. SPARK_Mode On: every overflow, index and range check of
--  this unit is proved, including that the second pass never writes past the
--  buffer sized by the first.
--
--  @description
--  The storage is cut into pieces. A piece is either a maximal run of
--  canonical sequences (a sequence whose bytes are exactly the UTF-8 of the
--  code point it decodes to), which is decoded, mapped with the full mapping
--  (Final_Sigma context inside the run) and encoded; or one sequence that is
--  not canonical (ill-formed, overlong, surrogate, above U+10FFFF), which is
--  copied unchanged. Piece_Last and Piece_Size are the shape and the size of
--  the piece that starts at an index. Case_Length adds the sizes (pass 1);
--  Case_Map writes the pieces (pass 2) and keeps the bytes written plus the
--  size of the remaining pieces equal to the buffer length.
--
--  Index arithmetic: no index is formed past S'Last. A piece starting at I ends
--  at I + (Step - 1) with Step <= S'Last - I + 1, and the next piece starts at
--  Piece_Last + 1 only when Piece_Last < S'Last, so S'Last = Natural'Last is
--  handled like any other bound.
--
--  The ghost code and the postconditions are not executed (the assertion
--  policy below); GNATprove proves them.

with Anystrings_Simple_Case;
with Anystrings_UTF_8_Replace;

package Anystrings_UTF_8_Case
  with SPARK_Mode
is
   pragma Assertion_Policy (Ghost => Ignore, Post => Ignore);

   subtype Scalar_Limit is Natural range 0 .. 16#10_FFFF#;
   subtype Sequence_Length is Positive range 1 .. 4;

   type Decoded is record
      Code_Point : Scalar_Limit;
      Step       : Sequence_Length;
   end record;

   --  The sequence starting at Buf (Start): its decoded code point (U+FFFD when
   --  ill-formed) and the number of bytes consumed (1 when ill-formed, to
   --  resynchronise on the next byte).
   function Decode (Buf : String; Start : Positive) return Decoded
   with
     Global => null,
     Pre    => Start in Buf'Range,
     Post   => Decode'Result.Step <= Buf'Last - Start + 1;

   --  The bytes of the sequence are exactly the UTF-8 of its code point.
   function Is_Canonical (Buf : String; Start : Positive) return Boolean
   is (declare
         D : constant Decoded := Decode (Buf, Start);
       begin
         Anystrings_Simple_Case.UTF_8_Of (D.Code_Point) = Buf (Start .. Start + (D.Step - 1)))
   with Pre => Start in Buf'Range;

   ---------------------------------------------------------------------------
   --  Pieces
   ---------------------------------------------------------------------------

   --  Last index of the maximal run of canonical sequences that starts at I, or
   --  I - 1 when the sequence at I is not canonical.
   function Run_Last (S : String; I : Positive) return Natural
   with
     Global => null,
     Pre    => I in S'Range,
     Post   => Run_Last'Result in I - 1 .. S'Last;

   --  Bytes of the sequence at I (copied unchanged when it is not canonical).
   function Raw_Step (S : String; I : Positive) return Positive
   is (Decode (S, I).Step)
   with
     Pre  => I in S'Range,
     Post => Raw_Step'Result <= S'Last - I + 1;

   --  Last index of the piece that starts at I.
   function Piece_Last (S : String; I : Positive) return Positive
   is (if Run_Last (S, I) >= I then Run_Last (S, I) else I + (Raw_Step (S, I) - 1))
   with
     Pre  => I in S'Range,
     Post => Piece_Last'Result in I .. S'Last;

   --  Bytes of the piece that starts at I after the mapping.
   function Piece_Size (S : String; I : Positive; Upper : Boolean) return Long_Long_Integer
   is (if Run_Last (S, I) >= I
       then Anystrings_Simple_Case.Mapped_UTF_8_Bytes
              (Anystrings_UTF_8_Replace.Decode_Replacing (S (I .. Run_Last (S, I))), Upper)
       else Long_Long_Integer (Raw_Step (S, I)))
   with
     Pre  => I in S'Range,
     Post => Piece_Size'Result in 0 .. 12 * Long_Long_Integer (Piece_Last (S, I) - I + 1);

   --  Bytes of the pieces from the one that starts at I to the end of S.
   function Rest_Size (S : String; I : Positive; Upper : Boolean) return Long_Long_Integer
   is (Piece_Size (S, I, Upper)
       + (if Piece_Last (S, I) = S'Last then 0 else Rest_Size (S, Piece_Last (S, I) + 1, Upper)))
   with
     Ghost,
     Pre                => I in S'Range,
     Post               => Rest_Size'Result in Piece_Size (S, I, Upper) .. 12 * Long_Long_Integer (S'Last - I + 1),
     Subprogram_Variant => (Decreases => S'Last - I);

   ---------------------------------------------------------------------------
   --  Passes
   ---------------------------------------------------------------------------

   --  Pass 1: size, in bytes, of the case mapping of S.
   function Case_Length (S : String; Upper : Boolean) return Long_Long_Integer
   with
     Global => null,
     Post   =>
       Case_Length'Result = (if S'Length = 0 then 0 else Rest_Size (S, S'First, Upper))
       and then Case_Length'Result in 0 .. 12 * Long_Long_Integer (S'Length);

   --  Pass 2: the case mapping of S, in a buffer of exactly Case_Length bytes.
   function Case_Map (S : String; Upper : Boolean) return String
   with
     Global => null,
     Pre    => Case_Length (S, Upper) <= Long_Long_Integer (Natural'Last),
     Post   =>
       Case_Map'Result'First = 1
       and then Long_Long_Integer (Case_Map'Result'Length) = Case_Length (S, Upper);

   --  S with every canonical sequence replaced by its simple lower-case form
   --  when that form has the same byte length; other bytes are copied. The
   --  result has the bounds and the length of S.
   function Simple_Lower (S : String) return String
   with
     Global => null,
     Post   => Simple_Lower'Result'First = S'First and then Simple_Lower'Result'Length = S'Length;

end Anystrings_UTF_8_Case;
