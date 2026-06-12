-------------------------------------------------------------------------------
--  UXString_Environment - Environment-variable bridge for the uxstring backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Environment_Variables;
with UXStrings; use UXStrings;

package body UXString_Environment with SPARK_Mode => Off is

   Null_String : constant String_Type := UXStrings.Null_UXString;

   --  Egress: try Latin-1, fall back to UTF-8. Matches the local helper
   --  previously hosted in uxstring_operations.adb.
   function To_OS_String (Source : String_Type) return String is
   begin
      return UXStrings.To_Latin_1 (Source);
   exception
      when others =>
         return String (UXStrings.To_UTF_8 (Source));
   end To_OS_String;

   --  Ingress: OS bytes are interpreted as UTF-8.
   function From_OS_String (Source : String) return String_Type is
   begin
      return UXStrings.From_UTF_8 (Source);
   exception
      when others =>
         return Null_String;
   end From_OS_String;

   function Get_Env (Name : String_Type) return String_Type is
      Encoded_Name : constant String := To_OS_String (Name);
   begin
      if Ada.Environment_Variables.Exists (Encoded_Name) then
         return From_OS_String (Ada.Environment_Variables.Value (Encoded_Name));
      else
         return Null_String;
      end if;
   exception
      when others =>
         return Null_String;
   end Get_Env;

   function Get_Env (Name : String_Type; Default : String_Type) return String_Type is
      Encoded_Name : constant String := To_OS_String (Name);
   begin
      if Ada.Environment_Variables.Exists (Encoded_Name) then
         return From_OS_String (Ada.Environment_Variables.Value (Encoded_Name));
      else
         return Default;
      end if;
   exception
      when others =>
         return Default;
   end Get_Env;

   function Env_Exists (Name : String_Type) return Boolean is
   begin
      return Ada.Environment_Variables.Exists (To_OS_String (Name));
   exception
      when others =>
         return False;
   end Env_Exists;

   function Set_Env (Name : String_Type; Value : String_Type) return Boolean is
   begin
      Ada.Environment_Variables.Set (To_OS_String (Name), To_OS_String (Value));
      return True;
   exception
      when others =>
         return False;
   end Set_Env;

   function Clear_Env (Name : String_Type) return Boolean is
   begin
      Ada.Environment_Variables.Clear (To_OS_String (Name));
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
            Process.all (From_OS_String (Name), From_OS_String (Value));
         exception
            when others => Ok := False;
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
         declare
            N : constant String_Type := From_OS_String (Name);
            V : constant String_Type := From_OS_String (Value);
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
      when others =>
         return False;
   end Iterate_Env;

end UXString_Environment;
