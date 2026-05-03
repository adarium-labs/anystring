-------------------------------------------------------------------------------
--  Standard_String_Operations - Operations for Unbounded_String
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Strings;
with Ada.Strings.Fixed;
with Ada.Characters.Handling;

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
      return To_Unbounded_String ((1 => C));
   end From_Character;

end Standard_String_Operations;
