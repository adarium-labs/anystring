-------------------------------------------------------------------------------
--  Anystrings - Generic String Abstraction
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

package body Anystrings
  with SPARK_Mode => Off
is

   procedure Put (Item : String_Type) is
   begin
      Put_File (Current_Output_File, Item);
   end Put;

   procedure Put_Line (File : File_Type; Item : String_Type) is
   begin
      Put_File (File, Item);
      New_Line_File (File);
   end Put_Line;

   procedure Put_Line (Item : String_Type) is
   begin
      Put_Line (Current_Output_File, Item);
   end Put_Line;

   function Get_Line return String_Type is
   begin
      return Get_Line_File (Current_Input_File);
   end Get_Line;

   procedure Get_Line (File : File_Type; Item : out String_Type) is
   begin
      Item := Get_Line_File (File);
   end Get_Line;

   procedure Get_Line (Item : out String_Type) is
   begin
      Item := Get_Line;
   end Get_Line;

   procedure New_Line is
   begin
      New_Line_File (Current_Output_File);
   end New_Line;

   function End_Of_File return Boolean is
   begin
      return End_Of_File_File (Current_Input_File);
   end End_Of_File;

   function Iterate_Env (Process : Env_Processor) return Boolean is
      procedure Process_Item (Name : String_Type; Value : String_Type) is
      begin
         Process.all (Name, Value);
      end Process_Item;
   begin
      return Environment_Iterate (Process_Item'Access);
   exception
      when others =>
         return False;
   end Iterate_Env;

   function Iterate_Env (Include : Env_Filter; Process : Env_Processor) return Boolean is
      procedure Process_Item (Name : String_Type; Value : String_Type) is
      begin
         if Include.all (Name, Value) then
            Process.all (Name, Value);
         end if;
      end Process_Item;
   begin
      return Environment_Iterate (Process_Item'Access);
   exception
      when others =>
         return False;
   end Iterate_Env;

end Anystrings;
