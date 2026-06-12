-------------------------------------------------------------------------------
--  String_Types.Environment - environment-variable bridge re-exports
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Child package of String_Types exposing the Ada.Environment_Variables bridge.
--
--  @description
--  Pure renames of the per-backend Wide_Environment implementation
--  package, so that consumers can opt in to the environment-variable API
--  with `with String_Types.Environment;` without forcing
--  Ada.Environment_Variables into the dependency closure of every
--  `with String_Types;`.
--
--  Public surface is identical across all five backends
--  (FUNC-FACADE-003), only the rename targets differ.
--
--  @relation FUNC-FACADE-002, FUNC-FACADE-003, FUNC-FACADE-007, NFR-FACADE-002

with Wide_Environment;

package String_Types.Environment with SPARK_Mode is

   subtype Env_Processor is Wide_Environment.Env_Processor;
   subtype Env_Filter    is Wide_Environment.Env_Filter;

   function Get_Env (Name : String_Type) return String_Type
     renames Wide_Environment.Get_Env;

   function Get_Env (Name : String_Type; Default : String_Type) return String_Type
     renames Wide_Environment.Get_Env;

   function Env_Exists (Name : String_Type) return Boolean
     renames Wide_Environment.Env_Exists;

   function Set_Env (Name : String_Type; Value : String_Type) return Boolean
     renames Wide_Environment.Set_Env;

   function Clear_Env (Name : String_Type) return Boolean
     renames Wide_Environment.Clear_Env;

   function Clear_Env return Boolean
     renames Wide_Environment.Clear_Env;

   function Iterate_Env (Process : Env_Processor) return Boolean
     renames Wide_Environment.Iterate_Env;

   function Iterate_Env (Include : Env_Filter; Process : Env_Processor) return Boolean
     renames Wide_Environment.Iterate_Env;

end String_Types.Environment;
