-------------------------------------------------------------------------------
--  String_Types.Environment - environment-variable bridge
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Child package of String_Types exposing the Ada.Environment_Variables bridge.
--
--  @description
--  Thin wrappers over the per-backend UXString_Environment implementation
--  package (String_Type is a private wrapper on this backend, so the
--  subprograms cannot be plain renames). Consumers opt in to the
--  environment-variable API with `with String_Types.Environment;` without
--  forcing Ada.Environment_Variables into the dependency closure of every
--  `with String_Types;`.
--
--  Public surface is identical across all five backends
--  (FUNC-FACADE-003), only the implementation differs.
--
--  @relation FUNC-FACADE-002, FUNC-FACADE-003, FUNC-FACADE-007, NFR-FACADE-002

package String_Types.Environment
  with SPARK_Mode => Off
is

   type Env_Processor is not null access procedure (Name : String_Type; Value : String_Type);

   type Env_Filter is not null access function (Name : String_Type; Value : String_Type) return Boolean;

   function Get_Env (Name : String_Type) return String_Type;

   function Get_Env (Name : String_Type; Default : String_Type) return String_Type;

   function Env_Exists (Name : String_Type) return Boolean;

   function Set_Env (Name : String_Type; Value : String_Type) return Boolean;

   function Clear_Env (Name : String_Type) return Boolean;

   function Clear_Env return Boolean;

   function Iterate_Env (Process : Env_Processor) return Boolean;

   function Iterate_Env (Include : Env_Filter; Process : Env_Processor) return Boolean;

end String_Types.Environment;
