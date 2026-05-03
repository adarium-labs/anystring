-------------------------------------------------------------------------------
--  UXString_Operations - Operations for UXStrings.UXString
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

package body UXString_Operations is

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
      return Starts_With (Source, From_UTF_8 (Prefix));
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
      return UXStrings.Trim (Source, UXStrings.Both);
   end Trim;

   function From_Character (C : Unicode_Character) return UXString is
   begin
      return UXStrings.From_Unicode (C);
   end From_Character;

end UXString_Operations;
