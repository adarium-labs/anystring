-------------------------------------------------------------------------------
--  Anystrings_Internal_Wide_Environment_Encoding - UTF-8 helpers
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Strings.UTF_Encoding;
with Ada.Strings.UTF_Encoding.Wide_Strings;
with Ada.Strings.UTF_Encoding.Wide_Wide_Strings;

package body Anystrings_Internal_Wide_Environment_Encoding is

   function Policy_Name return String is ("utf_8");

   function Can_Encode
     (Source : Ada.Strings.Wide_Unbounded.Unbounded_Wide_String) return Boolean
   is
      pragma Unreferenced (Source);
   begin
      return True;
   end Can_Encode;

   function Encode
     (Source : Ada.Strings.Wide_Unbounded.Unbounded_Wide_String) return String
   is
      use Ada.Strings.Wide_Unbounded;
   begin
      return Ada.Strings.UTF_Encoding.Wide_Strings.Encode
        (Item          => To_Wide_String (Source),
         Output_Scheme => Ada.Strings.UTF_Encoding.UTF_8,
         Output_BOM    => False);
   end Encode;

   function Decode_Wide
     (Source : String) return Ada.Strings.Wide_Unbounded.Unbounded_Wide_String
   is
   begin
      return Ada.Strings.Wide_Unbounded.To_Unbounded_Wide_String
        (Ada.Strings.UTF_Encoding.Wide_Strings.Decode
           (Ada.Strings.UTF_Encoding.UTF_8_String (Source)));
   end Decode_Wide;

   function Can_Encode
     (Source : Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String)
      return Boolean
   is
      pragma Unreferenced (Source);
   begin
      return True;
   end Can_Encode;

   function Encode
     (Source : Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String)
      return String
   is
      use Ada.Strings.Wide_Wide_Unbounded;
   begin
      return Ada.Strings.UTF_Encoding.Wide_Wide_Strings.Encode
        (Item          => To_Wide_Wide_String (Source),
         Output_Scheme => Ada.Strings.UTF_Encoding.UTF_8,
         Output_BOM    => False);
   end Encode;

   function Decode_Wide_Wide
     (Source : String) return Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String
   is
   begin
      return Ada.Strings.Wide_Wide_Unbounded.To_Unbounded_Wide_Wide_String
        (Ada.Strings.UTF_Encoding.Wide_Wide_Strings.Decode
           (Ada.Strings.UTF_Encoding.UTF_8_String (Source)));
   end Decode_Wide_Wide;

end Anystrings_Internal_Wide_Environment_Encoding;
