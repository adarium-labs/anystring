-------------------------------------------------------------------------------
--  UXString_Operations - Operations for UXStrings.UXString
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Environment_Variables;
with Ada.Strings;
with Ada.Strings.Unbounded;
with Ada.Wide_Wide_Characters.Handling;

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

   function To_String (Source : UXString) return String is
   begin
      return String (UXStrings.To_UTF_8 (Source));
   end To_String;

   function Environment_Value
     (Name    : UXString;
      Default : UXString) return UXString
   is
      Encoded_Name : constant String := To_String (Name);
   begin
      if Ada.Environment_Variables.Exists (Encoded_Name) then
         return From_UTF_8 (Ada.Environment_Variables.Value (Encoded_Name));
      else
         return Default;
      end if;
   end Environment_Value;

   function Environment_Exists
     (Name : UXString) return Boolean
   is
   begin
      return Ada.Environment_Variables.Exists (To_String (Name));
   end Environment_Exists;

   function Environment_Set
     (Name  : UXString;
      Value : UXString) return Boolean
   is
   begin
      Ada.Environment_Variables.Set (To_String (Name), To_String (Value));
      return True;
   exception
      when others =>
         return False;
   end Environment_Set;

   function Environment_Clear
     (Name : UXString) return Boolean
   is
   begin
      Ada.Environment_Variables.Clear (To_String (Name));
      return True;
   exception
      when others =>
         return False;
   end Environment_Clear;

   function Environment_Clear return Boolean is
   begin
      Ada.Environment_Variables.Clear;
      return True;
   exception
      when others =>
         return False;
   end Environment_Clear;

   function Environment_Iterate
     (Process : not null access procedure
        (Name  : UXString;
         Value : UXString)) return Boolean
   is
      Success : Boolean := True;

      procedure Process_Item
        (Name, Value : String)
      is
      begin
         begin
            Process.all (From_UTF_8 (Name), From_UTF_8 (Value));
         exception
            when others =>
               Success := False;
         end;
      end Process_Item;
   begin
      begin
         Ada.Environment_Variables.Iterate (Process_Item'Access);
      exception
         when others =>
            Success := False;
      end;

      return Success;
   end Environment_Iterate;

   procedure Create_File
     (File : in out File_Type;
      Mode : File_Mode := Out_File_Mode;
      Name : String := "")
   is
   begin
      Ada.Text_IO.Create (File, Mode, Name);
   end Create_File;

   procedure Open_File
     (File : in out File_Type;
      Mode : File_Mode;
      Name : String)
   is
   begin
      Ada.Text_IO.Open (File, Mode, Name);
   end Open_File;

   procedure Put_File
     (File : File_Type;
      Item : UXString)
   is
   begin
      Ada.Text_IO.Put (File, To_String (Item));
   end Put_File;

   function Get_Line_File
     (File : File_Type) return UXString
   is
   begin
      return From_UTF_8 (Ada.Text_IO.Get_Line (File));
   end Get_Line_File;

   procedure New_Line_File
     (File : File_Type)
   is
   begin
      Ada.Text_IO.New_Line (File);
   end New_Line_File;

   function Concat_String_Latin_1
     (Left  : UXString;
      Right : String) return UXString
   is
   begin
      return Left & UXStrings.From_Latin_1 (Right);
   end Concat_String_Latin_1;

   function Concat_Latin_1_String
     (Left  : String;
      Right : UXString) return UXString
   is
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

   function Slice
     (Source : UXString;
      Low    : Positive;
      High   : Natural) return UXString
   is
   begin
      return UXStrings.Slice (Source, Low, High);
   end Slice;

   function Index
     (Source  : UXString;
      Pattern : UXString) return Natural
   is
   begin
      return UXStrings.Index (Source, Pattern);
   end Index;

   function Index_Latin_1
     (Source  : UXString;
      Pattern : String) return Natural
   is
   begin
      return UXStrings.Index (Source, UXStrings.From_Latin_1 (Pattern));
   end Index_Latin_1;

   function Index_From
     (Source      : UXString;
      Pattern     : UXString;
      Starting_At : Positive) return Natural
   is
      S_Len : constant Natural := Length (Source);
      P_Len : constant Natural := Length (Pattern);
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

   function Index_Reverse
     (Source  : UXString;
      Pattern : UXString) return Natural
   is
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

   function To_Lower (Source : UXString) return UXString is
   begin
      return UXStrings.To_Lower (Source);
   end To_Lower;

   function To_Upper (Source : UXString) return UXString is
   begin
      return UXStrings.To_Upper (Source);
   end To_Upper;

   function Starts_With
     (Source : UXString;
      Prefix : UXString) return Boolean
   is
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

   function Starts_With_Latin_1
     (Source : UXString;
      Prefix : String) return Boolean
   is
   begin
      return UXString_Operations.Starts_With (Source, UXStrings.From_Latin_1 (Prefix));
   end Starts_With_Latin_1;

   function Ends_With
     (Source : UXString;
      Suffix : UXString) return Boolean
   is
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

   --  @relation FUNC-UTF8-003, FUNC-UTF8-005, FUNC-UTF8-006, NFR-UTF8-007
   function To_UTF_8 (Source : UXString) return String is
      use Ada.Strings.Unbounded;

      --  Replacement character U+FFFD (3 bytes: EF BF BD)
      FFFD : constant String :=
        Character'Val (16#EF#) & Character'Val (16#BF#) & Character'Val (16#BD#);

      --  Encode a single Latin-1 code point (0..255) as UTF-8.
      function Encode_Latin_1 (B : Natural) return String is
      begin
         if B <= 16#7F# then
            return String'(1 => Character'Val (B));
         else
            --  U+0080..U+00FF: 2-byte UTF-8 sequence.
            --  High byte = 0xC0 + B/64; Low byte = 0x80 + B mod 64.
            --  For B in 128..255: B/64 in 2..3, so high byte in 0xC2..0xC3.
            return String'(Character'Val (16#C0# + (B / 64)),
                           Character'Val (16#80# + (B mod 64)));
         end if;
      end Encode_Latin_1;

      function Is_Cont (C : Character) return Boolean is
         B : constant Natural := Character'Pos (C);
      begin
         return B in 16#80# .. 16#BF#;
      end Is_Cont;

      --  The internal byte representation from UXStrings (UXS1 stores raw
      --  bytes as given to From_UTF_8; UXS5 stores validated UTF-8).
      Raw    : constant String := String (UXStrings.To_UTF_8 (Source));
      Result : Unbounded_String;
      I      : Positive;
      Lead   : Natural;
      CP     : Natural;
   begin
      if Raw'Length = 0 then
         return "";
      end if;

      I := Raw'First;
      while I <= Raw'Last loop
         Lead := Character'Pos (Raw (I));

         if Lead <= 16#7F# then
            --  ASCII single byte — always valid UTF-8, pass through.
            Append (Result, Raw (I));
            I := I + 1;

         elsif Lead in 16#C2# .. 16#DF# then
            --  2-byte sequence: valid if followed by one continuation byte.
            if I + 1 <= Raw'Last and then Is_Cont (Raw (I + 1)) then
               Append (Result, Raw (I .. I + 1));
               I := I + 2;
            else
               --  Truncated or invalid: treat lead as Latin-1 code point.
               Append (Result, Encode_Latin_1 (Lead));
               I := I + 1;
            end if;

         elsif Lead in 16#E0# .. 16#EF# then
            --  3-byte sequence: valid if followed by two continuation bytes.
            if I + 2 <= Raw'Last
               and then Is_Cont (Raw (I + 1))
               and then Is_Cont (Raw (I + 2))
            then
               CP :=
                 (Lead mod 16) * 4_096
                 + (Character'Pos (Raw (I + 1)) mod 64) * 64
                 + (Character'Pos (Raw (I + 2)) mod 64);
               if CP in 16#D800# .. 16#DFFF# then
                  --  Surrogate code point — replace with U+FFFD.
                  Append (Result, FFFD);
               else
                  Append (Result, Raw (I .. I + 2));
               end if;
               I := I + 3;
            else
               --  Truncated: treat lead as Latin-1 code point.
               Append (Result, Encode_Latin_1 (Lead));
               I := I + 1;
            end if;

         elsif Lead in 16#F0# .. 16#F4# then
            --  4-byte sequence: valid if followed by three continuation bytes.
            if I + 3 <= Raw'Last
               and then Is_Cont (Raw (I + 1))
               and then Is_Cont (Raw (I + 2))
               and then Is_Cont (Raw (I + 3))
            then
               CP :=
                 (Lead mod 8) * 262_144
                 + (Character'Pos (Raw (I + 1)) mod 64) * 4_096
                 + (Character'Pos (Raw (I + 2)) mod 64) * 64
                 + (Character'Pos (Raw (I + 3)) mod 64);
               if CP > 16#10_FFFF# then
                  Append (Result, FFFD);
               else
                  Append (Result, Raw (I .. I + 3));
               end if;
               I := I + 4;
            else
               Append (Result, Encode_Latin_1 (Lead));
               I := I + 1;
            end if;

         else
            --  0x80..0xBF (bare continuation), 0xC0..0xC1 (always overlong),
            --  0xF5..0xFF (out-of-range lead): treat as Latin-1 code point.
            Append (Result, Encode_Latin_1 (Lead));
            I := I + 1;
         end if;
      end loop;

      return To_String (Result);
   end To_UTF_8;

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
      return P = 16#0A#
        or else P = 16#0D#
        or else P = 16#85#
        or else P = 16#2028#
        or else P = 16#2029#;
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
