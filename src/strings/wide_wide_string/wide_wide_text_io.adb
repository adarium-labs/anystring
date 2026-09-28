-------------------------------------------------------------------------------
--  Wide_Wide_Text_IO - UTF-8 Text_IO bridge for the wide_wide_string backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Strings.UTF_Encoding.Wide_Wide_Strings;
with Ada.Strings.Wide_Wide_Unbounded; use Ada.Strings.Wide_Wide_Unbounded;

package body Wide_Wide_Text_IO with SPARK_Mode => Off is

   package UTF renames Ada.Strings.UTF_Encoding;
   package WWS renames Ada.Strings.UTF_Encoding.Wide_Wide_Strings;

   REPLACEMENT : constant Wide_Wide_Character := Wide_Wide_Character'Val (16#FFFD#);

   --  UTF-8 bytes of Item; code points that cannot be encoded become U+FFFD.
   function To_UTF_8 (Item : String_Type) return String is
      Value : constant Wide_Wide_String := To_Wide_Wide_String (Item);
   begin
      return WWS.Encode (Value);
   exception
      when UTF.Encoding_Error =>
         declare
            Clean : Wide_Wide_String := Value;
         begin
            for C of Clean loop
               if Wide_Wide_Character'Pos (C) in 16#D800# .. 16#DFFF#
                 or else Wide_Wide_Character'Pos (C) > 16#10FFFF#
               then
                  C := REPLACEMENT;
               end if;
            end loop;
            return WWS.Encode (Clean);
         end;
   end To_UTF_8;

   --  Code points of a UTF-8 line; an invalid line is taken as Latin-1.
   function From_UTF_8 (Line : String) return String_Type is
   begin
      return To_Unbounded_Wide_Wide_String (WWS.Decode (Line));
   exception
      when UTF.Encoding_Error =>
         declare
            Result : Wide_Wide_String (Line'Range);
         begin
            for I in Line'Range loop
               Result (I) := Wide_Wide_Character'Val (Character'Pos (Line (I)));
            end loop;
            return To_Unbounded_Wide_Wide_String (Result);
         end;
   end From_UTF_8;

   procedure Create (File : in out File_Type; Mode : File_Mode := Out_File; Name : String := "") is
   begin
      Ada.Text_IO.Create (File, Mode, Name);
   end Create;

   procedure Open (File : in out File_Type; Mode : File_Mode; Name : String) is
   begin
      Ada.Text_IO.Open (File, Mode, Name);
   end Open;

   procedure New_Line is
   begin
      Ada.Text_IO.New_Line;
   end New_Line;

   procedure New_Line (File : File_Type) is
   begin
      Ada.Text_IO.New_Line (File);
   end New_Line;

   procedure Put (Item : String_Type) is
   begin
      Ada.Text_IO.Put (To_UTF_8 (Item));
   end Put;

   procedure Put (File : File_Type; Item : String_Type) is
   begin
      Ada.Text_IO.Put (File, To_UTF_8 (Item));
   end Put;

   procedure Put_Line (Item : String_Type) is
   begin
      Ada.Text_IO.Put_Line (To_UTF_8 (Item));
   end Put_Line;

   procedure Put_Line (File : File_Type; Item : String_Type) is
   begin
      Ada.Text_IO.Put_Line (File, To_UTF_8 (Item));
   end Put_Line;

   function Get_Line return String_Type is
   begin
      return From_UTF_8 (Ada.Text_IO.Get_Line);
   end Get_Line;

   function Get_Line (File : File_Type) return String_Type is
   begin
      return From_UTF_8 (Ada.Text_IO.Get_Line (File));
   end Get_Line;

   procedure Get_Line (Item : out String_Type) is
   begin
      Item := Get_Line;
   end Get_Line;

   procedure Get_Line (File : File_Type; Item : out String_Type) is
   begin
      Item := Get_Line (File);
   end Get_Line;

end Wide_Wide_Text_IO;
