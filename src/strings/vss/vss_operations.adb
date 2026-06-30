-------------------------------------------------------------------------------
--  VSS_Operations - Operations for VSS.Strings.Virtual_String
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Strings.Wide_Wide_Fixed;
with Ada.Wide_Wide_Characters.Handling;
with VSS.Characters;
with VSS.Strings.Conversions;
with VSS.Transformers.Casing;

package body VSS_Operations is

   --  True iff C is a valid Unicode scalar value (U+0000..U+10FFFF and
   --  not a surrogate). Ada.Wide_Wide_Characters.Handling raises
   --  Constraint_Error on non-Unicode arguments, so all classifier
   --  wrappers guard against that.
   function Is_Unicode_Scalar (C : Wide_Wide_Character) return Boolean is
      P : constant Natural := Wide_Wide_Character'Pos (C);
   begin
      return P <= 16#10_FFFF# and then P not in 16#D800# .. 16#DFFF#;
   end Is_Unicode_Scalar;

   --  Replacement character used by To_String for code points outside
   --  Latin-1 range.
   Latin_1_Substitute : constant Character := '?';

   --  U+FFFD REPLACEMENT CHARACTER, used when an input Wide_Wide_Character
   --  is not a valid Unicode scalar value (surrogate or > U+10FFFF).
   FFFD_Code_Point : constant := 16#FFFD#;

   ---------------------------------------------------------------------------
   --  Internal helpers
   ---------------------------------------------------------------------------

   --  Coerce an arbitrary Wide_Wide_Character into a valid
   --  VSS.Characters.Virtual_Character. Surrogates (U+D800..U+DFFF) and
   --  values above U+10FFFF are replaced with U+FFFD so that 'Val never
   --  trips the Virtual_Character Static_Predicate.
   function To_Valid_Virtual_Character (C : Wide_Wide_Character) return VSS.Characters.Virtual_Character is
      CP : constant Natural := Wide_Wide_Character'Pos (C);
   begin
      if CP > 16#10_FFFF# or else CP in 16#D800# .. 16#DFFF# then
         return VSS.Characters.Virtual_Character'Val (FFFD_Code_Point);
      else
         return VSS.Characters.Virtual_Character'Val (CP);
      end if;
   end To_Valid_Virtual_Character;

   --  Convert Latin-1 String to Wide_Wide_String (each byte -> code point).
   function Latin_1_To_WWS (Source : String) return Wide_Wide_String is
      Result : Wide_Wide_String (Source'Range);
   begin
      for I in Source'Range loop
         Result (I) := Wide_Wide_Character'Val (Character'Pos (Source (I)));
      end loop;
      return Result;
   end Latin_1_To_WWS;

   --  Convert Wide_Wide_String to Latin-1 String, substituting '?' for
   --  code points > U+00FF.
   function WWS_To_Latin_1 (Source : Wide_Wide_String) return String is
      Result : String (Source'Range);
   begin
      for I in Source'Range loop
         if Wide_Wide_Character'Pos (Source (I)) > 255 then
            Result (I) := Latin_1_Substitute;
         else
            Result (I) := Character'Val (Wide_Wide_Character'Pos (Source (I)));
         end if;
      end loop;
      return Result;
   end WWS_To_Latin_1;

   ---------------------------------------------------------------------------
   --  Core Operations
   ---------------------------------------------------------------------------

   function Length (Source : Virtual_String) return Natural is
   begin
      return Natural (VSS.Strings.Character_Length (Source));
   end Length;

   function Is_Empty (Source : Virtual_String) return Boolean is
   begin
      return VSS.Strings.Is_Empty (Source);
   end Is_Empty;

   function Element (Source : Virtual_String; Index : Positive) return Wide_Wide_Character is
      WS : constant Wide_Wide_String := VSS.Strings.Conversions.To_Wide_Wide_String (Source);
   begin
      return WS (WS'First + Index - 1);
   end Element;

   function Concat_Strings (Left : Virtual_String; Right : Virtual_String) return Virtual_String is
   begin
      return VSS.Strings."&" (Left, Right);
   end Concat_Strings;

   function Concat_String_Character (Left : Virtual_String; Right : Wide_Wide_Character) return Virtual_String is
   begin
      return VSS.Strings."&" (Left, To_Valid_Virtual_Character (Right));
   end Concat_String_Character;

   function Concat_Character_String (Left : Wide_Wide_Character; Right : Virtual_String) return Virtual_String is
   begin
      return VSS.Strings."&" (To_Valid_Virtual_Character (Left), Right);
   end Concat_Character_String;

   function Concat_String_Latin_1 (Left : Virtual_String; Right : String) return Virtual_String is
   begin
      return VSS.Strings."&" (Left, To_Virtual_String (Right));
   end Concat_String_Latin_1;

   function Concat_Latin_1_String (Left : String; Right : Virtual_String) return Virtual_String is
   begin
      return VSS.Strings."&" (To_Virtual_String (Left), Right);
   end Concat_Latin_1_String;

   ---------------------------------------------------------------------------
   --  Comparison Operations
   ---------------------------------------------------------------------------

   function "=" (Left, Right : Virtual_String) return Boolean is
   begin
      return VSS.Strings."=" (Left, Right);
   end "=";

   function "<" (Left, Right : Virtual_String) return Boolean is
   begin
      return VSS.Strings."<" (Left, Right);
   end "<";

   function "<=" (Left, Right : Virtual_String) return Boolean is
   begin
      return VSS.Strings."<=" (Left, Right);
   end "<=";

   function ">" (Left, Right : Virtual_String) return Boolean is
   begin
      return VSS.Strings.">" (Left, Right);
   end ">";

   function ">=" (Left, Right : Virtual_String) return Boolean is
   begin
      return VSS.Strings.">=" (Left, Right);
   end ">=";

   ---------------------------------------------------------------------------
   --  Conversion Operations
   ---------------------------------------------------------------------------

   function To_Virtual_String (Source : String) return Virtual_String is
   begin
      return VSS.Strings.To_Virtual_String (Latin_1_To_WWS (Source));
   end To_Virtual_String;

   function To_String (Source : Virtual_String) return String is
   begin
      return WWS_To_Latin_1 (VSS.Strings.Conversions.To_Wide_Wide_String (Source));
   end To_String;

   ---------------------------------------------------------------------------
   --  Environment Operations
   ---------------------------------------------------------------------------

   --  Encode a Virtual_String as a UTF-8 String for use as an OS env name
   --  or value.
   function To_UTF_8_String (Source : Virtual_String) return String is
   begin
      return VSS.Strings.Conversions.To_UTF_8_String (Source);
   end To_UTF_8_String;

   --  Decode an OS env name/value (assumed UTF-8) into a Virtual_String.
   --  Returns Null_Virtual_String if the input is not valid UTF-8.
   function From_UTF_8_String (Source : String) return Virtual_String is
   begin
      return VSS.Strings.Conversions.To_Virtual_String (Source);
   exception
      when others =>
         return Null_Virtual_String;
   end From_UTF_8_String;

   ---------------------------------------------------------------------------
   --  Text I/O Operations
   ---------------------------------------------------------------------------

   ---------------------------------------------------------------------------
   --  Extended Operations
   ---------------------------------------------------------------------------

   function Hash (Key : Virtual_String) return Ada.Containers.Hash_Type is
      Full : constant VSS.Strings.Hash_Type := VSS.Strings.Hash (Key);
   begin
      --  VSS.Strings.Hash_Type is mod 2**64. Truncate to Ada.Containers.Hash_Type
      --  (typically mod 2**32) via the universal 'Mod attribute.
      return Ada.Containers.Hash_Type'Mod (Full);
   end Hash;

   function Slice (Source : Virtual_String; Low : Positive; High : Natural) return Virtual_String is
      WS  : constant Wide_Wide_String := VSS.Strings.Conversions.To_Wide_Wide_String (Source);
      Len : constant Natural := WS'Length;
   begin
      if Low > Len or else Low > High then
         return Null_Virtual_String;
      end if;

      declare
         Hi : constant Natural := Natural'Min (High, Len);
      begin
         return VSS.Strings.To_Virtual_String (WS (WS'First + Low - 1 .. WS'First + Hi - 1));
      end;
   end Slice;

   function Index (Source : Virtual_String; Pattern : Virtual_String) return Natural is
      WS_Src : constant Wide_Wide_String := VSS.Strings.Conversions.To_Wide_Wide_String (Source);
      WS_Pat : constant Wide_Wide_String := VSS.Strings.Conversions.To_Wide_Wide_String (Pattern);
      Pos    : constant Natural := Ada.Strings.Wide_Wide_Fixed.Index (WS_Src, WS_Pat);
   begin
      if Pos = 0 then
         return 0;
      else
         --  Translate to 1-based index relative to start of Source.
         return Pos - WS_Src'First + 1;
      end if;
   end Index;

   function Index_Latin_1 (Source : Virtual_String; Pattern : String) return Natural is
   begin
      return Index (Source, To_Virtual_String (Pattern));
   end Index_Latin_1;

   function Index_From (Source : Virtual_String; Pattern : Virtual_String; Starting_At : Positive) return Natural is
      WS_Src : constant Wide_Wide_String := VSS.Strings.Conversions.To_Wide_Wide_String (Source);
      WS_Pat : constant Wide_Wide_String := VSS.Strings.Conversions.To_Wide_Wide_String (Pattern);
   begin
      if WS_Pat'Length = 0 or else Starting_At > WS_Src'Length then
         return 0;
      end if;
      declare
         From_Abs : constant Positive := WS_Src'First + Starting_At - 1;
         Pos      : constant Natural := Ada.Strings.Wide_Wide_Fixed.Index (WS_Src, WS_Pat, From_Abs);
      begin
         if Pos = 0 then
            return 0;
         else
            return Pos - WS_Src'First + 1;
         end if;
      end;
   end Index_From;

   function Index_Reverse (Source : Virtual_String; Pattern : Virtual_String) return Natural is
      WS_Src : constant Wide_Wide_String := VSS.Strings.Conversions.To_Wide_Wide_String (Source);
      WS_Pat : constant Wide_Wide_String := VSS.Strings.Conversions.To_Wide_Wide_String (Pattern);
   begin
      if WS_Pat'Length = 0 or else WS_Pat'Length > WS_Src'Length then
         return 0;
      end if;
      declare
         Pos : constant Natural := Ada.Strings.Wide_Wide_Fixed.Index (WS_Src, WS_Pat, Going => Ada.Strings.Backward);
      begin
         if Pos = 0 then
            return 0;
         else
            return Pos - WS_Src'First + 1;
         end if;
      end;
   end Index_Reverse;

   function To_Lower (Source : Virtual_String) return Virtual_String is
   begin
      return VSS.Transformers.Casing.To_Lowercase.Transform (Source);
   end To_Lower;

   function To_Upper (Source : Virtual_String) return Virtual_String is
   begin
      return VSS.Transformers.Casing.To_Uppercase.Transform (Source);
   end To_Upper;

   function Starts_With (Source : Virtual_String; Prefix : Virtual_String) return Boolean is
   begin
      return VSS.Strings.Starts_With (Source, Prefix);
   end Starts_With;

   function Starts_With_Latin_1 (Source : Virtual_String; Prefix : String) return Boolean is
   begin
      return Starts_With (Source, To_Virtual_String (Prefix));
   end Starts_With_Latin_1;

   function Ends_With (Source : Virtual_String; Suffix : Virtual_String) return Boolean is
   begin
      return VSS.Strings.Ends_With (Source, Suffix);
   end Ends_With;

   function Trim (Source : Virtual_String) return Virtual_String is
      WS : constant Wide_Wide_String := VSS.Strings.Conversions.To_Wide_Wide_String (Source);
   begin
      return VSS.Strings.To_Virtual_String (Ada.Strings.Wide_Wide_Fixed.Trim (WS, Ada.Strings.Both));
   end Trim;

   function From_Character (C : Wide_Wide_Character) return Virtual_String is
   begin
      return VSS.Characters.To_Virtual_String (To_Valid_Virtual_Character (C));
   end From_Character;

   function To_UTF_8 (Source : Virtual_String) return String is
   begin
      return VSS.Strings.Conversions.To_UTF_8_String (Source);
   end To_UTF_8;

   function To_Wide_Wide_String (Source : Virtual_String) return Wide_Wide_String is
   begin
      return VSS.Strings.Conversions.To_Wide_Wide_String (Source);
   end To_Wide_Wide_String;

   function From_Wide_Wide_String (Source : Wide_Wide_String) return Virtual_String is
      Sanitised : Wide_Wide_String (Source'Range);
   begin
      for I in Source'Range loop
         declare
            CP : constant Natural := Wide_Wide_Character'Pos (Source (I));
         begin
            if CP in 16#D800# .. 16#DFFF# or else CP > 16#10_FFFF# then
               Sanitised (I) := Wide_Wide_Character'Val (FFFD_Code_Point);
            else
               Sanitised (I) := Source (I);
            end if;
         end;
      end loop;
      return VSS.Strings.To_Virtual_String (Sanitised);
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
      if P in 16#09# .. 16#0D# or else P = 16#20# then
         return True;
      end if;
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

end VSS_Operations;
