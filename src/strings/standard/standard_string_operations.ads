-------------------------------------------------------------------------------
--  Standard_String_Operations - Operations for Unbounded_String
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Provides operations required for instantiating Strings with
--  Ada.Strings.Unbounded.Unbounded_String.
--
--  @description
--  This package wraps Unbounded_String operations to match the signature
--  required by the Strings generic package. Note that we use
--  Unbounded_String instead of Standard.String because String is an
--  unconstrained array type which cannot be used as a generic formal
--  private type.
--
--  For UTF-8 support, string content is assumed to be UTF-8 encoded.
--  Length and Element operate on bytes (Character values), not Unicode
--  code points. For full Unicode support, use the VSS or UXStrings
--  instantiation.

with Ada.Containers;
with Ada.Strings.Unbounded;
with Ada.Strings.Unbounded.Hash;
with Ada.Strings.Fixed;
with Ada.Characters.Handling;

package Standard_String_Operations is

   subtype Unbounded_String is Ada.Strings.Unbounded.Unbounded_String;

   ---------------------------------------------------------------------------
   --  Core Operations (required by Strings signature)
   ---------------------------------------------------------------------------

   --  Empty string constant
   Null_Unbounded_String : constant Unbounded_String := Ada.Strings.Unbounded.Null_Unbounded_String;

   --  Returns the length of the string
   function Length (Source : Unbounded_String) return Natural renames Ada.Strings.Unbounded.Length;

   --  Returns True if the string is empty
   function Is_Empty (Source : Unbounded_String) return Boolean
   is (Ada.Strings.Unbounded.Length (Source) = 0);

   --  Returns the character at position Index (1-indexed)
   function Element (Source : Unbounded_String; Index : Positive) return Character
   renames Ada.Strings.Unbounded.Element;

   --  Concatenation of two strings
   function Concat_Strings (Left : Unbounded_String; Right : Unbounded_String) return Unbounded_String
   renames Ada.Strings.Unbounded."&";

   --  Concatenation of a string and a character
   function Concat_String_Character (Left : Unbounded_String; Right : Character) return Unbounded_String
   renames Ada.Strings.Unbounded."&";

   --  Concatenation of a character and a string
   function Concat_Character_String (Left : Character; Right : Unbounded_String) return Unbounded_String
   renames Ada.Strings.Unbounded."&";

   --  Concatenation of Unbounded_String and Latin-1 String
   function Concat_String_Latin_1 (Left : Unbounded_String; Right : String) return Unbounded_String
   renames Ada.Strings.Unbounded."&";

   --  Concatenation of Latin-1 String and Unbounded_String
   function Concat_Latin_1_String (Left : String; Right : Unbounded_String) return Unbounded_String
   renames Ada.Strings.Unbounded."&";

   --  Comparison operators
   function "=" (Left, Right : Unbounded_String) return Boolean renames Ada.Strings.Unbounded."=";

   function "<" (Left, Right : Unbounded_String) return Boolean renames Ada.Strings.Unbounded."<";

   function "<=" (Left, Right : Unbounded_String) return Boolean renames Ada.Strings.Unbounded."<=";

   function ">" (Left, Right : Unbounded_String) return Boolean renames Ada.Strings.Unbounded.">";

   function ">=" (Left, Right : Unbounded_String) return Boolean renames Ada.Strings.Unbounded.">=";

   ---------------------------------------------------------------------------
   --  Conversion Operations
   ---------------------------------------------------------------------------

   --  Convert from String to Unbounded_String
   function To_Unbounded_String (Source : String) return Unbounded_String
   renames Ada.Strings.Unbounded.To_Unbounded_String;

   --  Convert from Unbounded_String to String
   function To_String (Source : Unbounded_String) return String renames Ada.Strings.Unbounded.To_String;

   ---------------------------------------------------------------------------
   --  Environment Operations
   ---------------------------------------------------------------------------

   function Environment_Value
     (Name    : Unbounded_String;
      Default : Unbounded_String) return Unbounded_String;

   function Environment_Exists
     (Name : Unbounded_String) return Boolean;

   function Environment_Set
     (Name  : Unbounded_String;
      Value : Unbounded_String) return Boolean;

   function Environment_Clear
     (Name : Unbounded_String) return Boolean;

   function Environment_Clear return Boolean;

   function Environment_Iterate
     (Process : not null access procedure
        (Name  : Unbounded_String;
         Value : Unbounded_String)) return Boolean;

   ---------------------------------------------------------------------------
   --  Extended Operations (used by String_Types)
   ---------------------------------------------------------------------------

   --  Hash function for use with hashed containers
   function Hash (Key : Unbounded_String) return Ada.Containers.Hash_Type renames Ada.Strings.Unbounded.Hash;

   --  Slice extraction
   function Slice (Source : Unbounded_String; Low : Positive; High : Natural) return Unbounded_String
   renames Ada.Strings.Unbounded.Unbounded_Slice;

   --  Index/search operations (returns 0 if not found)
   function Index (Source : Unbounded_String; Pattern : Unbounded_String) return Natural;

   function Index_Latin_1 (Source : Unbounded_String; Pattern : String) return Natural;

   --  Case conversion
   function To_Lower (Source : Unbounded_String) return Unbounded_String;
   function To_Upper (Source : Unbounded_String) return Unbounded_String;

   --  Prefix/suffix checking
   function Starts_With (Source : Unbounded_String; Prefix : Unbounded_String) return Boolean;

   function Starts_With_Latin_1 (Source : Unbounded_String; Prefix : String) return Boolean;

   function Ends_With (Source : Unbounded_String; Suffix : Unbounded_String) return Boolean;

   --  Trim whitespace from both ends
   function Trim (Source : Unbounded_String) return Unbounded_String;

   --  Create a single-character string
   function From_Character (C : Character) return Unbounded_String;

end Standard_String_Operations;
