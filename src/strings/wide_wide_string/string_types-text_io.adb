-------------------------------------------------------------------------------
--  String_Types.Text_IO - Text_IO bridge (bodies)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Bodies of the Text_IO wrappers: unwrap the String_Type operands, call the
--  Wide_Wide_Text_IO implementation, wrap the results.
--
--  @description
--  Get_Line reads through Wide_Wide_Text_IO, whose result is sanitised on the
--  way in (valid lines take the shared decode path; invalid lines fall back
--  to Latin-1, whose code points are all scalars). The result is then wrapped.

with String_Empty_Value.Convert;

package body String_Types.Text_IO with SPARK_Mode => Off is

   package Conv renames String_Empty_Value.Convert;

   procedure Put (Item : String_Type) is
   begin
      Wide_Wide_Text_IO.Put (Conv.To_Unbounded (Item));
   end Put;

   procedure Put (File : File_Type; Item : String_Type) is
   begin
      Wide_Wide_Text_IO.Put (File, Conv.To_Unbounded (Item));
   end Put;

   procedure Put_Line (Item : String_Type) is
   begin
      Wide_Wide_Text_IO.Put_Line (Conv.To_Unbounded (Item));
   end Put_Line;

   procedure Put_Line (File : File_Type; Item : String_Type) is
   begin
      Wide_Wide_Text_IO.Put_Line (File, Conv.To_Unbounded (Item));
   end Put_Line;

   function Get_Line return String_Type
   is (Conv.From_Unbounded (Wide_Wide_Text_IO.Get_Line));

   function Get_Line (File : File_Type) return String_Type
   is (Conv.From_Unbounded (Wide_Wide_Text_IO.Get_Line (File)));

   procedure Get_Line (Item : out String_Type) is
      Raw : Wide_Wide_Text_IO.String_Type;
   begin
      Wide_Wide_Text_IO.Get_Line (Raw);
      Item := Conv.From_Unbounded (Raw);
   end Get_Line;

   procedure Get_Line (File : File_Type; Item : out String_Type) is
      Raw : Wide_Wide_Text_IO.String_Type;
   begin
      Wide_Wide_Text_IO.Get_Line (File, Raw);
      Item := Conv.From_Unbounded (Raw);
   end Get_Line;

end String_Types.Text_IO;
