-------------------------------------------------------------------------------
--  Standard_String_Operations - Operations for Unbounded_String
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Strings;
with Ada.Strings.UTF_Encoding;
with Ada.Strings.UTF_Encoding.Strings;
with Ada.Environment_Variables;
with Ada.Text_IO;
with Ada.Strings.Fixed;
with Ada.Characters.Handling;

package body Standard_String_Operations is

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

   --  @relation FUNC-UTF8-003, FUNC-UTF8-005, FUNC-UTF8-006, NFR-UTF8-007, NFR-UTF8-010
   function To_UTF_8 (Source : Unbounded_String) return String is
      S : constant String := To_String (Source);
   begin
      return
        Ada.Strings.UTF_Encoding.Strings.Encode
          (Item => S, Output_Scheme => Ada.Strings.UTF_Encoding.UTF_8, Output_BOM => False);
   end To_UTF_8;

end Standard_String_Operations;
