-------------------------------------------------------------------------------
--  String_Types.Environment - environment-variable bridge (bodies)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with UXString_Environment;
with UXStrings;

package body String_Types.Environment with SPARK_Mode => Off is

   function Get_Env (Name : String_Type) return String_Type
   is ((Value => UXString_Environment.Get_Env (Name.Value)));

   function Get_Env (Name : String_Type; Default : String_Type) return String_Type
   is ((Value => UXString_Environment.Get_Env (Name.Value, Default.Value)));

   function Env_Exists (Name : String_Type) return Boolean
   is (UXString_Environment.Env_Exists (Name.Value));

   function Set_Env (Name : String_Type; Value : String_Type) return Boolean
   is (UXString_Environment.Set_Env (Name.Value, Value.Value));

   function Clear_Env (Name : String_Type) return Boolean
   is (UXString_Environment.Clear_Env (Name.Value));

   function Clear_Env return Boolean
   is (UXString_Environment.Clear_Env);

   function Iterate_Env (Process : Env_Processor) return Boolean is
      procedure Adapter (Name : UXStrings.UXString; Value : UXStrings.UXString) is
      begin
         Process.all ((Value => Name), (Value => Value));
      end Adapter;
   begin
      return UXString_Environment.Iterate_Env (Adapter'Access);
   end Iterate_Env;

   function Iterate_Env (Include : Env_Filter; Process : Env_Processor) return Boolean is
      function Adapter_Include (Name : UXStrings.UXString; Value : UXStrings.UXString) return Boolean
      is (Include.all ((Value => Name), (Value => Value)));

      procedure Adapter_Process (Name : UXStrings.UXString; Value : UXStrings.UXString) is
      begin
         Process.all ((Value => Name), (Value => Value));
      end Adapter_Process;
   begin
      return UXString_Environment.Iterate_Env (Adapter_Include'Access, Adapter_Process'Access);
   end Iterate_Env;

end String_Types.Environment;
