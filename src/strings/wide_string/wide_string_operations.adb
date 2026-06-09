-------------------------------------------------------------------------------
--  Wide_String_Operations - Operations for Wide_Unbounded_String
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Strings.Wide_Fixed;
with Ada.Strings;
with Ada.Strings.UTF_Encoding;
with Ada.Strings.UTF_Encoding.Wide_Strings;
with Ada.Environment_Variables;
with Ada.Wide_Characters.Handling;
with Anystrings_Internal_Wide_Environment_Encoding;

package body Wide_String_Operations is

   function To_Wide_String (Source : String) return Wide_String is
      Result : Wide_String (Source'Range);
   begin
      for I in Source'Range loop
         Result (I) := Wide_Character'Val (Character'Pos (Source (I)));
      end loop;
      return Result;
   end To_Wide_String;

   function To_String_From_Wide (Source : Wide_String) return String is
      Result : String (Source'Range);
   begin
      for I in Source'Range loop
         if Wide_Character'Pos (Source (I)) > 255 then
            Result (I) := '?';  --  Replacement for non-Latin-1 characters
         else
            Result (I) := Character'Val (Wide_Character'Pos (Source (I)));
         end if;
      end loop;
      return Result;
   end To_String_From_Wide;

   function Environment_Value
     (Name    : Unbounded_Wide_String;
      Default : Unbounded_Wide_String) return Unbounded_Wide_String
   is
   begin
      if not Anystrings_Internal_Wide_Environment_Encoding.Can_Encode (Name) then
         return Default;
      end if;

      declare
         Encoded_Name : constant String := Anystrings_Internal_Wide_Environment_Encoding.Encode (Name);
      begin
         if Ada.Environment_Variables.Exists (Encoded_Name) then
            return Anystrings_Internal_Wide_Environment_Encoding.Decode_Wide
              (Ada.Environment_Variables.Value (Encoded_Name));
         else
            return Default;
         end if;
      end;
   exception
      when others =>
         return Default;
   end Environment_Value;

   function Environment_Exists
     (Name : Unbounded_Wide_String) return Boolean
   is
   begin
      if not Anystrings_Internal_Wide_Environment_Encoding.Can_Encode (Name) then
         return False;
      end if;

      return Ada.Environment_Variables.Exists (Anystrings_Internal_Wide_Environment_Encoding.Encode (Name));
   exception
      when others =>
         return False;
   end Environment_Exists;

   function Environment_Set
     (Name  : Unbounded_Wide_String;
      Value : Unbounded_Wide_String) return Boolean
   is
   begin
      if not Anystrings_Internal_Wide_Environment_Encoding.Can_Encode (Name)
        or else not Anystrings_Internal_Wide_Environment_Encoding.Can_Encode (Value)
      then
         return False;
      end if;

      Ada.Environment_Variables.Set
        (Anystrings_Internal_Wide_Environment_Encoding.Encode (Name),
         Anystrings_Internal_Wide_Environment_Encoding.Encode (Value));
      return True;
   exception
      when others =>
         return False;
   end Environment_Set;

   function Environment_Clear
     (Name : Unbounded_Wide_String) return Boolean
   is
   begin
      if not Anystrings_Internal_Wide_Environment_Encoding.Can_Encode (Name) then
         return False;
      end if;

      Ada.Environment_Variables.Clear (Anystrings_Internal_Wide_Environment_Encoding.Encode (Name));
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
        (Name  : Unbounded_Wide_String;
         Value : Unbounded_Wide_String)) return Boolean
   is
      Success : Boolean := True;

      procedure Process_Item
        (Name, Value : String)
      is
      begin
         begin
            declare
               Decoded_Name : constant Unbounded_Wide_String :=
                 Anystrings_Internal_Wide_Environment_Encoding.Decode_Wide (Name);
               Decoded_Value : constant Unbounded_Wide_String :=
                 Anystrings_Internal_Wide_Environment_Encoding.Decode_Wide (Value);
            begin
               begin
                  Process.all (Decoded_Name, Decoded_Value);
               exception
                  when others =>
                     Success := False;
               end;
            end;
         exception
            when others =>
               null;
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
      Ada.Wide_Text_IO.Create (File, Mode, Name);
   end Create_File;

   procedure Open_File
     (File : in out File_Type;
      Mode : File_Mode;
      Name : String)
   is
   begin
      Ada.Wide_Text_IO.Open (File, Mode, Name);
   end Open_File;

   procedure Put_File
     (File : File_Type;
      Item : Unbounded_Wide_String)
   is
   begin
      Ada.Wide_Text_IO.Put
        (File,
         Ada.Strings.Wide_Unbounded.To_Wide_String (Item));
   end Put_File;

   function Get_Line_File
     (File : File_Type) return Unbounded_Wide_String
   is
   begin
      return Ada.Strings.Wide_Unbounded.To_Unbounded_Wide_String
        (Ada.Wide_Text_IO.Get_Line (File));
   end Get_Line_File;

   procedure New_Line_File
     (File : File_Type)
   is
   begin
      Ada.Wide_Text_IO.New_Line (File);
   end New_Line_File;

   function Concat_String_Latin_1
     (Left  : Unbounded_Wide_String;
      Right : String) return Unbounded_Wide_String
   is
      use Ada.Strings.Wide_Unbounded;
   begin
      return Left & To_Wide_String (Right);
   end Concat_String_Latin_1;

   function Concat_Latin_1_String
     (Left  : String;
      Right : Unbounded_Wide_String) return Unbounded_Wide_String
   is
      use Ada.Strings.Wide_Unbounded;
   begin
      return To_Wide_String (Left) & Right;
   end Concat_Latin_1_String;

   function To_Unbounded_Wide_String
     (Source : String) return Unbounded_Wide_String
   is
   begin
      return Ada.Strings.Wide_Unbounded.To_Unbounded_Wide_String
        (To_Wide_String (Source));
   end To_Unbounded_Wide_String;

   function To_String (Source : Unbounded_Wide_String) return String is
   begin
      return To_String_From_Wide
        (Ada.Strings.Wide_Unbounded.To_Wide_String (Source));
   end To_String;

   function Hash (Key : Unbounded_Wide_String) return Ada.Containers.Hash_Type is
      use Ada.Strings.Wide_Unbounded;
      Result : Ada.Containers.Hash_Type := 0;
      S      : constant Wide_String := To_Wide_String (Key);
   begin
      for I in S'Range loop
         Result := Ada.Containers.Hash_Type (Natural (Result) * 31 + Wide_Character'Pos (S (I)));
      end loop;
      return Result;
   end Hash;

   function Slice
     (Source : Unbounded_Wide_String;
      Low    : Positive;
      High   : Natural) return Unbounded_Wide_String
   is
      use Ada.Strings.Wide_Unbounded;
   begin
      return To_Unbounded_Wide_String (Slice (Source, Low, High));
   end Slice;

   function Index
     (Source  : Unbounded_Wide_String;
      Pattern : Unbounded_Wide_String) return Natural
   is
      use Ada.Strings.Wide_Unbounded;
   begin
      return Ada.Strings.Wide_Fixed.Index
        (To_Wide_String (Source), To_Wide_String (Pattern));
   end Index;

   function Index_Latin_1
     (Source  : Unbounded_Wide_String;
      Pattern : String) return Natural
   is
   begin
      return Index (Source, To_Unbounded_Wide_String (Pattern));
   end Index_Latin_1;

   function To_Lower (Source : Unbounded_Wide_String) return Unbounded_Wide_String
   is
      use Ada.Strings.Wide_Unbounded;
      S      : constant Wide_String := To_Wide_String (Source);
      Result : Wide_String (S'Range);
   begin
      for I in S'Range loop
         if Wide_Character'Pos (S (I)) in 65 .. 90 then
            Result (I) := Wide_Character'Val (Wide_Character'Pos (S (I)) + 32);
         else
            Result (I) := S (I);
         end if;
      end loop;
      return To_Unbounded_Wide_String (Result);
   end To_Lower;

   function To_Upper (Source : Unbounded_Wide_String) return Unbounded_Wide_String
   is
      use Ada.Strings.Wide_Unbounded;
      S      : constant Wide_String := To_Wide_String (Source);
      Result : Wide_String (S'Range);
   begin
      for I in S'Range loop
         if Wide_Character'Pos (S (I)) in 97 .. 122 then
            Result (I) := Wide_Character'Val (Wide_Character'Pos (S (I)) - 32);
         else
            Result (I) := S (I);
         end if;
      end loop;
      return To_Unbounded_Wide_String (Result);
   end To_Upper;

   function Starts_With
     (Source : Unbounded_Wide_String;
      Prefix : Unbounded_Wide_String) return Boolean
   is
      Prefix_Len : constant Natural := Ada.Strings.Wide_Unbounded.Length (Prefix);
   begin
      if Prefix_Len = 0 then
         return True;
      elsif Prefix_Len > Ada.Strings.Wide_Unbounded.Length (Source) then
         return False;
      else
         return Wide_String_Operations."="
           (Ada.Strings.Wide_Unbounded.To_Unbounded_Wide_String
              (Ada.Strings.Wide_Unbounded.Slice (Source, 1, Prefix_Len)),
            Prefix);
      end if;
   end Starts_With;

   function Starts_With_Latin_1
     (Source : Unbounded_Wide_String;
      Prefix : String) return Boolean
   is
   begin
      return Starts_With (Source, To_Unbounded_Wide_String (Prefix));
   end Starts_With_Latin_1;

   function Ends_With
     (Source : Unbounded_Wide_String;
      Suffix : Unbounded_Wide_String) return Boolean
   is
      Source_Len : constant Natural := Ada.Strings.Wide_Unbounded.Length (Source);
      Suffix_Len : constant Natural := Ada.Strings.Wide_Unbounded.Length (Suffix);
   begin
      if Suffix_Len = 0 then
         return True;
      elsif Suffix_Len > Source_Len then
         return False;
      else
         return Wide_String_Operations."="
           (Ada.Strings.Wide_Unbounded.To_Unbounded_Wide_String
              (Ada.Strings.Wide_Unbounded.Slice
                 (Source, Source_Len - Suffix_Len + 1, Source_Len)),
            Suffix);
      end if;
   end Ends_With;

   function Trim (Source : Unbounded_Wide_String) return Unbounded_Wide_String is
   begin
      return Ada.Strings.Wide_Unbounded.Trim (Source, Ada.Strings.Both);
   end Trim;

   function From_Character (C : Wide_Character) return Unbounded_Wide_String is
   begin
      return Ada.Strings.Wide_Unbounded.To_Unbounded_Wide_String ((1 => C));
   end From_Character;

   --  @relation FUNC-UTF8-003, FUNC-UTF8-005, FUNC-UTF8-006, FUNC-UTF8-007, NFR-UTF8-007
   function To_UTF_8 (Source : Unbounded_Wide_String) return String is
      WS : constant Wide_String :=
        Ada.Strings.Wide_Unbounded.To_Wide_String (Source);

      --  U+FFFD replacement character as Wide_Character
      Replacement : constant Wide_Character := Wide_Character'Val (16#FFFD#);

      --  Build a sanitised copy with surrogates replaced by U+FFFD.
      Sanitised : Wide_String (WS'Range);
   begin
      for I in WS'Range loop
         declare
            CP : constant Natural := Wide_Character'Pos (WS (I));
         begin
            if CP in 16#D800# .. 16#DFFF# then
               Sanitised (I) := Replacement;
            else
               Sanitised (I) := WS (I);
            end if;
         end;
      end loop;

      return Ada.Strings.UTF_Encoding.Wide_Strings.Encode
        (Item          => Sanitised,
         Output_Scheme => Ada.Strings.UTF_Encoding.UTF_8,
         Output_BOM    => False);
   end To_UTF_8;

   ---------------------------------------------------------------------------
   --  Character Classification & Case Mapping
   ---------------------------------------------------------------------------

   function Char_Is_Alphanumeric (C : Wide_Character) return Boolean is
   begin
      return Ada.Wide_Characters.Handling.Is_Alphanumeric (C);
   end Char_Is_Alphanumeric;

   function Char_Is_Control (C : Wide_Character) return Boolean is
   begin
      return Ada.Wide_Characters.Handling.Is_Control (C);
   end Char_Is_Control;

   function Char_Is_Digit (C : Wide_Character) return Boolean is
   begin
      return Ada.Wide_Characters.Handling.Is_Digit (C);
   end Char_Is_Digit;

   function Char_Is_Graphic (C : Wide_Character) return Boolean is
   begin
      --  Ada.Wide_Characters.Handling has no Is_Graphic; approximate as
      --  "not a control character".
      return not Ada.Wide_Characters.Handling.Is_Control (C);
   end Char_Is_Graphic;

   function Char_Is_Hex_Digit (C : Wide_Character) return Boolean is
   begin
      return Ada.Wide_Characters.Handling.Is_Hexadecimal_Digit (C);
   end Char_Is_Hex_Digit;

   function Char_Is_Letter (C : Wide_Character) return Boolean is
   begin
      return Ada.Wide_Characters.Handling.Is_Letter (C);
   end Char_Is_Letter;

   function Char_Is_Line_Terminator (C : Wide_Character) return Boolean is
      P : constant Natural := Wide_Character'Pos (C);
   begin
      --  wide_string is non-Unicode by contract: LF (0x0A), CR (0x0D) only.
      return P = 16#0A# or else P = 16#0D#;
   end Char_Is_Line_Terminator;

   function Char_Is_Lower (C : Wide_Character) return Boolean is
   begin
      return Ada.Wide_Characters.Handling.Is_Lower (C);
   end Char_Is_Lower;

   function Char_Is_Upper (C : Wide_Character) return Boolean is
   begin
      return Ada.Wide_Characters.Handling.Is_Upper (C);
   end Char_Is_Upper;

   function Char_Is_Whitespace (C : Wide_Character) return Boolean is
      P : constant Natural := Wide_Character'Pos (C);
   begin
      --  wide_string contract: ASCII whitespace SP/HT/LF/VT/FF/CR.
      return P in 16#09# .. 16#0D# or else P = 16#20#;
   end Char_Is_Whitespace;

   function Char_To_Lower (C : Wide_Character) return Wide_Character is
   begin
      return Ada.Wide_Characters.Handling.To_Lower (C);
   end Char_To_Lower;

   function Char_To_Upper (C : Wide_Character) return Wide_Character is
   begin
      return Ada.Wide_Characters.Handling.To_Upper (C);
   end Char_To_Upper;

end Wide_String_Operations;
