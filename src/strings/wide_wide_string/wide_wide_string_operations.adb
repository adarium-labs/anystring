-------------------------------------------------------------------------------
--  Wide_Wide_String_Operations - Operations for Wide_Wide_Unbounded_String
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Strings.Wide_Wide_Fixed;
with Ada.Strings;
with Ada.Strings.Unbounded;
with Ada.Strings.UTF_Encoding;
with Ada.Strings.UTF_Encoding.Wide_Wide_Strings;
with Ada.Wide_Wide_Characters.Handling;
with Anystrings_Conv;

package body Wide_Wide_String_Operations is

   --  True iff C is a valid Unicode scalar value (in U+0000..U+10FFFF and
   --  not a UTF-16 surrogate). Ada.Wide_Wide_Characters.Handling raises
   --  Constraint_Error on non-Unicode arguments, so all classifier wrappers
   --  guard against that.
   function Is_Unicode_Scalar (C : Wide_Wide_Character) return Boolean is
      P : constant Natural := Wide_Wide_Character'Pos (C);
   begin
      return P <= 16#10_FFFF# and then P not in 16#D800# .. 16#DFFF#;
   end Is_Unicode_Scalar;

   function To_Wide_Wide_String (Source : String) return Wide_Wide_String is
      Result : Wide_Wide_String (Source'Range);
   begin
      for I in Source'Range loop
         Result (I) := Wide_Wide_Character'Val (Character'Pos (Source (I)));
      end loop;
      return Result;
   end To_Wide_Wide_String;

   function To_String_From_Wide_Wide (Source : Wide_Wide_String) return String is
      Result : String (Source'Range);
   begin
      for I in Source'Range loop
         if Wide_Wide_Character'Pos (Source (I)) > 255 then
            Result (I) := '?';
         else
            Result (I) := Character'Val (Wide_Wide_Character'Pos (Source (I)));
         end if;
      end loop;
      return Result;
   end To_String_From_Wide_Wide;

   function Concat_String_Latin_1 (Left : Unbounded_Wide_Wide_String; Right : String) return Unbounded_Wide_Wide_String
   is
      use Ada.Strings.Wide_Wide_Unbounded;
   begin
      return Left & To_Wide_Wide_String (Right);
   end Concat_String_Latin_1;

   function Concat_Latin_1_String (Left : String; Right : Unbounded_Wide_Wide_String) return Unbounded_Wide_Wide_String
   is
      use Ada.Strings.Wide_Wide_Unbounded;
   begin
      return To_Wide_Wide_String (Left) & Right;
   end Concat_Latin_1_String;

   function To_Unbounded_Wide_Wide_String (Source : String) return Unbounded_Wide_Wide_String is
   begin
      return Ada.Strings.Wide_Wide_Unbounded.To_Unbounded_Wide_Wide_String (To_Wide_Wide_String (Source));
   end To_Unbounded_Wide_Wide_String;

   function To_Unbounded_Wide_Wide_String (Source : Wide_Wide_String) return Unbounded_Wide_Wide_String is
   begin
      return Ada.Strings.Wide_Wide_Unbounded.To_Unbounded_Wide_Wide_String (Source);
   end To_Unbounded_Wide_Wide_String;

   function To_String (Source : Unbounded_Wide_Wide_String) return String is
   begin
      return To_String_From_Wide_Wide (Ada.Strings.Wide_Wide_Unbounded.To_Wide_Wide_String (Source));
   end To_String;

   function Hash (Key : Unbounded_Wide_Wide_String) return Ada.Containers.Hash_Type is
      use Ada.Strings.Wide_Wide_Unbounded;
      Result : Ada.Containers.Hash_Type := 0;
      S      : constant Wide_Wide_String := To_Wide_Wide_String (Key);
   begin
      for I in S'Range loop
         Result := Ada.Containers.Hash_Type (Natural (Result) * 31 + Wide_Wide_Character'Pos (S (I)));
      end loop;
      return Result;
   end Hash;

   function Slice
     (Source : Unbounded_Wide_Wide_String; Low : Positive; High : Natural) return Unbounded_Wide_Wide_String
   is
      use Ada.Strings.Wide_Wide_Unbounded;
   begin
      return To_Unbounded_Wide_Wide_String (Slice (Source, Low, High));
   end Slice;

   function Index (Source : Unbounded_Wide_Wide_String; Pattern : Unbounded_Wide_Wide_String) return Natural is
      use Ada.Strings.Wide_Wide_Unbounded;
   begin
      return Ada.Strings.Wide_Wide_Fixed.Index (To_Wide_Wide_String (Source), To_Wide_Wide_String (Pattern));
   end Index;

   function Index_Latin_1 (Source : Unbounded_Wide_Wide_String; Pattern : String) return Natural is
   begin
      return Index (Source, To_Unbounded_Wide_Wide_String (Pattern));
   end Index_Latin_1;

   function Index_From
     (Source : Unbounded_Wide_Wide_String; Pattern : Unbounded_Wide_Wide_String; Starting_At : Positive) return Natural
   is
      use Ada.Strings.Wide_Wide_Unbounded;
      S : constant Wide_Wide_String := To_Wide_Wide_String (Source);
      P : constant Wide_Wide_String := To_Wide_Wide_String (Pattern);
   begin
      if P'Length = 0 or else Starting_At > S'Length then
         return 0;
      end if;
      return Ada.Strings.Wide_Wide_Fixed.Index (S, P, Starting_At);
   end Index_From;

   function Index_Reverse (Source : Unbounded_Wide_Wide_String; Pattern : Unbounded_Wide_Wide_String) return Natural is
      use Ada.Strings.Wide_Wide_Unbounded;
      S : constant Wide_Wide_String := To_Wide_Wide_String (Source);
      P : constant Wide_Wide_String := To_Wide_Wide_String (Pattern);
   begin
      if P'Length = 0 or else P'Length > S'Length then
         return 0;
      end if;
      return Ada.Strings.Wide_Wide_Fixed.Index (S, P, Going => Ada.Strings.Backward);
   end Index_Reverse;

   function To_Lower (Source : Unbounded_Wide_Wide_String) return Unbounded_Wide_Wide_String is
      use Ada.Strings.Wide_Wide_Unbounded;
      S      : constant Wide_Wide_String := To_Wide_Wide_String (Source);
      Result : Wide_Wide_String (S'Range);
   begin
      for I in S'Range loop
         if Wide_Wide_Character'Pos (S (I)) in 65 .. 90 then
            Result (I) := Wide_Wide_Character'Val (Wide_Wide_Character'Pos (S (I)) + 32);
         else
            Result (I) := S (I);
         end if;
      end loop;
      return To_Unbounded_Wide_Wide_String (Result);
   end To_Lower;

   function To_Upper (Source : Unbounded_Wide_Wide_String) return Unbounded_Wide_Wide_String is
      use Ada.Strings.Wide_Wide_Unbounded;
      S      : constant Wide_Wide_String := To_Wide_Wide_String (Source);
      Result : Wide_Wide_String (S'Range);
   begin
      for I in S'Range loop
         if Wide_Wide_Character'Pos (S (I)) in 97 .. 122 then
            Result (I) := Wide_Wide_Character'Val (Wide_Wide_Character'Pos (S (I)) - 32);
         else
            Result (I) := S (I);
         end if;
      end loop;
      return To_Unbounded_Wide_Wide_String (Result);
   end To_Upper;

   function Starts_With (Source : Unbounded_Wide_Wide_String; Prefix : Unbounded_Wide_Wide_String) return Boolean is
      Prefix_Len : constant Natural := Ada.Strings.Wide_Wide_Unbounded.Length (Prefix);
   begin
      if Prefix_Len = 0 then
         return True;
      elsif Prefix_Len > Ada.Strings.Wide_Wide_Unbounded.Length (Source) then
         return False;
      else
         return
           Wide_Wide_String_Operations."="
             (Ada.Strings.Wide_Wide_Unbounded.To_Unbounded_Wide_Wide_String
                (Ada.Strings.Wide_Wide_Unbounded.Slice (Source, 1, Prefix_Len)),
              Prefix);
      end if;
   end Starts_With;

   function Starts_With_Latin_1 (Source : Unbounded_Wide_Wide_String; Prefix : String) return Boolean is
   begin
      return Starts_With (Source, To_Unbounded_Wide_Wide_String (Prefix));
   end Starts_With_Latin_1;

   function Ends_With (Source : Unbounded_Wide_Wide_String; Suffix : Unbounded_Wide_Wide_String) return Boolean is
      Source_Len : constant Natural := Ada.Strings.Wide_Wide_Unbounded.Length (Source);
      Suffix_Len : constant Natural := Ada.Strings.Wide_Wide_Unbounded.Length (Suffix);
   begin
      if Suffix_Len = 0 then
         return True;
      elsif Suffix_Len > Source_Len then
         return False;
      else
         return
           Wide_Wide_String_Operations."="
             (Ada.Strings.Wide_Wide_Unbounded.To_Unbounded_Wide_Wide_String
                (Ada.Strings.Wide_Wide_Unbounded.Slice (Source, Source_Len - Suffix_Len + 1, Source_Len)),
              Suffix);
      end if;
   end Ends_With;

   function Trim (Source : Unbounded_Wide_Wide_String) return Unbounded_Wide_Wide_String is
   begin
      return Ada.Strings.Wide_Wide_Unbounded.Trim (Source, Ada.Strings.Both);
   end Trim;

   function From_Character (C : Wide_Wide_Character) return Unbounded_Wide_Wide_String is
   begin
      return Ada.Strings.Wide_Wide_Unbounded.To_Unbounded_Wide_Wide_String ([1 => C]);
   end From_Character;

   --  @relation FUNC-UTF8-003, FUNC-UTF8-005, FUNC-UTF8-006, FUNC-UTF8-007, NFR-UTF8-007
   function To_UTF_8 (Source : Unbounded_Wide_Wide_String) return String is
      WS : constant Wide_Wide_String := Ada.Strings.Wide_Wide_Unbounded.To_Wide_Wide_String (Source);

      --  U+FFFD replacement character as Wide_Wide_Character
      Replacement : constant Wide_Wide_Character := Wide_Wide_Character'Val (16#FFFD#);

      --  Build a sanitised copy with surrogates replaced by U+FFFD.
      Sanitised : Wide_Wide_String (WS'Range);
   begin
      for I in WS'Range loop
         declare
            CP : constant Natural := Wide_Wide_Character'Pos (WS (I));
         begin
            if CP in 16#D800# .. 16#DFFF# then
               Sanitised (I) := Replacement;
            else
               Sanitised (I) := WS (I);
            end if;
         end;
      end loop;

      return
        Ada.Strings.UTF_Encoding.Wide_Wide_Strings.Encode
          (Item => Sanitised, Output_Scheme => Ada.Strings.UTF_Encoding.UTF_8, Output_BOM => False);
   end To_UTF_8;

   function To_Wide_Wide_String
     (Source : Unbounded_Wide_Wide_String) return Wide_Wide_String
   is
   begin
      return Ada.Strings.Wide_Wide_Unbounded.To_Wide_Wide_String (Source);
   end To_Wide_Wide_String;

   function From_Wide_Wide_String
     (Source : Wide_Wide_String) return Unbounded_Wide_Wide_String
   is
      Sanitised   : Wide_Wide_String (Source'Range);
      Replacement : constant Wide_Wide_Character := Wide_Wide_Character'Val (16#FFFD#);
   begin
      for I in Source'Range loop
         declare
            CP : constant Natural := Wide_Wide_Character'Pos (Source (I));
         begin
            if CP in 16#D800# .. 16#DFFF# or else CP > 16#10_FFFF# then
               Sanitised (I) := Replacement;
            else
               Sanitised (I) := Source (I);
            end if;
         end;
      end loop;
      return Ada.Strings.Wide_Wide_Unbounded.To_Unbounded_Wide_Wide_String (Sanitised);
   end From_Wide_Wide_String;

   ---------------------------------------------------------------------------
   --  Character Classification & Case Mapping
   ---------------------------------------------------------------------------

   function Char_Is_Alphanumeric (C : Wide_Wide_Character) return Boolean is
   begin
      if not Is_Unicode_Scalar (C) then
         return False;
      end if;
      return Ada.Wide_Wide_Characters.Handling.Is_Alphanumeric (C);
   end Char_Is_Alphanumeric;

   function Char_Is_Control (C : Wide_Wide_Character) return Boolean is
   begin
      if not Is_Unicode_Scalar (C) then
         return False;
      end if;
      return Ada.Wide_Wide_Characters.Handling.Is_Control (C);
   end Char_Is_Control;

   function Char_Is_Digit (C : Wide_Wide_Character) return Boolean is
   begin
      if not Is_Unicode_Scalar (C) then
         return False;
      end if;
      return Ada.Wide_Wide_Characters.Handling.Is_Digit (C);
   end Char_Is_Digit;

   function Char_Is_Graphic (C : Wide_Wide_Character) return Boolean is
   begin
      if not Is_Unicode_Scalar (C) then
         return False;
      end if;
      return not Ada.Wide_Wide_Characters.Handling.Is_Control (C);
   end Char_Is_Graphic;

   function Char_Is_Hex_Digit (C : Wide_Wide_Character) return Boolean is
   begin
      if not Is_Unicode_Scalar (C) then
         return False;
      end if;
      return Ada.Wide_Wide_Characters.Handling.Is_Hexadecimal_Digit (C);
   end Char_Is_Hex_Digit;

   function Char_Is_Letter (C : Wide_Wide_Character) return Boolean is
   begin
      if not Is_Unicode_Scalar (C) then
         return False;
      end if;
      return Ada.Wide_Wide_Characters.Handling.Is_Letter (C);
   end Char_Is_Letter;

   function Char_Is_Line_Terminator (C : Wide_Wide_Character) return Boolean is
      P : constant Natural := Wide_Wide_Character'Pos (C);
   begin
      --  LF, CR, NEL, LS, PS — Unicode-backend semantics.
      return P = 16#0A# or else P = 16#0D# or else P = 16#85# or else P = 16#2028# or else P = 16#2029#;
   end Char_Is_Line_Terminator;

   function Char_Is_Lower (C : Wide_Wide_Character) return Boolean is
   begin
      if not Is_Unicode_Scalar (C) then
         return False;
      end if;
      return Ada.Wide_Wide_Characters.Handling.Is_Lower (C);
   end Char_Is_Lower;

   function Char_Is_Upper (C : Wide_Wide_Character) return Boolean is
   begin
      if not Is_Unicode_Scalar (C) then
         return False;
      end if;
      return Ada.Wide_Wide_Characters.Handling.Is_Upper (C);
   end Char_Is_Upper;

   function Char_Is_Whitespace (C : Wide_Wide_Character) return Boolean is
      P : constant Natural := Wide_Wide_Character'Pos (C);
   begin
      --  ASCII whitespace (HT/LF/VT/FF/CR/SP)…
      if P in 16#09# .. 16#0D# or else P = 16#20# then
         return True;
      end if;
      --  …plus Unicode Space_Separator on the Unicode-aware backend.
      if not Is_Unicode_Scalar (C) then
         return False;
      end if;
      return Ada.Wide_Wide_Characters.Handling.Is_Space (C);
   end Char_Is_Whitespace;

   function Char_To_Lower (C : Wide_Wide_Character) return Wide_Wide_Character is
   begin
      if not Is_Unicode_Scalar (C) then
         return C;
      end if;
      return Ada.Wide_Wide_Characters.Handling.To_Lower (C);
   end Char_To_Lower;

   function Char_To_Upper (C : Wide_Wide_Character) return Wide_Wide_Character is
   begin
      if not Is_Unicode_Scalar (C) then
         return C;
      end if;
      return Ada.Wide_Wide_Characters.Handling.To_Upper (C);
   end Char_To_Upper;

   --  @relation FUNC-CONV-008, FUNC-CONV-009
   function To_Latin_1_If_Possible (Source : Unbounded_Wide_Wide_String) return Anystrings_Conv.Latin_1_Conv_Result is
      WS      : constant Wide_Wide_String := Ada.Strings.Wide_Wide_Unbounded.To_Wide_Wide_String (Source);
      Out_Buf : Ada.Strings.Unbounded.Unbounded_String;
      Repls   : Natural := 0;
   begin
      for I in WS'Range loop
         declare
            CP : constant Natural := Wide_Wide_Character'Pos (WS (I));
         begin
            if CP <= 16#FF# then
               Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (CP));
            else
               Ada.Strings.Unbounded.Append (Out_Buf, '?');
               Repls := Repls + 1;
            end if;
         end;
      end loop;
      return
        (Status         => (if Repls = 0 then Anystrings_Conv.Ok else Anystrings_Conv.Lossy),
         Value          => Out_Buf,
         Replaced_Count => Repls);
   end To_Latin_1_If_Possible;

   function From_Wide_Wide_String_With_Substitute
     (Source     : Wide_Wide_String;
      Substitute : Wide_Wide_Character) return Unbounded_Wide_Wide_String
   is
      Sanitised : Wide_Wide_String (Source'Range);
   begin
      for I in Source'Range loop
         declare
            CP : constant Natural := Wide_Wide_Character'Pos (Source (I));
         begin
            if CP in 16#D800# .. 16#DFFF# or else CP > 16#10_FFFF# then
               Sanitised (I) := Substitute;
            else
               Sanitised (I) := Source (I);
            end if;
         end;
      end loop;
      return Ada.Strings.Wide_Wide_Unbounded.To_Unbounded_Wide_Wide_String (Sanitised);
   end From_Wide_Wide_String_With_Substitute;

   function From_Wide_Wide_String_Skip_Invalid
     (Source : Wide_Wide_String) return Unbounded_Wide_Wide_String
   is
      Out_Buf : Unbounded_Wide_Wide_String :=
        Ada.Strings.Wide_Wide_Unbounded.Null_Unbounded_Wide_Wide_String;
   begin
      for I in Source'Range loop
         declare
            CP : constant Natural := Wide_Wide_Character'Pos (Source (I));
         begin
            if not (CP in 16#D800# .. 16#DFFF# or else CP > 16#10_FFFF#) then
               Ada.Strings.Wide_Wide_Unbounded.Append (Out_Buf, Source (I));
            end if;
         end;
      end loop;
      return Out_Buf;
   end From_Wide_Wide_String_Skip_Invalid;

end Wide_Wide_String_Operations;
