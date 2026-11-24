-------------------------------------------------------------------------------
--  String_Types.Environment - environment-variable bridge (bodies)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Bodies of the environment wrappers. The callbacks given by the caller take
--  String_Type values; the implementation calls back with unbounded values.
--  The adapters below are nested in the entry point, so they can reach the
--  caller's callback without a global.

package body String_Types.Environment with SPARK_Mode => Off is

   function Get_Env (Name : String_Type) return String_Type
   is (Wrap (Wide_Wide_Environment.Get_Env (Unwrap (Name))));

   function Get_Env (Name : String_Type; Default : String_Type) return String_Type
   is (Wrap
         (Wide_Wide_Environment.Get_Env (Unwrap (Name), Unwrap (Default))));

   function Env_Exists (Name : String_Type) return Boolean
   is (Wide_Wide_Environment.Env_Exists (Unwrap (Name)));

   function Set_Env (Name : String_Type; Value : String_Type) return Boolean
   is (Wide_Wide_Environment.Set_Env (Unwrap (Name), Unwrap (Value)));

   function Clear_Env (Name : String_Type) return Boolean
   is (Wide_Wide_Environment.Clear_Env (Unwrap (Name)));

   function Iterate_Env (Process : Env_Processor) return Boolean is
      procedure Process_Adapter
        (Name  : Wide_Wide_Environment.String_Type;
         Value : Wide_Wide_Environment.String_Type) is
      begin
         Process.all (Wrap (Name), Wrap (Value));
      end Process_Adapter;
   begin
      return Wide_Wide_Environment.Iterate_Env (Process_Adapter'Access);
   end Iterate_Env;

   function Iterate_Env (Include : Env_Filter; Process : Env_Processor) return Boolean is
      function Filter_Adapter
        (Name  : Wide_Wide_Environment.String_Type;
         Value : Wide_Wide_Environment.String_Type) return Boolean
      is (Include.all (Wrap (Name), Wrap (Value)));

      procedure Process_Adapter
        (Name  : Wide_Wide_Environment.String_Type;
         Value : Wide_Wide_Environment.String_Type) is
      begin
         Process.all (Wrap (Name), Wrap (Value));
      end Process_Adapter;
   begin
      return Wide_Wide_Environment.Iterate_Env
               (Include => Filter_Adapter'Access, Process => Process_Adapter'Access);
   end Iterate_Env;

end String_Types.Environment;
