-------------------------------------------------------------------------------
--  Wide_Wide_Text_IO - Ada.Wide_Wide_Text_IO bridge for the wide_wide_string backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Strings.Wide_Wide_Unbounded; use Ada.Strings.Wide_Wide_Unbounded;

package body Wide_Wide_Text_IO with SPARK_Mode => Off is

   procedure Create (File : in out File_Type; Mode : File_Mode := Out_File; Name : String := "") is
   begin
      Ada.Wide_Wide_Text_IO.Create (File, Mode, Name);
   end Create;

   procedure Open (File : in out File_Type; Mode : File_Mode; Name : String) is
   begin
      Ada.Wide_Wide_Text_IO.Open (File, Mode, Name);
   end Open;

   procedure New_Line is
   begin
      Ada.Wide_Wide_Text_IO.New_Line;
   end New_Line;

   procedure New_Line (File : File_Type) is
   begin
      Ada.Wide_Wide_Text_IO.New_Line (File);
   end New_Line;

   procedure Put (Item : String_Type) is
   begin
      Ada.Wide_Wide_Text_IO.Put (To_Wide_Wide_String (Item));
   end Put;

   procedure Put (File : File_Type; Item : String_Type) is
   begin
      Ada.Wide_Wide_Text_IO.Put (File, To_Wide_Wide_String (Item));
   end Put;

   procedure Put_Line (Item : String_Type) is
   begin
      Ada.Wide_Wide_Text_IO.Put_Line (To_Wide_Wide_String (Item));
   end Put_Line;

   procedure Put_Line (File : File_Type; Item : String_Type) is
   begin
      Ada.Wide_Wide_Text_IO.Put_Line (File, To_Wide_Wide_String (Item));
   end Put_Line;

   function Get_Line return String_Type is
   begin
      return To_Unbounded_Wide_Wide_String (Ada.Wide_Wide_Text_IO.Get_Line);
   end Get_Line;

   function Get_Line (File : File_Type) return String_Type is
   begin
      return To_Unbounded_Wide_Wide_String (Ada.Wide_Wide_Text_IO.Get_Line (File));
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
