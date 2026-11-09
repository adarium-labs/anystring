-------------------------------------------------------------------------------
--  UXString_Environment - Environment-variable bridge for the uxstring backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Stand-alone Ada.Environment_Variables bridge for the uxstring
--  (UXStrings.UXString) backend. Spec SPARK_Mode On; body SPARK_Mode Off.
--
--  @relation FUNC-FACADE-007, NFR-FACADE-002

with UXStrings;

package UXString_Environment
  with SPARK_Mode => Off
is

   subtype String_Type is UXStrings.UXString;

   --  Callbacks are anonymous access parameters so that callers can pass
   --  nested subprograms (String_Types.Environment adapts its own callbacks).

   function Get_Env (Name : String_Type) return String_Type;
   function Get_Env (Name : String_Type; Default : String_Type) return String_Type;
   function Env_Exists (Name : String_Type) return Boolean;
   function Set_Env (Name : String_Type; Value : String_Type) return Boolean;
   function Clear_Env (Name : String_Type) return Boolean;
   function Clear_Env return Boolean;
   function Iterate_Env (Process : not null access procedure (Name : String_Type; Value : String_Type)) return Boolean;
   function Iterate_Env
     (Include : not null access function (Name : String_Type; Value : String_Type) return Boolean;
      Process : not null access procedure (Name : String_Type; Value : String_Type)) return Boolean;

end UXString_Environment;
