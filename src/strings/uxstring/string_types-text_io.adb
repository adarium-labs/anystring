-------------------------------------------------------------------------------
--  String_Types.Text_IO - Text_IO bridge (bodies)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with UXString_Wrapper.Convert;

package body String_Types.Text_IO
  with SPARK_Mode => Off
is

   package Conv renames UXString_Wrapper.Convert;

   procedure Put (Item : String_Type) is
   begin
      UXString_Text_IO.Put (Conv.To_UXString (Item));
   end Put;

   procedure Put (File : File_Type; Item : String_Type) is
   begin
      UXString_Text_IO.Put (File, Conv.To_UXString (Item));
   end Put;

   procedure Put_Line (Item : String_Type) is
   begin
      UXString_Text_IO.Put_Line (Conv.To_UXString (Item));
   end Put_Line;

   procedure Put_Line (File : File_Type; Item : String_Type) is
   begin
      UXString_Text_IO.Put_Line (File, Conv.To_UXString (Item));
   end Put_Line;

   function Get_Line return String_Type
   is (Conv.From_UXString (UXString_Text_IO.Get_Line));

   function Get_Line (File : File_Type) return String_Type
   is (Conv.From_UXString (UXString_Text_IO.Get_Line (File)));

   procedure Get_Line (Item : out String_Type) is
   begin
      Item := Get_Line;
   end Get_Line;

   procedure Get_Line (File : File_Type; Item : out String_Type) is
   begin
      Item := Get_Line (File);
   end Get_Line;

end String_Types.Text_IO;
