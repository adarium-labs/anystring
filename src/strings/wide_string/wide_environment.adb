-------------------------------------------------------------------------------
--  Wide_Environment - Environment-variable bridge for the wide_string backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Environment_Variables;
with Ada.Strings.Wide_Unbounded;
with Anystrings_Internal_Wide_Environment_Encoding;

package body Wide_Environment with SPARK_Mode => Off is

   Null_String : constant String_Type :=
     Ada.Strings.Wide_Unbounded.Null_Unbounded_Wide_String;

   function Get_Env (Name : String_Type) return String_Type is
   begin
      if not Anystrings_Internal_Wide_Environment_Encoding.Can_Encode (Name) then
         return Null_String;
      end if;

      declare
         Encoded_Name : constant String :=
           Anystrings_Internal_Wide_Environment_Encoding.Encode (Name);
      begin
         if Ada.Environment_Variables.Exists (Encoded_Name) then
            return Anystrings_Internal_Wide_Environment_Encoding.Decode_Wide
                     (Ada.Environment_Variables.Value (Encoded_Name));
         else
            return Null_String;
         end if;
      end;
   exception
      when others =>
         return Null_String;
   end Get_Env;

   function Get_Env (Name : String_Type; Default : String_Type) return String_Type is
   begin
      if not Anystrings_Internal_Wide_Environment_Encoding.Can_Encode (Name) then
         return Default;
      end if;

      declare
         Encoded_Name : constant String :=
           Anystrings_Internal_Wide_Environment_Encoding.Encode (Name);
      begin
         if Ada.Environment_Variables.Exists (Encoded_Name) then
            return Anystrings_Internal_Wide_Environment_Encoding.Decode_Wide
                     (Ada.Environment_Variables.Value (Encoded_Name));
         else
            return Default;
         end if;
      end;
   exception
      when others =>
         return Default;
   end Get_Env;

   function Env_Exists (Name : String_Type) return Boolean is
   begin
      if not Anystrings_Internal_Wide_Environment_Encoding.Can_Encode (Name) then
         return False;
      end if;
      return Ada.Environment_Variables.Exists
               (Anystrings_Internal_Wide_Environment_Encoding.Encode (Name));
   exception
      when others =>
         return False;
   end Env_Exists;

   function Set_Env (Name : String_Type; Value : String_Type) return Boolean is
   begin
      if not Anystrings_Internal_Wide_Environment_Encoding.Can_Encode (Name)
        or else not Anystrings_Internal_Wide_Environment_Encoding.Can_Encode (Value)
      then
         return False;
      end if;
      Ada.Environment_Variables.Set
        (Anystrings_Internal_Wide_Environment_Encoding.Encode (Name),
         Anystrings_Internal_Wide_Environment_Encoding.Encode (Value));
      return True;
   exception
      when others =>
         return False;
   end Set_Env;

   function Clear_Env (Name : String_Type) return Boolean is
   begin
      if not Anystrings_Internal_Wide_Environment_Encoding.Can_Encode (Name) then
         return False;
      end if;
      Ada.Environment_Variables.Clear
        (Anystrings_Internal_Wide_Environment_Encoding.Encode (Name));
      return True;
   exception
      when others =>
         return False;
   end Clear_Env;

   function Clear_Env return Boolean is
   begin
      Ada.Environment_Variables.Clear;
      return True;
   exception
      when others =>
         return False;
   end Clear_Env;

   function Iterate_Env (Process : Env_Processor) return Boolean is
      Ok : Boolean := True;

      procedure Process_Item (Name, Value : String) is
      begin
         begin
            declare
               N : constant String_Type :=
                 Anystrings_Internal_Wide_Environment_Encoding.Decode_Wide (Name);
               V : constant String_Type :=
                 Anystrings_Internal_Wide_Environment_Encoding.Decode_Wide (Value);
            begin
               begin
                  Process.all (N, V);
               exception
                  when others => Ok := False;
               end;
            end;
         exception
            when others => null;
         end;
      end Process_Item;
   begin
      Ada.Environment_Variables.Iterate (Process_Item'Access);
      return Ok;
   exception
      when others =>
         return False;
   end Iterate_Env;

   function Iterate_Env (Include : Env_Filter; Process : Env_Processor) return Boolean is
      Ok : Boolean := True;

      procedure Process_Item (Name, Value : String) is
      begin
         begin
            declare
               N : constant String_Type :=
                 Anystrings_Internal_Wide_Environment_Encoding.Decode_Wide (Name);
               V : constant String_Type :=
                 Anystrings_Internal_Wide_Environment_Encoding.Decode_Wide (Value);
            begin
               if Include.all (N, V) then
                  Process.all (N, V);
               end if;
            exception
               when others => Ok := False;
            end;
         exception
            when others => null;
         end;
      end Process_Item;
   begin
      Ada.Environment_Variables.Iterate (Process_Item'Access);
      return Ok;
   exception
      when others =>
         return False;
   end Iterate_Env;

end Wide_Environment;
