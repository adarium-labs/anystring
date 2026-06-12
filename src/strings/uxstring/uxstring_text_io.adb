-------------------------------------------------------------------------------
--  UXString_Text_IO - Ada.Text_IO bridge for the uxstring backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with UXString_Operations;

package body UXString_Text_IO with SPARK_Mode => Off is

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
      Ada.Text_IO.Put (UXString_Operations.To_String (Item));
   end Put;

   procedure Put (File : File_Type; Item : String_Type) is
   begin
      Ada.Text_IO.Put (File, UXString_Operations.To_String (Item));
   end Put;

   procedure Put_Line (Item : String_Type) is
   begin
      Ada.Text_IO.Put_Line (UXString_Operations.To_String (Item));
   end Put_Line;

   procedure Put_Line (File : File_Type; Item : String_Type) is
   begin
      Ada.Text_IO.Put_Line (File, UXString_Operations.To_String (Item));
   end Put_Line;

   function Get_Line return String_Type is
   begin
      return UXStrings.From_UTF_8 (Ada.Text_IO.Get_Line);
   end Get_Line;

   function Get_Line (File : File_Type) return String_Type is
   begin
      return UXStrings.From_UTF_8 (Ada.Text_IO.Get_Line (File));
   end Get_Line;

   procedure Get_Line (Item : out String_Type) is
   begin
      Item := Get_Line;
   end Get_Line;

   procedure Get_Line (File : File_Type; Item : out String_Type) is
   begin
      Item := Get_Line (File);
   end Get_Line;

end UXString_Text_IO;
