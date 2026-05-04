-------------------------------------------------------------------------------
--  Wide_String_Operations - Operations for Wide_Unbounded_String
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Provides operations required for instantiating Strings with
--  Ada.Strings.Wide_Unbounded.Unbounded_Wide_String.

with Ada.Containers;
with Ada.Strings.Wide_Unbounded;

package Wide_String_Operations is

   subtype Unbounded_Wide_String is
     Ada.Strings.Wide_Unbounded.Unbounded_Wide_String;

   Null_Unbounded_Wide_String : constant Unbounded_Wide_String :=
     Ada.Strings.Wide_Unbounded.Null_Unbounded_Wide_String;

   ---------------------------------------------------------------------------
   --  Core Operations
   ---------------------------------------------------------------------------

   function Length (Source : Unbounded_Wide_String) return Natural
     renames Ada.Strings.Wide_Unbounded.Length;

   function Is_Empty (Source : Unbounded_Wide_String) return Boolean
   is (Ada.Strings.Wide_Unbounded.Length (Source) = 0);

   function Element
     (Source : Unbounded_Wide_String;
      Index  : Positive) return Wide_Character
     renames Ada.Strings.Wide_Unbounded.Element;

   function Concat_Strings
     (Left  : Unbounded_Wide_String;
      Right : Unbounded_Wide_String) return Unbounded_Wide_String
     renames Ada.Strings.Wide_Unbounded."&";

   function Concat_String_Character
     (Left  : Unbounded_Wide_String;
      Right : Wide_Character) return Unbounded_Wide_String
     renames Ada.Strings.Wide_Unbounded."&";

   function Concat_Character_String
     (Left  : Wide_Character;
      Right : Unbounded_Wide_String) return Unbounded_Wide_String
     renames Ada.Strings.Wide_Unbounded."&";

   function Concat_String_Latin_1
     (Left  : Unbounded_Wide_String;
      Right : String) return Unbounded_Wide_String;

   function Concat_Latin_1_String
     (Left  : String;
      Right : Unbounded_Wide_String) return Unbounded_Wide_String;

   ---------------------------------------------------------------------------
   --  Comparison Operations
   ---------------------------------------------------------------------------

   function "="
     (Left, Right : Unbounded_Wide_String) return Boolean
     renames Ada.Strings.Wide_Unbounded."=";

   function "<"
     (Left, Right : Unbounded_Wide_String) return Boolean
     renames Ada.Strings.Wide_Unbounded."<";

   function "<="
     (Left, Right : Unbounded_Wide_String) return Boolean
     renames Ada.Strings.Wide_Unbounded."<=";

   function ">"
     (Left, Right : Unbounded_Wide_String) return Boolean
     renames Ada.Strings.Wide_Unbounded.">";

   function ">="
     (Left, Right : Unbounded_Wide_String) return Boolean
     renames Ada.Strings.Wide_Unbounded.">=";

   ---------------------------------------------------------------------------
   --  Conversion Operations
   ---------------------------------------------------------------------------

   function To_Unbounded_Wide_String (Source : String) return Unbounded_Wide_String;

   function To_String (Source : Unbounded_Wide_String) return String;

   ---------------------------------------------------------------------------
   --  Environment Operations
   ---------------------------------------------------------------------------

   function Environment_Value
     (Name    : Unbounded_Wide_String;
      Default : Unbounded_Wide_String) return Unbounded_Wide_String;

   function Environment_Exists
     (Name : Unbounded_Wide_String) return Boolean;

   function Environment_Set
     (Name  : Unbounded_Wide_String;
      Value : Unbounded_Wide_String) return Boolean;

   function Environment_Clear
     (Name : Unbounded_Wide_String) return Boolean;

   function Environment_Clear return Boolean;

   function Environment_Iterate
     (Process : not null access procedure
        (Name  : Unbounded_Wide_String;
         Value : Unbounded_Wide_String)) return Boolean;

   ---------------------------------------------------------------------------
   --  Extended Operations
   ---------------------------------------------------------------------------

   function Hash (Key : Unbounded_Wide_String) return Ada.Containers.Hash_Type;

   function Slice
     (Source : Unbounded_Wide_String;
      Low    : Positive;
      High   : Natural) return Unbounded_Wide_String;

   function Index
     (Source  : Unbounded_Wide_String;
      Pattern : Unbounded_Wide_String) return Natural;

   function Index_Latin_1
     (Source  : Unbounded_Wide_String;
      Pattern : String) return Natural;

   function To_Lower (Source : Unbounded_Wide_String) return Unbounded_Wide_String;
   function To_Upper (Source : Unbounded_Wide_String) return Unbounded_Wide_String;

   function Starts_With
     (Source : Unbounded_Wide_String;
      Prefix : Unbounded_Wide_String) return Boolean;

   function Starts_With_Latin_1
     (Source : Unbounded_Wide_String;
      Prefix : String) return Boolean;

   function Ends_With
     (Source : Unbounded_Wide_String;
      Suffix : Unbounded_Wide_String) return Boolean;

   function Trim (Source : Unbounded_Wide_String) return Unbounded_Wide_String;

   function From_Character (C : Wide_Character) return Unbounded_Wide_String;

end Wide_String_Operations;
