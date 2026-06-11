-------------------------------------------------------------------------------
--  Standard_String_Operations - Operations for Unbounded_String
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Strings;
with Ada.Environment_Variables;
with Ada.Strings.Fixed;

package body Standard_String_Operations is

   --  Walk one UTF-8 code-point sequence starting at Buf (Start), decoding
   --  the leading 1..4 bytes per RFC 3629 and reporting:
   --
   --    Code_Point — the decoded scalar value.  On malformed input the
   --                 helper returns U+FFFD (16#FFFD#) as a deterministic
   --                 replacement (FUNC-CONV-006: To_Latin_1 is total).
   --    Step       — the number of source bytes consumed (1 for ASCII,
   --                 2..4 for multi-byte sequences, 1 for resynchronisation
   --                 on malformed input).
   --
   --  This helper is local to the body because both To_Latin_1 and
   --  To_Latin_1_If_Possible need to consume exactly the same byte-walking
   --  semantics, and the only difference between them is whether a
   --  replacement is counted.
   procedure Decode_One_UTF_8_Code_Point
     (Buf        : String;
      Start      : Natural;
      Code_Point : out Natural;
      Step       : out Natural);

   procedure Decode_One_UTF_8_Code_Point
     (Buf        : String;
      Start      : Natural;
      Code_Point : out Natural;
      Step       : out Natural)
   is
      function Is_Cont (C : Character) return Boolean
      is (Character'Pos (C) in 16#80# .. 16#BF#);

      Lead : constant Natural := Character'Pos (Buf (Start));
   begin
      --  Default for malformed input: U+FFFD, single-byte resync.
      Code_Point := 16#FFFD#;
      Step       := 1;

      if Lead <= 16#7F# then
         --  1-byte ASCII.
         Code_Point := Lead;
         Step       := 1;

      elsif Lead in 16#C2# .. 16#DF#
        and then Start + 1 <= Buf'Last
        and then Is_Cont (Buf (Start + 1))
      then
         --  2-byte sequence: 110xxxxx 10xxxxxx — encodes U+0080..U+07FF.
         Code_Point :=
           (Lead mod 32) * 64
           + (Character'Pos (Buf (Start + 1)) mod 64);
         Step       := 2;

      elsif Lead in 16#E0# .. 16#EF#
        and then Start + 2 <= Buf'Last
        and then Is_Cont (Buf (Start + 1))
        and then Is_Cont (Buf (Start + 2))
      then
         --  3-byte sequence: 1110xxxx 10xxxxxx 10xxxxxx
         --  — encodes U+0800..U+FFFF (with surrogates U+D800..U+DFFF
         --  treated as replacement).
         Code_Point :=
           (Lead mod 16) * 4_096
           + (Character'Pos (Buf (Start + 1)) mod 64) * 64
           + (Character'Pos (Buf (Start + 2)) mod 64);
         Step       := 3;
         if Code_Point in 16#D800# .. 16#DFFF# then
            Code_Point := 16#FFFD#;
         end if;

      elsif Lead in 16#F0# .. 16#F4#
        and then Start + 3 <= Buf'Last
        and then Is_Cont (Buf (Start + 1))
        and then Is_Cont (Buf (Start + 2))
        and then Is_Cont (Buf (Start + 3))
      then
         --  4-byte sequence: 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
         --  — encodes U+10000..U+10FFFF.
         Code_Point :=
           (Lead mod 8) * 262_144
           + (Character'Pos (Buf (Start + 1)) mod 64) * 4_096
           + (Character'Pos (Buf (Start + 2)) mod 64) * 64
           + (Character'Pos (Buf (Start + 3)) mod 64);
         Step       := 4;
         if Code_Point > 16#10_FFFF# then
            Code_Point := 16#FFFD#;
         end if;
      end if;
      --  Any other lead byte (bare continuation 0x80..0xBF, overlong
      --  starters 0xC0..0xC1, out-of-range 0xF5..0xFF, or truncated
      --  multi-byte sequence) falls through to the default
      --  (U+FFFD, single-byte resync) set above.
   end Decode_One_UTF_8_Code_Point;


   function Environment_Value (Name : Unbounded_String; Default : Unbounded_String) return Unbounded_String is
   begin
      return To_Unbounded_String (Ada.Environment_Variables.Value (To_String (Name), To_String (Default)));
   end Environment_Value;

   function Environment_Exists (Name : Unbounded_String) return Boolean is
   begin
      return Ada.Environment_Variables.Exists (To_String (Name));
   end Environment_Exists;

   function Environment_Set (Name : Unbounded_String; Value : Unbounded_String) return Boolean is
   begin
      Ada.Environment_Variables.Set (To_String (Name), To_String (Value));
      return True;
   exception
      when others =>
         return False;
   end Environment_Set;

   function Environment_Clear (Name : Unbounded_String) return Boolean is
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
     (Process : not null access procedure (Name : Unbounded_String; Value : Unbounded_String)) return Boolean
   is
      Success : Boolean := True;

      procedure Process_Item (Name, Value : String) is
      begin
         begin
            Process.all (To_Unbounded_String (Name), To_Unbounded_String (Value));
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

   procedure Create_File (File : in out File_Type; Mode : File_Mode := Out_File_Mode; Name : String := "") is
   begin
      Ada.Text_IO.Create (File, Mode, Name);
   end Create_File;

   procedure Open_File (File : in out File_Type; Mode : File_Mode; Name : String) is
   begin
      Ada.Text_IO.Open (File, Mode, Name);
   end Open_File;

   procedure Put_File (File : File_Type; Item : Unbounded_String) is
   begin
      Ada.Text_IO.Put (File, To_String (Item));
   end Put_File;

   function Get_Line_File (File : File_Type) return Unbounded_String is
   begin
      return To_Unbounded_String (Ada.Text_IO.Get_Line (File));
   end Get_Line_File;

   procedure New_Line_File (File : File_Type) is
   begin
      Ada.Text_IO.New_Line (File);
   end New_Line_File;

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

   function Index_From
     (Source      : Unbounded_String;
      Pattern     : Unbounded_String;
      Starting_At : Positive) return Natural
   is
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

   function To_Lower (Source : Unbounded_String) return Unbounded_String is
      S : constant String := To_String (Source);
   begin
      return To_Unbounded_String (Ada.Characters.Handling.To_Lower (S));
   end To_Lower;

   function To_Upper (Source : Unbounded_String) return Unbounded_String is
      S : constant String := To_String (Source);
   begin
      return To_Unbounded_String (Ada.Characters.Handling.To_Upper (S));
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
   function To_Latin_1 (Source : Unbounded_String) return String is
      Buf     : constant String := To_String (Source);
      Out_Buf : Ada.Strings.Unbounded.Unbounded_String;
      I       : Natural := Buf'First;
   begin
      while I <= Buf'Last loop
         declare
            CP   : Natural;
            Step : Natural;
         begin
            Decode_One_UTF_8_Code_Point (Buf, I, CP, Step);
            if CP <= 16#FF# then
               Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (CP));
            else
               Ada.Strings.Unbounded.Append (Out_Buf, '?');
            end if;
            I := I + Step;
         end;
      end loop;
      return Ada.Strings.Unbounded.To_String (Out_Buf);
   end To_Latin_1;

   --  @relation FUNC-CONV-008, FUNC-CONV-009
   function To_Latin_1_If_Possible
     (Source : Unbounded_String) return Anystrings_Conv.Latin_1_Conv_Result
   is
      Buf     : constant String := To_String (Source);
      Out_Buf : Ada.Strings.Unbounded.Unbounded_String;
      I       : Natural := Buf'First;
      Repls   : Natural := 0;
   begin
      while I <= Buf'Last loop
         declare
            CP   : Natural;
            Step : Natural;
         begin
            Decode_One_UTF_8_Code_Point (Buf, I, CP, Step);
            if CP <= 16#FF# then
               Ada.Strings.Unbounded.Append (Out_Buf, Character'Val (CP));
            else
               Ada.Strings.Unbounded.Append (Out_Buf, '?');
               Repls := Repls + 1;
            end if;
            I := I + Step;
         end;
      end loop;
      return
        (Status         => (if Repls = 0 then Anystrings_Conv.Ok
                            else Anystrings_Conv.Lossy),
         Value          => Out_Buf,
         Replaced_Count => Repls);
   end To_Latin_1_If_Possible;

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

end Standard_String_Operations;
