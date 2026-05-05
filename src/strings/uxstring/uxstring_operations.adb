-------------------------------------------------------------------------------
--  UXString_Operations - Operations for UXStrings.UXString
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Environment_Variables;
with Ada.Strings;

package body UXString_Operations is

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
      return Left & From_UTF_8 (Right);
   end Concat_String_Latin_1;

   function Concat_Latin_1_String
     (Left  : String;
      Right : UXString) return UXString
   is
   begin
      return From_UTF_8 (Left) & Right;
   end Concat_Latin_1_String;

   function Hash (Key : UXString) return Ada.Containers.Hash_Type is
      --  Simple hash using UTF-8 representation
      Result : Ada.Containers.Hash_Type := 0;
      UTF8   : constant String := To_UTF_8 (Key);
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
      return UXStrings.Index (Source, From_UTF_8 (Pattern));
   end Index_Latin_1;

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
      return UXString_Operations.Starts_With (Source, From_UTF_8 (Prefix));
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

end UXString_Operations;
