-------------------------------------------------------------------------------
--  Anystrings_Simple_Case - Unicode case mapping of scalar values and runs
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Case mapping shared by the backends, on top of the generated UCD tables.
--  SPARK_Mode On: every overflow, index and range check of this unit is proved.
--
--  @description
--  Lower maps one scalar value with the simple lower-case mapping (used by
--  Simple_To_Lower on every backend). Map_At maps the code point at one index
--  of a run with the full mapping and the Final_Sigma rule (Unicode 3.13). The
--  Mapped_* functions give the size of that mapping of a run in code points,
--  UTF-16 units and UTF-8 bytes. Full_Map, Full_Map_UTF_16 and Put_Mapped_UTF_8
--  build the mapping in a buffer of exactly that size: two passes, no
--  over-allocation. The data is Anystrings_UCD_Case, generated from UCD 15.1.0
--  by tools/ucd.
--
--  Sizes are computed in Long_Long_Integer. A run of N code points maps to at
--  most 12 * N units of any kind, and N <= Natural'Last, so no sum here
--  overflows (proved by the postcondition of Prefix_Size). The builders require
--  the exact size to be at most Natural'Last (the length of a String_Type); the
--  facade states that as the precondition of To_Lower and To_Upper.
--
--  Proof model. Prefix_Size (Run, Upper, Kind, Last) is the size of the mapping
--  of Run (Run'First .. Last). Every loop below keeps its running total equal
--  to it, so the number of units written never exceeds the size computed by the
--  first pass. The ghost code and the postconditions are not executed (the
--  assertion policy below): they would turn each loop into a quadratic or
--  recursive computation. GNATprove proves them instead.

package Anystrings_Simple_Case
  with SPARK_Mode
is
   pragma Assertion_Policy (Ghost => Ignore, Post => Ignore);

   --  The characters a code point maps to (1 .. Count are meaningful).
   subtype Mapped_Chars is Wide_Wide_String (1 .. 3);
   subtype Map_Count is Positive range 1 .. 3;

   type Mapping is record
      Chars : Mapped_Chars;
      Count : Map_Count;
   end record;

   --  All code points of Run are at most U+10FFFF (surrogates included).
   function Is_Valid (Run : Wide_Wide_String) return Boolean
   is (for all C of Run => Wide_Wide_Character'Pos (C) <= 16#10_FFFF#);

   --  Simple lower-case form of a scalar value. Surrogates and values above
   --  U+10FFFF are returned unchanged.
   function Lower (C : Wide_Wide_Character) return Wide_Wide_Character
   with Global => null;

   --  The same on code points: a value that is not a scalar value is returned
   --  unchanged.
   function Simple_Lower_Code_Point (CP : Natural) return Natural
   with
     Global => null,
     Post   =>
       (if CP <= 16#10_FFFF# then Simple_Lower_Code_Point'Result <= 16#10_FFFF#
        else Simple_Lower_Code_Point'Result = CP);

   ---------------------------------------------------------------------------
   --  Sizes
   ---------------------------------------------------------------------------

   type Size_Kind is (Code_Points, UTF_16_Units, UTF_8_Bytes);

   --  UTF-8 bytes of one code point (1 .. 4).
   function UTF_8_Size (CP : Natural) return Positive
   is (if CP <= 16#7F# then 1 elsif CP <= 16#7FF# then 2 elsif CP <= 16#FFFF# then 3 else 4);

   --  Units of C of the given kind (1 .. 4).
   function Size_Of (C : Wide_Wide_Character; Kind : Size_Kind) return Positive
   is (case Kind is
         when Code_Points  => 1,
         when UTF_16_Units => (if Wide_Wide_Character'Pos (C) <= 16#FFFF# then 1 else 2),
         when UTF_8_Bytes  => UTF_8_Size (Wide_Wide_Character'Pos (C)));

   --  Units of the first K characters of M.
   function Partial_Size (M : Mapping; K : Natural; Kind : Size_Kind) return Natural
   is ((if K >= 1 then Size_Of (M.Chars (1), Kind) else 0)
       + (if K >= 2 then Size_Of (M.Chars (2), Kind) else 0)
       + (if K >= 3 then Size_Of (M.Chars (3), Kind) else 0))
   with
     Pre  => K <= 3,
     Post => Partial_Size'Result <= 4 * K;

   --  Full mapping of the code point at Run (I), with the Final_Sigma rule
   --  decided from the context inside Run (Upper selects the upper-case
   --  mapping). A value that is not a scalar value is returned unchanged
   --  (Count = 1). If Run (I) is at most U+10FFFF, so are all its characters.
   function Map_At (Run : Wide_Wide_String; I : Positive; Upper : Boolean) return Mapping
   with
     Global => null,
     Pre    => I in Run'Range,
     Post   =>
       (if Wide_Wide_Character'Pos (Run (I)) <= 16#10_FFFF#
        then (for all K in Mapped_Chars'Range => Wide_Wide_Character'Pos (Map_At'Result.Chars (K)) <= 16#10_FFFF#));

   --  Units of Map_At (Run, I, Upper) (1 .. 12).
   function Size_At (Run : Wide_Wide_String; I : Positive; Upper : Boolean; Kind : Size_Kind) return Positive
   is (Partial_Size (Map_At (Run, I, Upper), Map_At (Run, I, Upper).Count, Kind))
   with Pre => I in Run'Range;

   --  Size of the mapping of Run (Run'First .. Last).
   function Prefix_Size
     (Run : Wide_Wide_String; Upper : Boolean; Kind : Size_Kind; Last : Natural) return Long_Long_Integer
   with
     Ghost,
     Global             => null,
     Pre                => Last >= Run'First - 1 and then Last <= Run'Last,
     Post               => Prefix_Size'Result in 0 .. 12 * Long_Long_Integer (Last - (Run'First - 1)),
     Subprogram_Variant => (Decreases => Last);

   --  Prefix_Size never decreases.
   procedure Lemma_Prefix_Monotone
     (Run : Wide_Wide_String; Upper : Boolean; Kind : Size_Kind; First : Natural; Last : Natural)
   with
     Ghost,
     Global             => null,
     Pre                => First >= Run'First - 1 and then First <= Last and then Last <= Run'Last,
     Post               => Prefix_Size (Run, Upper, Kind, First) <= Prefix_Size (Run, Upper, Kind, Last),
     Subprogram_Variant => (Decreases => Last - First);

   --  Size of the mapping of Run in the given kind.
   function Mapped_Size (Run : Wide_Wide_String; Upper : Boolean; Kind : Size_Kind) return Long_Long_Integer
   with
     Global => null,
     Post   =>
       Mapped_Size'Result = (if Run'Length = 0 then 0 else Prefix_Size (Run, Upper, Kind, Run'Last))
       and then Mapped_Size'Result in 0 .. 12 * Long_Long_Integer (Run'Length);

   --  Number of code points Full_Map (Run, Upper) produces.
   function Mapped_Code_Points (Run : Wide_Wide_String; Upper : Boolean) return Long_Long_Integer
   is (Mapped_Size (Run, Upper, Code_Points));

   --  Number of UTF-16 code units of Full_Map_UTF_16 (Run, Upper): 1 for a code
   --  point up to U+FFFF, 2 above.
   function Mapped_UTF_16_Units (Run : Wide_Wide_String; Upper : Boolean) return Long_Long_Integer
   is (Mapped_Size (Run, Upper, UTF_16_Units));

   --  Number of UTF-8 bytes of Put_Mapped_UTF_8 (Run, Upper): 1 to 4 per code
   --  point.
   function Mapped_UTF_8_Bytes (Run : Wide_Wide_String; Upper : Boolean) return Long_Long_Integer
   is (Mapped_Size (Run, Upper, UTF_8_Bytes));

   ---------------------------------------------------------------------------
   --  Builders
   ---------------------------------------------------------------------------

   --  Full case mapping of Run, one code point at a time, with exactly
   --  Mapped_Code_Points (Run, Upper) code points in the result. A value that is
   --  not a scalar value is copied unchanged. The result may be longer than Run
   --  (U+0130 lower-cases to U+0069 U+0307, and U+00DF upper-cases to "SS").
   function Full_Map (Run : Wide_Wide_String; Upper : Boolean) return Wide_Wide_String
   with
     Global => null,
     Pre    => Mapped_Code_Points (Run, Upper) <= Long_Long_Integer (Natural'Last),
     Post   =>
       Full_Map'Result'First = 1
       and then Long_Long_Integer (Full_Map'Result'Length) = Mapped_Code_Points (Run, Upper);

   --  The same mapping encoded in UTF-16 (a code point above U+FFFF is a
   --  surrogate pair), with exactly Mapped_UTF_16_Units (Run, Upper) units.
   function Full_Map_UTF_16 (Run : Wide_Wide_String; Upper : Boolean) return Wide_String
   with
     Global => null,
     Pre    => Is_Valid (Run) and then Mapped_UTF_16_Units (Run, Upper) <= Long_Long_Integer (Natural'Last),
     Post   =>
       Full_Map_UTF_16'Result'First = 1
       and then Long_Long_Integer (Full_Map_UTF_16'Result'Length) = Mapped_UTF_16_Units (Run, Upper);

   --  UTF-8 bytes of one code point (1 .. 4).
   function UTF_8_Of (CP : Natural) return String
   with
     Global => null,
     Pre    => CP <= 16#10_FFFF#,
     Post   => UTF_8_Of'Result'First = 1 and then UTF_8_Of'Result'Length = UTF_8_Size (CP);

   --  Write the UTF-8 bytes of the mapping of Run to Buf (Pos + 1 ..) and
   --  advance Pos by Mapped_UTF_8_Bytes (Run, Upper). The caller sizes Buf with
   --  a first pass (Mapped_UTF_8_Bytes), so the bytes always fit.
   procedure Put_Mapped_UTF_8
     (Run : Wide_Wide_String; Upper : Boolean; Buf : in out String; Pos : in out Natural)
   with
     Global => null,
     Pre    =>
       Buf'First = 1
       and then Is_Valid (Run)
       and then Pos <= Buf'Length
       and then Long_Long_Integer (Pos) + Mapped_UTF_8_Bytes (Run, Upper) <= Long_Long_Integer (Buf'Length),
     Post   =>
       Long_Long_Integer (Pos) = Long_Long_Integer (Pos'Old) + Mapped_UTF_8_Bytes (Run, Upper);

end Anystrings_Simple_Case;
