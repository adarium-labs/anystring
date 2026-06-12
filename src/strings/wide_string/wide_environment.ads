-------------------------------------------------------------------------------
--  Wide_Environment - Environment-variable bridge for the wide_string backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Stand-alone Ada.Environment_Variables bridge for the wide_string
--  (Unbounded_Wide_String) backend. Spec SPARK_Mode On; body SPARK_Mode Off.
--
--  @description
--  The body preserves the build-time selectable encoder
--  Anystrings_Internal_Wide_Environment_Encoding (ANYSTRING_WIDE_ENV_ENCODING)
--  used for ingress/egress of environment-variable names and values.
--
--  @relation FUNC-FACADE-007, NFR-FACADE-002

with Ada.Strings.Wide_Unbounded;

package Wide_Environment with SPARK_Mode is

   subtype String_Type is Ada.Strings.Wide_Unbounded.Unbounded_Wide_String;

   type Env_Processor is not null access procedure
     (Name : String_Type; Value : String_Type);

   type Env_Filter is not null access function
     (Name : String_Type; Value : String_Type) return Boolean;

   function Get_Env (Name : String_Type) return String_Type;
   function Get_Env (Name : String_Type; Default : String_Type) return String_Type;
   function Env_Exists (Name : String_Type) return Boolean;
   function Set_Env (Name : String_Type; Value : String_Type) return Boolean;
   function Clear_Env (Name : String_Type) return Boolean;
   function Clear_Env return Boolean;
   function Iterate_Env (Process : Env_Processor) return Boolean;
   function Iterate_Env (Include : Env_Filter; Process : Env_Processor) return Boolean;

end Wide_Environment;
