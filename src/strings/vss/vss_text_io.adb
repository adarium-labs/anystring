-------------------------------------------------------------------------------
--  VSS_Text_IO - Ada.Text_IO bridge for the vss backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Anystrings_Byte_Output;
with Anystrings_UTF_8_Replace;
with Anystrings_UTF_8_Validate;
with VSS_Operations;
with VSS.Strings.Conversions;

package body VSS_Text_IO
  with SPARK_Mode => Off
is

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
      Anystrings_Byte_Output.Put (VSS.Strings.Conversions.To_UTF_8_String (Item));
   end Put;

   procedure Put (File : File_Type; Item : String_Type) is
   begin
      Anystrings_Byte_Output.Put (File, VSS.Strings.Conversions.To_UTF_8_String (Item));
   end Put;

   procedure Put_Line (Item : String_Type) is
   begin
      Anystrings_Byte_Output.Put_Line (VSS.Strings.Conversions.To_UTF_8_String (Item));
   end Put_Line;

   procedure Put_Line (File : File_Type; Item : String_Type) is
   begin
      Anystrings_Byte_Output.Put_Line (File, VSS.Strings.Conversions.To_UTF_8_String (Item));
   end Put_Line;

   --  Code points of a UTF-8 line; an invalid line (VSS raises
   --  Constraint_Error "Ill-formed UTF-8 data") is taken as Latin-1.
   function From_UTF_8 (Line : String) return String_Type is
   begin
      --  A valid line takes the shared decode path (U+FEFF kept, no library
      --  conversion); an invalid line falls through to the Latin-1 reading below.
      if Anystrings_UTF_8_Validate.Validate (Line).Is_Ok then
         return VSS_Operations.From_Wide_Wide_String
           (Anystrings_UTF_8_Replace.Decode_Replacing (Line));
      end if;
      declare
         Result : Wide_Wide_String (Line'Range);
      begin
         for I in Line'Range loop
            Result (I) := Wide_Wide_Character'Val (Character'Pos (Line (I)));
         end loop;
         return VSS.Strings.To_Virtual_String (Result);
      end;
   end From_UTF_8;

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

end VSS_Text_IO;
