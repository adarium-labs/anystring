-------------------------------------------------------------------------------
--  Wide_Wide_String_Operations - Operations for Wide_Wide_Unbounded_String
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Strings.Wide_Wide_Fixed;
with Ada.Strings;
with Wide_Wide_String_Operations;

package body Wide_Wide_String_Operations is

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

   function Concat_String_Latin_1
     (Left  : Unbounded_Wide_Wide_String;
      Right : String) return Unbounded_Wide_Wide_String
   is
      use Ada.Strings.Wide_Wide_Unbounded;
   begin
      return Left & To_Wide_Wide_String (Right);
   end Concat_String_Latin_1;

   function Concat_Latin_1_String
     (Left  : String;
      Right : Unbounded_Wide_Wide_String) return Unbounded_Wide_Wide_String
   is
      use Ada.Strings.Wide_Wide_Unbounded;
   begin
      return To_Wide_Wide_String (Left) & Right;
   end Concat_Latin_1_String;

   function To_Unbounded_Wide_Wide_String
     (Source : String) return Unbounded_Wide_Wide_String
   is
   begin
      return Ada.Strings.Wide_Wide_Unbounded.To_Unbounded_Wide_Wide_String
        (To_Wide_Wide_String (Source));
   end To_Unbounded_Wide_Wide_String;

   function To_Unbounded_Wide_Wide_String
     (Source : Wide_Wide_String) return Unbounded_Wide_Wide_String
   is
   begin
      return Ada.Strings.Wide_Wide_Unbounded.To_Unbounded_Wide_Wide_String (Source);
   end To_Unbounded_Wide_Wide_String;

   function To_String (Source : Unbounded_Wide_Wide_String) return String is
   begin
      return To_String_From_Wide_Wide
        (Ada.Strings.Wide_Wide_Unbounded.To_Wide_Wide_String (Source));
   end To_String;

   function Hash
     (Key : Unbounded_Wide_Wide_String) return Ada.Containers.Hash_Type
   is
      use Ada.Strings.Wide_Wide_Unbounded;
      Result : Ada.Containers.Hash_Type := 0;
      S      : constant Wide_Wide_String := To_Wide_Wide_String (Key);
   begin
      for I in S'Range loop
         Result := Ada.Containers.Hash_Type (Natural (Result) * 31 +
           Wide_Wide_Character'Pos (S (I)));
      end loop;
      return Result;
   end Hash;

   function Slice
     (Source : Unbounded_Wide_Wide_String;
      Low    : Positive;
      High   : Natural) return Unbounded_Wide_Wide_String
   is
      use Ada.Strings.Wide_Wide_Unbounded;
   begin
      return To_Unbounded_Wide_Wide_String (Slice (Source, Low, High));
   end Slice;

   function Index
     (Source  : Unbounded_Wide_Wide_String;
      Pattern : Unbounded_Wide_Wide_String) return Natural
   is
      use Ada.Strings.Wide_Wide_Unbounded;
      use Ada.Strings.Wide_Wide_Fixed;
   begin
      return Ada.Strings.Wide_Wide_Fixed.Index
        (To_Wide_Wide_String (Source), To_Wide_Wide_String (Pattern));
   end Index;

   function Index_Latin_1
     (Source  : Unbounded_Wide_Wide_String;
      Pattern : String) return Natural
   is
   begin
      return Index (Source, To_Unbounded_Wide_Wide_String (Pattern));
   end Index_Latin_1;

   function To_Lower
     (Source : Unbounded_Wide_Wide_String) return Unbounded_Wide_Wide_String
   is
      use Ada.Strings.Wide_Wide_Unbounded;
      S      : constant Wide_Wide_String := To_Wide_Wide_String (Source);
      Result : Wide_Wide_String (S'Range);
   begin
      for I in S'Range loop
         if Wide_Wide_Character'Pos (S (I)) in 65 .. 90 then
            Result (I) :=
              Wide_Wide_Character'Val (Wide_Wide_Character'Pos (S (I)) + 32);
         else
            Result (I) := S (I);
         end if;
      end loop;
      return To_Unbounded_Wide_Wide_String (Result);
   end To_Lower;

   function To_Upper
     (Source : Unbounded_Wide_Wide_String) return Unbounded_Wide_Wide_String
   is
      use Ada.Strings.Wide_Wide_Unbounded;
      S      : constant Wide_Wide_String := To_Wide_Wide_String (Source);
      Result : Wide_Wide_String (S'Range);
   begin
      for I in S'Range loop
         if Wide_Wide_Character'Pos (S (I)) in 97 .. 122 then
            Result (I) :=
              Wide_Wide_Character'Val (Wide_Wide_Character'Pos (S (I)) - 32);
         else
            Result (I) := S (I);
         end if;
      end loop;
      return To_Unbounded_Wide_Wide_String (Result);
   end To_Upper;

   function Starts_With
     (Source : Unbounded_Wide_Wide_String;
      Prefix : Unbounded_Wide_Wide_String) return Boolean
   is
      use Ada.Strings.Wide_Wide_Unbounded;
      Prefix_Len : constant Natural := Length (Prefix);
   begin
      if Prefix_Len = 0 then
         return True;
      elsif Prefix_Len > Length (Source) then
         return False;
      else
         return Wide_Wide_String_Operations."=" (Slice (Source, 1, Prefix_Len), Prefix);
      end if;
   end Starts_With;

   function Starts_With_Latin_1
     (Source : Unbounded_Wide_Wide_String;
      Prefix : String) return Boolean
   is
   begin
      return Starts_With (Source, To_Unbounded_Wide_Wide_String (Prefix));
   end Starts_With_Latin_1;

   function Ends_With
     (Source : Unbounded_Wide_Wide_String;
      Suffix : Unbounded_Wide_Wide_String) return Boolean
   is
      use Ada.Strings.Wide_Wide_Unbounded;
      Source_Len : constant Natural := Length (Source);
      Suffix_Len : constant Natural := Length (Suffix);
   begin
      if Suffix_Len = 0 then
         return True;
      elsif Suffix_Len > Source_Len then
         return False;
      else
         return Wide_Wide_String_Operations."=" (Slice (Source, Source_Len - Suffix_Len + 1, Source_Len), Suffix);
      end if;
   end Ends_With;

   function Trim
     (Source : Unbounded_Wide_Wide_String) return Unbounded_Wide_Wide_String
   is
      use Ada.Strings.Wide_Wide_Unbounded;
   begin
      return Trim (Source, Ada.Strings.Both);
   end Trim;

   function From_Character
     (C : Wide_Wide_Character) return Unbounded_Wide_Wide_String
   is
   begin
      return Ada.Strings.Wide_Wide_Unbounded.To_Unbounded_Wide_Wide_String
        ((1 => C));
   end From_Character;

end Wide_Wide_String_Operations;
