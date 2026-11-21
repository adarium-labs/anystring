-------------------------------------------------------------------------------
--  Anystrings_Simple_Case - Unicode case mapping of scalar values and runs
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Case mapping shared by the backends, on top of the generated UCD tables.
--
--  @description
--  Lower maps one scalar value with the simple lower-case mapping (used by
--  Simple_To_Lower on every backend). Map_At maps the code point at one index
--  of a run with the full mapping and the Final_Sigma rule (Unicode 3.13), and
--  the Mapped_* functions give the size of that mapping in code points, UTF-16
--  units and UTF-8 bytes. Full_Map builds the full mapping of a run with a
--  buffer of exactly the size Mapped_Code_Points gives: two passes, no
--  over-allocation. The data is Anystrings_UCD_Case, generated from UCD 15.1.0
--  by tools/ucd.
--
--  Sizes are computed in Long_Long_Integer. A run of N code points maps to at
--  most 3 * N code points, and N <= Integer'Last, so no sum here overflows.
--  Full_Map requires the mapped size to be at most Natural'Last (the length of
--  a String_Type); the facade states that as the precondition of To_Lower and
--  To_Upper.
--
--  Not SPARK: the functions return unconstrained or Long_Long_Integer values
--  computed from the SPARK-On Anystrings_UCD_Case lookups.

pragma SPARK_Mode (Off);

package Anystrings_Simple_Case is

   --  The characters a code point maps to (1 .. Count are meaningful).
   subtype Mapped_Chars is Wide_Wide_String (1 .. 3);
   subtype Map_Count is Positive range 1 .. 3;

   --  Simple lower-case form of C. Surrogates and values above U+10FFFF are
   --  returned unchanged.
   function Lower (C : Wide_Wide_Character) return Wide_Wide_Character;

   --  Full case mapping of the code point at Run (I), with the Final_Sigma rule
   --  decided from the context inside Run (Upper selects the upper-case
   --  mapping). Chars (1 .. Count) are the result. A value that is not a scalar
   --  value is returned unchanged (Count = 1).
   procedure Map_At
     (Run   : Wide_Wide_String;
      I     : Positive;
      Upper : Boolean;
      Chars : out Mapped_Chars;
      Count : out Map_Count)
   with Pre => I in Run'Range;

   --  Number of code points Full_Map (Run, Upper) produces.
   function Mapped_Code_Points (Run : Wide_Wide_String; Upper : Boolean) return Long_Long_Integer;

   --  Number of UTF-16 code units of Full_Map (Run, Upper): 1 for a code point
   --  up to U+FFFF, 2 above. Run holds scalar values.
   function Mapped_UTF_16_Units (Run : Wide_Wide_String; Upper : Boolean) return Long_Long_Integer;

   --  Number of UTF-8 bytes of Full_Map (Run, Upper): 1 to 4 per code point.
   --  Run holds scalar values.
   function Mapped_UTF_8_Bytes (Run : Wide_Wide_String; Upper : Boolean) return Long_Long_Integer;

   --  Full case mapping of Run, one code point at a time, with exactly
   --  Mapped_Code_Points (Run, Upper) code points in the result. A value that is
   --  not a scalar value is copied unchanged. The result may be longer than Run
   --  (U+0130 lower-cases to U+0069 U+0307, and U+00DF upper-cases to "SS").
   function Full_Map (Run : Wide_Wide_String; Upper : Boolean) return Wide_Wide_String
   with Pre => Mapped_Code_Points (Run, Upper) <= Long_Long_Integer (Natural'Last);

end Anystrings_Simple_Case;
