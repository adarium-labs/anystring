-------------------------------------------------------------------------------
--  UXString_Operations - Operations for UXStrings.UXString
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Strings;
with Ada.Strings.Unbounded;
with Ada.Strings.UTF_Encoding;
with Ada.Strings.UTF_Encoding.Wide_Wide_Strings;
with Ada.Wide_Wide_Characters.Handling;
with Anystrings_Simple_Case;
with Anystrings_UTF_8_Replace;

package body UXString_Operations is

   --  True iff C is a valid Unicode scalar value (in U+0000..U+10FFFF and
   --  not a UTF-16 surrogate). Unicode_Character permits up to
   --  U+7FFFFFFF; guard against the non-scalar range so the underlying
   --  Wide_Wide_Characters.Handling predicates never raise.
   function Is_Unicode_Scalar (C : Unicode_Character) return Boolean is
      P : constant Natural := Wide_Wide_Character'Pos (C);
   begin
      return P <= 16#10_FFFF# and then P not in 16#D800# .. 16#DFFF#;
   end Is_Unicode_Scalar;

   --  Human decision (2026-11-17): uxstring reads the API-edge String as UTF-8,
   --  with ill-formed subparts replaced by U+FFFD (algorithm R). No Latin-1
   --  fallback, so no input raises. This differs from the Latin-1 convention
   --  that wide_* follow; see docs/text-model.md (cross-backend To_String_Type).
   function To_UXString (Source : String) return UXString is
   begin
      return From_Wide_Wide_String (Anystrings_UTF_8_Replace.Decode_Replacing (Source));
   end To_UXString;

   function To_String (Source : UXString) return String is
   begin
      return UXStrings.To_Latin_1 (Source);
   exception
      when others =>
         return String (UXStrings.To_UTF_8 (Source));
   end To_String;

   function Concat_String_Latin_1 (Left : UXString; Right : String) return UXString is
   begin
      return Left & UXStrings.From_Latin_1 (Right);
   end Concat_String_Latin_1;

   function Concat_Latin_1_String (Left : String; Right : UXString) return UXString is
   begin
      return UXStrings.From_Latin_1 (Left) & Right;
   end Concat_Latin_1_String;

   function Hash (Key : UXString) return Ada.Containers.Hash_Type is
      --  Simple hash using UTF-8 representation
      Result : Ada.Containers.Hash_Type := 0;
      UTF8   : constant UXStrings.UTF_8_Character_Array := UXStrings.To_UTF_8 (Key);
   begin
      for I in UTF8'Range loop
         Result := Ada.Containers.Hash_Type (Natural (Result) * 31 + Character'Pos (UTF8 (I)));
      end loop;
      return Result;
   end Hash;

   function Slice (Source : UXString; Low : Positive; High : Natural) return UXString is
   begin
      return UXStrings.Slice (Source, Low, High);
   end Slice;

   function Index (Source : UXString; Pattern : UXString) return Natural is
   begin
      return UXStrings.Index (Source, Pattern);
   end Index;

   function Index_Latin_1 (Source : UXString; Pattern : String) return Natural is
   begin
      return UXStrings.Index (Source, UXStrings.From_Latin_1 (Pattern));
   end Index_Latin_1;

   function Index_From (Source : UXString; Pattern : UXString; Starting_At : Positive) return Natural is
      S_Len   : constant Natural := Length (Source);
      P_Len   : constant Natural := Length (Pattern);
      Sub_Pos : Natural;
   begin
      if P_Len = 0 or else Starting_At > S_Len then
         return 0;
      end if;
      --  Slice from Starting_At to end of Source, then offset back.
      Sub_Pos := UXStrings.Index (Slice (Source, Starting_At, S_Len), Pattern);
      if Sub_Pos = 0 then
         return 0;
      else
         return Sub_Pos + Starting_At - 1;
      end if;
   end Index_From;

   function Index_Reverse (Source : UXString; Pattern : UXString) return Natural is
      S_Len : constant Natural := Length (Source);
      P_Len : constant Natural := Length (Pattern);
      Last  : Natural := 0;
      Pos   : Natural;
      Start : Positive := 1;
   begin
      if P_Len = 0 or else P_Len > S_Len then
         return 0;
      end if;
      loop
         Pos := Index_From (Source, Pattern, Start);
         exit when Pos = 0;
         Last := Pos;
         exit when Pos >= S_Len;
         Start := Pos + 1;
      end loop;
      return Last;
   end Index_Reverse;


   --  Full case mapping (Anystrings_Simple_Case.Full_Map) on the code points, rebuilt
   --  with exactly the number of code points the mapping gives.
   function Full_Lower_Length (Source : UXString) return Long_Long_Integer is
   begin
      return Anystrings_Simple_Case.Mapped_Code_Points (To_Wide_Wide_String (Source), Upper => False);
   end Full_Lower_Length;

   function Full_Upper_Length (Source : UXString) return Long_Long_Integer is
   begin
      return Anystrings_Simple_Case.Mapped_Code_Points (To_Wide_Wide_String (Source), Upper => True);
   end Full_Upper_Length;

   function To_Lower (Source : UXString) return UXString is
   begin
      return From_Wide_Wide_String (Anystrings_Simple_Case.Full_Map (To_Wide_Wide_String (Source), Upper => False));
   end To_Lower;

   function Simple_To_Lower (Source : UXString) return UXString is
      Scalars : Wide_Wide_String := To_Wide_Wide_String (Source);
   begin
      for I in Scalars'Range loop
         Scalars (I) := Anystrings_Simple_Case.Lower (Scalars (I));
      end loop;
      return From_Wide_Wide_String (Scalars);
   end Simple_To_Lower;

   function To_Upper (Source : UXString) return UXString is
   begin
      return From_Wide_Wide_String (Anystrings_Simple_Case.Full_Map (To_Wide_Wide_String (Source), Upper => True));
   end To_Upper;

   function Starts_With (Source : UXString; Prefix : UXString) return Boolean is
      Prefix_Len : constant Natural := Length (Prefix);
   begin
      if Prefix_Len = 0 then
         return True;
      elsif Prefix_Len > Length (Source) then
         return False;
      else
         return Slice (Source, 1, Prefix_Len) = Prefix;
      end if;
   end Starts_With;

   function Starts_With_Latin_1 (Source : UXString; Prefix : String) return Boolean is
   begin
      return UXString_Operations.Starts_With (Source, UXStrings.From_Latin_1 (Prefix));
   end Starts_With_Latin_1;

   function Ends_With (Source : UXString; Suffix : UXString) return Boolean is
      Source_Len : constant Natural := Length (Source);
      Suffix_Len : constant Natural := Length (Suffix);
   begin
      if Suffix_Len = 0 then
         return True;
      elsif Suffix_Len > Source_Len then
         return False;
      else
         return Slice (Source, Source_Len - Suffix_Len + 1, Source_Len) = Suffix;
      end if;
   end Ends_With;

   function Trim (Source : UXString) return UXString is
   begin
      return UXStrings.Trim (Source, Ada.Strings.Both);
   end Trim;

   function From_Character (C : Unicode_Character) return UXString is
   begin
      return UXStrings.From_Unicode (C);
   end From_Character;

   --  UTF-8 of the stored code points. UXS5 stores whatever it is given, so a
   --  surrogate or a value above U+10FFFF can be stored; each one becomes
   --  U+FFFD here (policy P) before the encoder, which would otherwise raise.
   function Sanitised_UTF_8 (Source : UXString) return String is
      Cps : Wide_Wide_String := UXStrings.To_Unicode (Source);
   begin
      for C of Cps loop
         if not Is_Unicode_Scalar (C) then
            C := Wide_Wide_Character'Val (16#FFFD#);
         end if;
      end loop;
      return
        Ada.Strings.UTF_Encoding.Wide_Wide_Strings.Encode
          (Item => Cps, Output_Scheme => Ada.Strings.UTF_Encoding.UTF_8, Output_BOM => False);
   end Sanitised_UTF_8;

   --  @relation FUNC-UTF8-003, FUNC-UTF8-005, FUNC-UTF8-006, NFR-UTF8-007
   function To_UTF_8 (Source : UXString) return String is
      use Ada.Strings.Unbounded;

      --  Replacement character U+FFFD (3 bytes: EF BF BD)
      FFFD : constant String := Character'Val (16#EF#) & Character'Val (16#BF#) & Character'Val (16#BD#);

      --  Encode a single Latin-1 code point (0..255) as UTF-8.
      function Encode_Latin_1 (B : Natural) return String is
      begin
         if B <= 16#7F# then
            return [1 => Character'Val (B)];
         else
            --  U+0080..U+00FF: 2-byte UTF-8 sequence.
            --  High byte = 0xC0 + B/64; Low byte = 0x80 + B mod 64.
            --  For B in 128..255: B/64 in 2..3, so high byte in 0xC2..0xC3.
            return [Character'Val (16#C0# + (B / 64)), Character'Val (16#80# + (B mod 64))];
         end if;
      end Encode_Latin_1;

      function Is_Cont (C : Character) return Boolean is
         B : constant Natural := Character'Pos (C);
      begin
         return B in 16#80# .. 16#BF#;
      end Is_Cont;

      --  UXStrings.To_UTF_8 encodes the stored code points (UXS5 stores an
      --  array of code points, not UTF-8 bytes); the walk below re-checks the
      --  encoding byte by byte and is the identity on well-formed UTF-8.
      Raw    : constant String := Sanitised_UTF_8 (Source);
      Result : Unbounded_String;
      I      : Positive;
      Step   : Positive;   --  bytes consumed at I
      Lead   : Natural;
      CP     : Natural;
      --  Bytes after I. I <= Raw'Last, so this is never negative, and every
      --  position I + K with K <= Room is inside Raw. The tests below read
      --  "Room >= K", never "I + K <= Raw'Last", which overflows when Raw'Last
      --  is Positive'Last.
      Room   : Natural;
   begin
      if Raw'Length = 0 then
         return "";
      end if;

      I := Raw'First;
      loop
         Lead := Character'Pos (Raw (I));
         Room := Raw'Last - I;

         if Lead <= 16#7F# then
            --  ASCII single byte — always valid UTF-8, pass through.
            Append (Result, Raw (I));
            Step := 1;

         elsif Lead in 16#C2# .. 16#DF# then
            --  2-byte sequence: valid if followed by one continuation byte.
            if Room >= 1 and then Is_Cont (Raw (I + 1)) then
               Append (Result, Raw (I .. I + 1));
               Step := 2;
            else
               --  Truncated or invalid: treat lead as Latin-1 code point.
               Append (Result, Encode_Latin_1 (Lead));
               Step := 1;
            end if;

         elsif Lead in 16#E0# .. 16#EF# then
            --  3-byte sequence: valid if followed by two continuation bytes.
            if Room >= 2 and then Is_Cont (Raw (I + 1)) and then Is_Cont (Raw (I + 2)) then
               CP :=
                 (Lead mod 16)
                 * 4_096
                 + (Character'Pos (Raw (I + 1)) mod 64) * 64
                 + (Character'Pos (Raw (I + 2)) mod 64);
               if CP in 16#D800# .. 16#DFFF# then
                  --  Surrogate code point — replace with U+FFFD.
                  Append (Result, FFFD);
               else
                  Append (Result, Raw (I .. I + 2));
               end if;
               Step := 3;
            else
               --  Truncated: treat lead as Latin-1 code point.
               Append (Result, Encode_Latin_1 (Lead));
               Step := 1;
            end if;

         elsif Lead in 16#F0# .. 16#F4# then
            --  4-byte sequence: valid if followed by three continuation bytes.
            if Room >= 3
              and then Is_Cont (Raw (I + 1))
              and then Is_Cont (Raw (I + 2))
              and then Is_Cont (Raw (I + 3))
            then
               CP :=
                 (Lead mod 8)
                 * 262_144
                 + (Character'Pos (Raw (I + 1)) mod 64) * 4_096
                 + (Character'Pos (Raw (I + 2)) mod 64) * 64
                 + (Character'Pos (Raw (I + 3)) mod 64);
               if CP > 16#10_FFFF# then
                  Append (Result, FFFD);
               else
                  Append (Result, Raw (I .. I + 3));
               end if;
               Step := 4;
            else
               Append (Result, Encode_Latin_1 (Lead));
               Step := 1;
            end if;

         else
            --  0x80..0xBF (bare continuation), 0xC0..0xC1 (always overlong),
            --  0xF5..0xFF (out-of-range lead): treat as Latin-1 code point.
            Append (Result, Encode_Latin_1 (Lead));
            Step := 1;
         end if;

         --  The step that consumed the rest of Raw ends the loop; otherwise
         --  I + Step is at most Raw'Last.
         exit when Step > Room;
         I := I + Step;
      end loop;

      return To_String (Result);
   end To_UTF_8;

   --  Code points in one step: UXS5 stores the array of code points, so this
   --  is a single copy (linear), not one Element call per index.
   function To_Wide_Wide_String (Source : UXString) return Wide_Wide_String is
   begin
      return UXStrings.To_Unicode (Source);
   end To_Wide_Wide_String;

   --  Build a UXString in one pass: each invalid code point (surrogate or above
   --  U+10FFFF) becomes Substitute, or is dropped when Drop is set. The result is
   --  built with a single UXStrings.From_Unicode, so no code point is stripped
   --  (a leading U+FEFF is kept).
   function Build_Policy
     (Source : Wide_Wide_String; Substitute : Natural; Drop : Boolean) return UXString
   is
      Clean : Wide_Wide_String (1 .. Source'Length);
      Count : Natural := 0;
   begin
      for C of Source loop
         if Is_Unicode_Scalar (C) then
            Count := Count + 1;
            Clean (Count) := C;
         elsif not Drop then
            Count := Count + 1;
            Clean (Count) := Wide_Wide_Character'Val (Substitute);
         end if;
      end loop;
      return UXStrings.From_Unicode (Clean (1 .. Count));
   end Build_Policy;

   function From_Wide_Wide_String (Source : Wide_Wide_String) return UXString is
   begin
      return Build_Policy (Source, 16#FFFD#, Drop => False);
   end From_Wide_Wide_String;

   function From_Wide_Wide_String_With_Substitute
     (Source     : Wide_Wide_String;
      Substitute : Wide_Wide_Character) return UXString
   is
   begin
      return Build_Policy (Source, Wide_Wide_Character'Pos (Substitute), Drop => False);
   end From_Wide_Wide_String_With_Substitute;

   function From_Wide_Wide_String_Skip_Invalid
     (Source : Wide_Wide_String) return UXString
   is
   begin
      return Build_Policy (Source, 16#FFFD#, Drop => True);
   end From_Wide_Wide_String_Skip_Invalid;


   ---------------------------------------------------------------------------
   --  Character Classification & Case Mapping
   ---------------------------------------------------------------------------

   function Char_Is_Alphanumeric (C : Unicode_Character) return Boolean is
   begin
      if not Is_Unicode_Scalar (C) then
         return False;
      end if;
      return Ada.Wide_Wide_Characters.Handling.Is_Alphanumeric (C);
   end Char_Is_Alphanumeric;

   function Char_Is_Control (C : Unicode_Character) return Boolean is
   begin
      if not Is_Unicode_Scalar (C) then
         return False;
      end if;
      return Ada.Wide_Wide_Characters.Handling.Is_Control (C);
   end Char_Is_Control;

   function Char_Is_Digit (C : Unicode_Character) return Boolean is
   begin
      if not Is_Unicode_Scalar (C) then
         return False;
      end if;
      return Ada.Wide_Wide_Characters.Handling.Is_Digit (C);
   end Char_Is_Digit;

   function Char_Is_Graphic (C : Unicode_Character) return Boolean is
   begin
      if not Is_Unicode_Scalar (C) then
         return False;
      end if;
      return not Ada.Wide_Wide_Characters.Handling.Is_Control (C);
   end Char_Is_Graphic;

   function Char_Is_Hex_Digit (C : Unicode_Character) return Boolean is
   begin
      if not Is_Unicode_Scalar (C) then
         return False;
      end if;
      return Ada.Wide_Wide_Characters.Handling.Is_Hexadecimal_Digit (C);
   end Char_Is_Hex_Digit;

   function Char_Is_Letter (C : Unicode_Character) return Boolean is
   begin
      if not Is_Unicode_Scalar (C) then
         return False;
      end if;
      return Ada.Wide_Wide_Characters.Handling.Is_Letter (C);
   end Char_Is_Letter;

   function Char_Is_Line_Terminator (C : Unicode_Character) return Boolean is
      P : constant Natural := Wide_Wide_Character'Pos (C);
   begin
      return P = 16#0A# or else P = 16#0D# or else P = 16#85# or else P = 16#2028# or else P = 16#2029#;
   end Char_Is_Line_Terminator;

   function Char_Is_Lower (C : Unicode_Character) return Boolean is
   begin
      if not Is_Unicode_Scalar (C) then
         return False;
      end if;
      return Ada.Wide_Wide_Characters.Handling.Is_Lower (C);
   end Char_Is_Lower;

   function Char_Is_Upper (C : Unicode_Character) return Boolean is
   begin
      if not Is_Unicode_Scalar (C) then
         return False;
      end if;
      return Ada.Wide_Wide_Characters.Handling.Is_Upper (C);
   end Char_Is_Upper;

   function Char_Is_Whitespace (C : Unicode_Character) return Boolean is
      P : constant Natural := Wide_Wide_Character'Pos (C);
   begin
      if P in 16#09# .. 16#0D# or else P = 16#20# then
         return True;
      end if;
      if not Is_Unicode_Scalar (C) then
         return False;
      end if;
      return Ada.Wide_Wide_Characters.Handling.Is_Space (C);
   end Char_Is_Whitespace;

   function Char_To_Lower (C : Unicode_Character) return Unicode_Character is
   begin
      if not Is_Unicode_Scalar (C) then
         return C;
      end if;
      return Ada.Wide_Wide_Characters.Handling.To_Lower (C);
   end Char_To_Lower;

   function Char_To_Upper (C : Unicode_Character) return Unicode_Character is
   begin
      if not Is_Unicode_Scalar (C) then
         return C;
      end if;
      return Ada.Wide_Wide_Characters.Handling.To_Upper (C);
   end Char_To_Upper;

end UXString_Operations;
