-------------------------------------------------------------------------------
--  UXString_Text_IO - Ada.Text_IO bridge for the uxstring backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Anystrings_Byte_Output;
with Anystrings_UTF_8_Validate;

package body UXString_Text_IO
  with SPARK_Mode => Off
is

   --  Text on the wire is UTF-8 on every backend (not UXString_Operations.
   --  To_String, which prefers Latin-1 when the value fits).
   function To_UTF_8 (Item : String_Type) return String
   is (String (UXStrings.To_UTF_8 (Item)));

   --  Code points of a UTF-8 line; an invalid line is taken as Latin-1.
   --  UXStrings decodes lazily (a bad sequence only raises Data_Error on a
   --  later access), so the line is validated up front.
   function From_UTF_8 (Line : String) return String_Type
   is (if Anystrings_UTF_8_Validate.Validate (Line).Is_Ok
       then UXStrings.From_UTF_8 (Line)
       else UXStrings.From_Latin_1 (Line));

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

end UXString_Text_IO;
