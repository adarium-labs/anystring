-------------------------------------------------------------------------------
--  Anystrings_Internal_Wide_Environment_Encoding - Latin-1 helpers
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

package body Anystrings_Internal_Wide_Environment_Encoding is

   function Policy_Name return String is ("latin_1");

   function Can_Encode
     (Source : Ada.Strings.Wide_Unbounded.Unbounded_Wide_String) return Boolean
   is
      use Ada.Strings.Wide_Unbounded;
      Value : constant Wide_String := To_Wide_String (Source);
   begin
      for C of Value loop
         if Wide_Character'Pos (C) > 255 then
            return False;
         end if;
      end loop;

      return True;
   end Can_Encode;

   function To_Wide_String (Source : String) return Wide_String is
      Result : Wide_String (Source'Range);
   begin
      for I in Source'Range loop
         Result (I) := Wide_Character'Val (Character'Pos (Source (I)));
      end loop;
      return Result;
   end To_Wide_String;

   function To_String (Source : Wide_String) return String is
      Result : String (Source'Range);
   begin
      for I in Source'Range loop
         if Wide_Character'Pos (Source (I)) > 255 then
            raise Constraint_Error with "Wide character not representable in Latin-1 environment encoding";
         end if;

         Result (I) := Character'Val (Wide_Character'Pos (Source (I)));
      end loop;
      return Result;
   end To_String;

   function Can_Encode
     (Source : Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String)
      return Boolean
   is
      use Ada.Strings.Wide_Wide_Unbounded;
      Value : constant Wide_Wide_String := To_Wide_Wide_String (Source);
   begin
      for C of Value loop
         if Wide_Wide_Character'Pos (C) > 255 then
            return False;
         end if;
      end loop;

      return True;
   end Can_Encode;

   function To_Wide_Wide_String (Source : String) return Wide_Wide_String is
      Result : Wide_Wide_String (Source'Range);
   begin
      for I in Source'Range loop
         Result (I) := Wide_Wide_Character'Val (Character'Pos (Source (I)));
      end loop;
      return Result;
   end To_Wide_Wide_String;

   function To_String (Source : Wide_Wide_String) return String is
      Result : String (Source'Range);
   begin
      for I in Source'Range loop
         if Wide_Wide_Character'Pos (Source (I)) > 255 then
            raise Constraint_Error with "Wide_Wide character not representable in Latin-1 environment encoding";
         end if;

         Result (I) := Character'Val (Wide_Wide_Character'Pos (Source (I)));
      end loop;
      return Result;
   end To_String;

   function Encode
     (Source : Ada.Strings.Wide_Unbounded.Unbounded_Wide_String) return String
   is
      use Ada.Strings.Wide_Unbounded;
   begin
      return To_String (To_Wide_String (Source));
   end Encode;

   function Decode_Wide
     (Source : String) return Ada.Strings.Wide_Unbounded.Unbounded_Wide_String
   is
   begin
      return Ada.Strings.Wide_Unbounded.To_Unbounded_Wide_String
        (To_Wide_String (Source));
   end Decode_Wide;

   function Encode
     (Source : Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String)
      return String
   is
      use Ada.Strings.Wide_Wide_Unbounded;
   begin
      return To_String (To_Wide_Wide_String (Source));
   end Encode;

   function Decode_Wide_Wide
     (Source : String) return Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String
   is
   begin
      return Ada.Strings.Wide_Wide_Unbounded.To_Unbounded_Wide_Wide_String
        (To_Wide_Wide_String (Source));
   end Decode_Wide_Wide;

end Anystrings_Internal_Wide_Environment_Encoding;
