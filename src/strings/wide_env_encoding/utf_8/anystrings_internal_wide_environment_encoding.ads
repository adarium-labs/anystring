-------------------------------------------------------------------------------
--  Anystrings_Internal_Wide_Environment_Encoding - UTF-8 helpers
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Strings.Wide_Unbounded;
with Ada.Strings.Wide_Wide_Unbounded;

package Anystrings_Internal_Wide_Environment_Encoding is

   function Policy_Name return String;

   function Can_Encode
     (Source : Ada.Strings.Wide_Unbounded.Unbounded_Wide_String) return Boolean;

   function Encode
     (Source : Ada.Strings.Wide_Unbounded.Unbounded_Wide_String) return String;

   function Decode_Wide
     (Source : String) return Ada.Strings.Wide_Unbounded.Unbounded_Wide_String;

   function Can_Encode
     (Source : Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String)
      return Boolean;

   function Encode
     (Source : Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String)
      return String;

   function Decode_Wide_Wide
     (Source : String) return Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String;

end Anystrings_Internal_Wide_Environment_Encoding;
