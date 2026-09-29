-------------------------------------------------------------------------------
--  Wide_Text_IO - UTF-8 Text_IO bridge for the wide_string backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Anystrings_Byte_Output;
with Ada.Strings.UTF_Encoding.Wide_Strings;
with Ada.Strings.Wide_Unbounded; use Ada.Strings.Wide_Unbounded;

package body Wide_Text_IO
  with SPARK_Mode => Off
is

   package UTF renames Ada.Strings.UTF_Encoding;
   package WS renames Ada.Strings.UTF_Encoding.Wide_Strings;

   REPLACEMENT : constant Wide_Character := Wide_Character'Val (16#FFFD#);

   --  UTF-8 bytes of Item (UTF-16); unpaired surrogates become U+FFFD.
   function To_UTF_8 (Item : String_Type) return String is
      Value : constant Wide_String := To_Wide_String (Item);
   begin
      return WS.Encode (Value);
   exception
      when UTF.Encoding_Error =>
         declare
            subtype High is Wide_Character range Wide_Character'Val (16#D800#) .. Wide_Character'Val (16#DBFF#);
            subtype Low is Wide_Character range Wide_Character'Val (16#DC00#) .. Wide_Character'Val (16#DFFF#);
            Clean : Wide_String := Value;
            I     : Natural := Clean'First;
         begin
            while I <= Clean'Last loop
               if Clean (I) in High and then I < Clean'Last and then Clean (I + 1) in Low then
                  I := I + 2;
               else
                  if Clean (I) in High | Low then
                     Clean (I) := REPLACEMENT;
                  end if;
                  I := I + 1;
               end if;
            end loop;
            return WS.Encode (Clean);
         end;
   end To_UTF_8;

   --  UTF-16 value of a UTF-8 line; an invalid line is taken as Latin-1.
   function From_UTF_8 (Line : String) return String_Type is
   begin
      return To_Unbounded_Wide_String (WS.Decode (Line));
   exception
      when UTF.Encoding_Error =>
         declare
            Result : Wide_String (Line'Range);
         begin
            for I in Line'Range loop
               Result (I) := Wide_Character'Val (Character'Pos (Line (I)));
            end loop;
            return To_Unbounded_Wide_String (Result);
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
      Anystrings_Byte_Output.Put (To_UTF_8 (Item));
   end Put;

   procedure Put (File : File_Type; Item : String_Type) is
   begin
      Anystrings_Byte_Output.Put (File, To_UTF_8 (Item));
   end Put;

   procedure Put_Line (Item : String_Type) is
   begin
      Anystrings_Byte_Output.Put_Line (To_UTF_8 (Item));
   end Put_Line;

   procedure Put_Line (File : File_Type; Item : String_Type) is
   begin
      Anystrings_Byte_Output.Put_Line (File, To_UTF_8 (Item));
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

end Wide_Text_IO;
