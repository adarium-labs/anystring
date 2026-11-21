-------------------------------------------------------------------------------
--  Standard_String_Operations - Operations for Unbounded_String
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Strings;
with Ada.Strings.Fixed;
--  Ada.Strings.Unbounded.Aux exposes the buffer of an Unbounded_String without
--  a copy, which Code_Point_Length needs to stay allocation-free. It is a GNAT
--  internal unit; the warning it raises is accepted here and nowhere else.
pragma Warnings (Off, "internal GNAT unit");
pragma Warnings (Off, "non-portable");
with Ada.Strings.Unbounded.Aux;
pragma Warnings (On, "non-portable");
pragma Warnings (On, "internal GNAT unit");
with Anystrings_UTF_8_Case;
with Anystrings_UTF_8_Replace;

package body Standard_String_Operations is

   function Index (Source : Unbounded_String; Pattern : Unbounded_String) return Natural is
      S : constant String := To_String (Source);
      P : constant String := To_String (Pattern);
   begin
      return Ada.Strings.Fixed.Index (S, P);
   end Index;

   function Index_Latin_1 (Source : Unbounded_String; Pattern : String) return Natural is
      S : constant String := To_String (Source);
   begin
      return Ada.Strings.Fixed.Index (S, Pattern);
   end Index_Latin_1;

   function Index_From (Source : Unbounded_String; Pattern : Unbounded_String; Starting_At : Positive) return Natural is
      S : constant String := To_String (Source);
      P : constant String := To_String (Pattern);
   begin
      if P'Length = 0 or else Starting_At > S'Length then
         return 0;
      end if;
      return Ada.Strings.Fixed.Index (S, P, Starting_At);
   end Index_From;

   function Index_Reverse (Source : Unbounded_String; Pattern : Unbounded_String) return Natural is
      S : constant String := To_String (Source);
      P : constant String := To_String (Pattern);
   begin
      if P'Length = 0 or else P'Length > S'Length then
         return 0;
      end if;
      return Ada.Strings.Fixed.Index (S, P, Going => Ada.Strings.Backward);
   end Index_Reverse;

   --  Case mappings. All the walking, sizing and index arithmetic is in
   --  Anystrings_UTF_8_Case (SPARK_Mode On, proved free of run-time errors);
   --  the bodies here only convert between Unbounded_String and String.

   function Simple_To_Lower (Source : Unbounded_String) return Unbounded_String is
   begin
      return To_Unbounded_String (Anystrings_UTF_8_Case.Simple_Lower (To_String (Source)));
   end Simple_To_Lower;

   function Full_Lower_Length (Source : Unbounded_String) return Long_Long_Integer is
   begin
      return Anystrings_UTF_8_Case.Case_Length (To_String (Source), Upper => False);
   end Full_Lower_Length;

   function Full_Upper_Length (Source : Unbounded_String) return Long_Long_Integer is
   begin
      return Anystrings_UTF_8_Case.Case_Length (To_String (Source), Upper => True);
   end Full_Upper_Length;

   function To_Lower (Source : Unbounded_String) return Unbounded_String is
   begin
      return To_Unbounded_String (Anystrings_UTF_8_Case.Case_Map (To_String (Source), Upper => False));
   end To_Lower;

   function To_Upper (Source : Unbounded_String) return Unbounded_String is
   begin
      return To_Unbounded_String (Anystrings_UTF_8_Case.Case_Map (To_String (Source), Upper => True));
   end To_Upper;

   function Starts_With (Source : Unbounded_String; Prefix : Unbounded_String) return Boolean is
      S          : constant String := To_String (Source);
      P          : constant String := To_String (Prefix);
      Prefix_Len : constant Natural := P'Length;
   begin
      if Prefix_Len = 0 then
         return True;
      elsif Prefix_Len > S'Length then
         return False;
      else
         return S (S'First .. S'First + Prefix_Len - 1) = P;
      end if;
   end Starts_With;

   function Starts_With_Latin_1 (Source : Unbounded_String; Prefix : String) return Boolean is
      S          : constant String := To_String (Source);
      Prefix_Len : constant Natural := Prefix'Length;
   begin
      if Prefix_Len = 0 then
         return True;
      elsif Prefix_Len > S'Length then
         return False;
      else
         return S (S'First .. S'First + Prefix_Len - 1) = Prefix;
      end if;
   end Starts_With_Latin_1;

   function Ends_With (Source : Unbounded_String; Suffix : Unbounded_String) return Boolean is
      S          : constant String := To_String (Source);
      Suf        : constant String := To_String (Suffix);
      Suffix_Len : constant Natural := Suf'Length;
   begin
      if Suffix_Len = 0 then
         return True;
      elsif Suffix_Len > S'Length then
         return False;
      else
         return S (S'Last - Suffix_Len + 1 .. S'Last) = Suf;
      end if;
   end Ends_With;

   function Trim (Source : Unbounded_String) return Unbounded_String is
   begin
      return Ada.Strings.Unbounded.Trim (Source, Ada.Strings.Both);
   end Trim;

   function From_Character (C : Character) return Unbounded_String is
   begin
      return To_Unbounded_String ([1 => C]);
   end From_Character;

   --  @relation FUNC-UTF8-003, FUNC-UTF8-005, FUNC-UTF8-006,
   --            FUNC-CONV-001, FUNC-CONV-003, FUNC-CONV-011,
   --            NFR-UTF8-007, NFR-UTF8-010
   function To_UTF_8 (Source : Unbounded_String) return String is
   begin
      --  Per FUNC-CONV-001 storage is UTF-8; emission is byte-identity.
      --  Prior implementation called Ada.Strings.UTF_Encoding.Strings.Encode
      --  which double-encoded UTF-8 input by treating each stored byte as
      --  a Latin-1 code point (the bug fixed by this work-plan).
      return To_String (Source);
   end To_UTF_8;

   --  @relation FUNC-CONV-006, FUNC-CONV-007
   --  Decodes with algorithm R (Anystrings_UTF_8_Replace), the model of
   --  docs/text-model.md section 9.5: one U+FFFD per maximal ill-formed subpart,
   --  so an encoded surrogate (ED A0 80) is three U+FFFD, one per byte. A code
   --  point above U+00FF is written as '?'.
   function To_Latin_1 (Source : Unbounded_String) return String is
      Scalars : constant Wide_Wide_String := Anystrings_UTF_8_Replace.Decode_Replacing (To_String (Source));
      Out_Buf : String (1 .. Scalars'Length);
   begin
      for I in Scalars'Range loop
         if Wide_Wide_Character'Pos (Scalars (I)) <= 16#FF# then
            Out_Buf (I - Scalars'First + 1) := Character'Val (Wide_Wide_Character'Pos (Scalars (I)));
         else
            Out_Buf (I - Scalars'First + 1) := '?';
         end if;
      end loop;
      return Out_Buf;
   end To_Latin_1;

   --  @relation FUNC-CONV-008, FUNC-CONV-009
   function To_Latin_1_If_Possible (Source : Unbounded_String) return Anystrings_Conv.Latin_1_Conv_Result is
      Scalars : constant Wide_Wide_String := Anystrings_UTF_8_Replace.Decode_Replacing (To_String (Source));
      Out_Buf : Ada.Strings.Unbounded.Unbounded_String;
      Repls   : Natural := 0;
   begin
      for I in Scalars'Range loop
         if Wide_Wide_Character'Pos (Scalars (I)) <= 16#FF# then
            Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (Wide_Wide_Character'Pos (Scalars (I))));
         else
            Ada.Strings.Unbounded.Append (Out_Buf, '?');
            Repls := Repls + 1;
         end if;
      end loop;
      return
        (Status         => (if Repls = 0 then Anystrings_Conv.Ok else Anystrings_Conv.Lossy),
         Value          => Out_Buf,
         Replaced_Count => Repls);
   end To_Latin_1_If_Possible;

   function To_Wide_Wide_String (Source : Unbounded_String) return Wide_Wide_String is
   begin
      return Anystrings_UTF_8_Replace.Decode_Replacing (To_String (Source));
   end To_Wide_Wide_String;

   function Code_Point_Length (Source : Unbounded_String) return Natural is
      Buf : Ada.Strings.Unbounded.Aux.Big_String_Access;
      Len : Natural;
   begin
      Ada.Strings.Unbounded.Aux.Get_String (Source, Buf, Len);
      if Len = 0 then
         return 0;
      end if;
      return Anystrings_UTF_8_Replace.Code_Point_Count (Buf (1 .. Len));
   end Code_Point_Length;

   function From_Wide_Wide_String (Source : Wide_Wide_String) return Unbounded_String is
      Out_Buf : Ada.Strings.Unbounded.Unbounded_String;

      --  Substitute for surrogate / out-of-range code-points (policy P): the
      --  same U+FFFD as every other backend. It is stored as its UTF-8 encoding,
      --  EF BF BD (three bytes), so one code point in gives three bytes out.
      Default_Substitute : constant Natural := 16#FFFD#;

      procedure Encode_Code_Point (CP : Natural) is
      begin
         if CP <= 16#7F# then
            Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (CP));
         elsif CP <= 16#7FF# then
            Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (16#C0# + CP / 64));
            Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (16#80# + CP mod 64));
         elsif CP <= 16#FFFF# then
            Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (16#E0# + CP / 4_096));
            Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (16#80# + (CP / 64) mod 64));
            Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (16#80# + CP mod 64));
         else
            Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (16#F0# + CP / 262_144));
            Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (16#80# + (CP / 4_096) mod 64));
            Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (16#80# + (CP / 64) mod 64));
            Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (16#80# + CP mod 64));
         end if;
      end Encode_Code_Point;
   begin
      for I in Source'Range loop
         declare
            CP : constant Natural := Wide_Wide_Character'Pos (Source (I));
         begin
            if CP in 16#D800# .. 16#DFFF# or else CP > 16#10_FFFF# then
               Encode_Code_Point (Default_Substitute);
            else
               Encode_Code_Point (CP);
            end if;
         end;
      end loop;
      return Out_Buf;
   end From_Wide_Wide_String;

   function Char_Is_Line_Terminator (C : Character) return Boolean is
      P : constant Natural := Character'Pos (C);
   begin
      --  LF (0x0A) and CR (0x0D). Latin-1 cannot represent LS/PS/NEL above.
      return P = 16#0A# or else P = 16#0D#;
   end Char_Is_Line_Terminator;

   function Char_Is_Whitespace (C : Character) return Boolean is
      P : constant Natural := Character'Pos (C);
   begin
      --  HT (0x09), LF (0x0A), VT (0x0B), FF (0x0C), CR (0x0D), SP (0x20).
      return P in 16#09# .. 16#0D# or else P = 16#20#;
   end Char_Is_Whitespace;

   --  ASCII only (see the spec): a byte >= 16#80# is neither lower nor upper.
   function Char_Is_Lower (C : Character) return Boolean is
      P : constant Natural := Character'Pos (C);
   begin
      return P in 16#61# .. 16#7A#;
   end Char_Is_Lower;

   function Char_Is_Upper (C : Character) return Boolean is
      P : constant Natural := Character'Pos (C);
   begin
      return P in 16#41# .. 16#5A#;
   end Char_Is_Upper;

   --  ASCII only (see the spec): bytes >= 16#80# are returned unchanged.
   function Char_To_Lower (C : Character) return Character is
      P : constant Natural := Character'Pos (C);
   begin
      if P in 16#41# .. 16#5A# then
         return Character'Val (P + 16#20#);
      end if;
      return C;
   end Char_To_Lower;

   function Char_To_Upper (C : Character) return Character is
      P : constant Natural := Character'Pos (C);
   begin
      if P in 16#61# .. 16#7A# then
         return Character'Val (P - 16#20#);
      end if;
      return C;
   end Char_To_Upper;

   --  Encode a Unicode scalar code-point as 1..4 UTF-8 bytes appended to
   --  Out_Buf. Local helper factored out to keep the three Tier-2
   --  From_Wide_Wide_String_* variants DRY. Caller is responsible for
   --  ensuring CP is a valid Unicode scalar (0 .. 0x10FFFF, not a
   --  surrogate); the three variants check this before every call.
   procedure Encode_UTF_8_Code_Point
     (CP      : Natural;
      Out_Buf : in out Ada.Strings.Unbounded.Unbounded_String);

   procedure Encode_UTF_8_Code_Point
     (CP      : Natural;
      Out_Buf : in out Ada.Strings.Unbounded.Unbounded_String)
   is
   begin
      if CP <= 16#7F# then
         Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (CP));
      elsif CP <= 16#7FF# then
         Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (16#C0# + CP / 64));
         Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (16#80# + CP mod 64));
      elsif CP <= 16#FFFF# then
         Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (16#E0# + CP / 4_096));
         Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (16#80# + (CP / 64) mod 64));
         Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (16#80# + CP mod 64));
      else
         Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (16#F0# + CP / 262_144));
         Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (16#80# + (CP / 4_096) mod 64));
         Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (16#80# + (CP / 64) mod 64));
         Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (16#80# + CP mod 64));
      end if;
   end Encode_UTF_8_Code_Point;

   function From_Wide_Wide_String_With_Substitute
     (Source     : Wide_Wide_String;
      Substitute : Wide_Wide_Character) return Unbounded_String
   is
      Out_Buf : Ada.Strings.Unbounded.Unbounded_String;
      Sub_CP  : constant Natural := Wide_Wide_Character'Pos (Substitute);
   begin
      for I in Source'Range loop
         declare
            CP : constant Natural := Wide_Wide_Character'Pos (Source (I));
         begin
            if CP in 16#D800# .. 16#DFFF# or else CP > 16#10_FFFF# then
               Encode_UTF_8_Code_Point (Sub_CP, Out_Buf);
            else
               Encode_UTF_8_Code_Point (CP, Out_Buf);
            end if;
         end;
      end loop;
      return Out_Buf;
   end From_Wide_Wide_String_With_Substitute;

   function From_Wide_Wide_String_Skip_Invalid
     (Source : Wide_Wide_String) return Unbounded_String
   is
      Out_Buf : Ada.Strings.Unbounded.Unbounded_String;
   begin
      for I in Source'Range loop
         declare
            CP : constant Natural := Wide_Wide_Character'Pos (Source (I));
         begin
            if not (CP in 16#D800# .. 16#DFFF# or else CP > 16#10_FFFF#) then
               Encode_UTF_8_Code_Point (CP, Out_Buf);
            end if;
         end;
      end loop;
      return Out_Buf;
   end From_Wide_Wide_String_Skip_Invalid;

end Standard_String_Operations;
