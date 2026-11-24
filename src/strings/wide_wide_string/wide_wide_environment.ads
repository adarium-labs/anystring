-------------------------------------------------------------------------------
--  Wide_Wide_Environment - Environment-variable bridge for wide_wide backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Stand-alone Ada.Environment_Variables bridge for the wide_wide_string
--  (Unbounded_Wide_Wide_String) backend. Spec SPARK_Mode On; body SPARK_Mode Off.
--
--  @description
--  The body preserves the build-time selectable encoder
--  Anystrings_Internal_Wide_Environment_Encoding (ANYSTRING_WIDE_ENV_ENCODING).
--
--  @relation FUNC-FACADE-007, NFR-FACADE-002

with Ada.Strings.Wide_Wide_Unbounded;

package Wide_Wide_Environment with SPARK_Mode is

   subtype String_Type is Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String;

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
   --  Anonymous access formals, not Env_Processor / Env_Filter: a caller may
   --  pass an adapter nested in its own body (a deeper accessibility level
   --  than a library-level named access type), as Ada.Environment_Variables
   --  allows for its own Iterate.
   function Iterate_Env
     (Process : not null access procedure (Name : String_Type; Value : String_Type)) return Boolean;

   function Iterate_Env
     (Include : not null access function (Name : String_Type; Value : String_Type) return Boolean;
      Process : not null access procedure (Name : String_Type; Value : String_Type)) return Boolean;

end Wide_Wide_Environment;
