-------------------------------------------------------------------------------
--  Standard_Environment - Environment-variable bridge for the standard backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Environment_Variables;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package body Standard_Environment with SPARK_Mode => Off is

   function Get_Env (Name : String_Type) return String_Type is
   begin
      if Ada.Environment_Variables.Exists (To_String (Name)) then
         return To_Unbounded_String
                  (Ada.Environment_Variables.Value (To_String (Name)));
      else
         return Null_Unbounded_String;
      end if;
   exception
      when others =>
         return Null_Unbounded_String;
   end Get_Env;

   function Get_Env (Name : String_Type; Default : String_Type) return String_Type is
   begin
      if Ada.Environment_Variables.Exists (To_String (Name)) then
         return To_Unbounded_String
                  (Ada.Environment_Variables.Value (To_String (Name)));
      else
         return Default;
      end if;
   exception
      when others =>
         return Default;
   end Get_Env;

   function Env_Exists (Name : String_Type) return Boolean is
   begin
      return Ada.Environment_Variables.Exists (To_String (Name));
   exception
      when others =>
         return False;
   end Env_Exists;

   function Set_Env (Name : String_Type; Value : String_Type) return Boolean is
   begin
      Ada.Environment_Variables.Set (To_String (Name), To_String (Value));
      return True;
   exception
      when others => return False;
   end Set_Env;

   function Clear_Env (Name : String_Type) return Boolean is
   begin
      Ada.Environment_Variables.Clear (To_String (Name));
      return True;
   exception
      when others => return False;
   end Clear_Env;

   function Clear_Env return Boolean is
   begin
      Ada.Environment_Variables.Clear;
      return True;
   exception
      when others => return False;
   end Clear_Env;

   function Iterate_Env (Process : Env_Processor) return Boolean is
      Ok : Boolean := True;
      procedure Process_Item (Name, Value : String) is
      begin
         begin
            Process.all (To_Unbounded_String (Name), To_Unbounded_String (Value));
         exception
            when others => Ok := False;
         end;
      end Process_Item;
   begin
      Ada.Environment_Variables.Iterate (Process_Item'Access);
      return Ok;
   exception
      when others => return False;
   end Iterate_Env;

   function Iterate_Env (Include : Env_Filter; Process : Env_Processor) return Boolean is
      Ok : Boolean := True;
      procedure Process_Item (Name, Value : String) is
      begin
         declare
            N : constant String_Type := To_Unbounded_String (Name);
            V : constant String_Type := To_Unbounded_String (Value);
         begin
            if Include.all (N, V) then
               Process.all (N, V);
            end if;
         exception
            when others => Ok := False;
         end;
      end Process_Item;
   begin
      Ada.Environment_Variables.Iterate (Process_Item'Access);
      return Ok;
   exception
      when others => return False;
   end Iterate_Env;

end Standard_Environment;
