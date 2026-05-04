-------------------------------------------------------------------------------
--  Anystrings - Generic String Abstraction
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

package body Anystrings with SPARK_Mode => Off is

   function Iterate_Env (Process : Env_Processor) return Boolean is
      procedure Process_Item
        (Name  : String_Type;
         Value : String_Type)
      is
      begin
         Process.all (Name, Value);
      end Process_Item;
   begin
      return Environment_Iterate (Process_Item'Access);
   exception
      when others =>
         return False;
   end Iterate_Env;

   function Iterate_Env
     (Include : Env_Filter;
      Process : Env_Processor) return Boolean
   is
      procedure Process_Item
        (Name  : String_Type;
         Value : String_Type)
      is
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
