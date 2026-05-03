-------------------------------------------------------------------------------
--  Anystrings - Generic String Abstraction
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Generic signature package defining abstract string operations.
--
--  @description
--  This package defines a signature (interface) that can be implemented
--  by various string types including:
--    - Ada.Strings.Unbounded.Unbounded_String
--    - Wide_String / Wide_Wide_String wrappers
--    - VSS.Strings.Virtual_String
--    - UXStrings.UXString
--
--  The signature is designed to be SPARK compatible at Silver level.
--  Users instantiate this generic with their preferred string type by
--  providing the required formal parameters (types and operations).

with Ada.Containers;

generic
   --  The string type being abstracted
   type String_Type is private;

   --  The character type used by this string type
   type Character_Type is(<>);

   --  Empty string constant
   Null_String : String_Type;

   ---------------------------------------------------------------------------
   --  Core Operations (required for basic string manipulation)
   ---------------------------------------------------------------------------

   --  Returns the length (number of characters) of the string
   with function Length (Source : String_Type) return Natural;

   --  Returns True if the string is empty
   with function Is_Empty (Source : String_Type) return Boolean;

   --  Returns the character at the given position (1-indexed)
   with function Element (Source : String_Type; Index : Positive) return Character_Type;

   --  Concatenation of two strings
   with function Concat_Strings (Left : String_Type; Right : String_Type) return String_Type;

   --  Concatenation of a string and a character
   with function Concat_String_Character (Left : String_Type; Right : Character_Type) return String_Type;

   --  Concatenation of a character and a string
   with function Concat_Character_String (Left : Character_Type; Right : String_Type) return String_Type;

   ---------------------------------------------------------------------------
   --  Comparison Operations
   ---------------------------------------------------------------------------

   --  Equality comparison
   with function "=" (Left, Right : String_Type) return Boolean is <>;

   --  Less-than comparison
   with function "<" (Left, Right : String_Type) return Boolean is <>;

   --  Less-than-or-equal comparison
   with function "<=" (Left, Right : String_Type) return Boolean is <>;

   --  Greater-than comparison
   with function ">" (Left, Right : String_Type) return Boolean is <>;

   --  Greater-than-or-equal comparison
   with function ">=" (Left, Right : String_Type) return Boolean is <>;

   ---------------------------------------------------------------------------
   --  Conversion Operations (to/from Latin-1 String)
   ---------------------------------------------------------------------------

   --  Convert from Latin-1 String to String_Type
   with function To_String_Type (Source : String) return String_Type;

   --  Convert from String_Type to Latin-1 String
   with function To_Latin_1 (Source : String_Type) return String;

   ---------------------------------------------------------------------------
   --  Extended Operations (required by the framework)
   ---------------------------------------------------------------------------

   --  Hash function for use with hashed containers
   with function Hash (Key : String_Type) return Ada.Containers.Hash_Type;

   --  Slice extraction (returns substring from Low to High, inclusive)
   with function Slice (Source : String_Type; Low : Positive; High : Natural) return String_Type;

   --  Index/search operations (returns 0 if not found)
   with function Index (Source : String_Type; Pattern : String_Type) return Natural;

   --  Index with Latin-1 pattern
   with function Index_Latin_1 (Source : String_Type; Pattern : String) return Natural;

   --  Case conversion
   with function To_Lower (Source : String_Type) return String_Type;
   with function To_Upper (Source : String_Type) return String_Type;

   --  Prefix/suffix checking
   with function Starts_With (Source : String_Type; Prefix : String_Type) return Boolean;

   with function Starts_With_Latin_1 (Source : String_Type; Prefix : String) return Boolean;

   with function Ends_With (Source : String_Type; Suffix : String_Type) return Boolean;

   --  Trim whitespace from both ends
   with function Trim (Source : String_Type) return String_Type;

   --  Create a single-character string
   with function From_Character (C : Character_Type) return String_Type;

   ---------------------------------------------------------------------------
   --  Concatenation with Latin-1 String
   ---------------------------------------------------------------------------

   --  Concatenation of String_Type and Latin-1 String
   with function Concat_String_Latin_1 (Left : String_Type; Right : String) return String_Type;

   --  Concatenation of Latin-1 String and String_Type
   with function Concat_Latin_1_String (Left : String; Right : String_Type) return String_Type;

package Anystrings with SPARK_Mode
is

   ---------------------------------------------------------------------------
   --  Constants
   ---------------------------------------------------------------------------

   --  Empty string constant
   Empty_String : constant String_Type := Null_String;

   ---------------------------------------------------------------------------
   --  Query Operations
   ---------------------------------------------------------------------------

   --  Returns the length of the string
   function Get_Length (Source : String_Type) return Natural
   is (Length (Source))
   with Post => Get_Length'Result = Length (Source);

   --  Returns True if the string is empty (null or zero-length)
   function Is_Null_Or_Empty (Source : String_Type) return Boolean
   is (Is_Empty (Source))
   with Post => Is_Null_Or_Empty'Result = Is_Empty (Source);

   --  Returns the character at the given position
   function Get_Element (Source : String_Type; Index : Positive) return Character_Type
   is (Element (Source, Index))
   with Pre => Index <= Length (Source) and then not Is_Empty (Source);

   --  Returns the first valid index (always 1 for non-empty strings)
   function First_Index (Source : String_Type) return Positive
   is (1)
   with Pre => not Is_Empty (Source);

   --  Returns the last valid index (equals Length for non-empty strings)
   function Last_Index (Source : String_Type) return Natural
   is (Length (Source));

   ---------------------------------------------------------------------------
   --  Concatenation Operations
   ---------------------------------------------------------------------------

   --  Concatenates two strings
   function Concat (Left : String_Type; Right : String_Type) return String_Type
   is (Concat_Strings (Left, Right));

   --  Appends a character to a string
   function Append_Character (Left : String_Type; Right : Character_Type) return String_Type
   is (Concat_String_Character (Left, Right));

   --  Prepends a character to a string
   function Prepend_Character (Left : Character_Type; Right : String_Type) return String_Type
   is (Concat_Character_String (Left, Right));

   ---------------------------------------------------------------------------
   --  Comparison Operations
   ---------------------------------------------------------------------------

   --  Returns True if strings are equal
   function Equal (Left, Right : String_Type) return Boolean
   is ("=" (Left, Right));

   --  Returns True if Left is less than Right
   function Less_Than (Left, Right : String_Type) return Boolean
   is ("<" (Left, Right));

   --  Returns True if Left is less than or equal to Right
   function Less_Or_Equal (Left, Right : String_Type) return Boolean
   is ("<=" (Left, Right));

   --  Returns True if Left is greater than Right
   function Greater_Than (Left, Right : String_Type) return Boolean
   is (">" (Left, Right));

   --  Returns True if Left is greater than or equal to Right
   function Greater_Or_Equal (Left, Right : String_Type) return Boolean
   is (">=" (Left, Right));

   ---------------------------------------------------------------------------
   --  Conversion Operations
   ---------------------------------------------------------------------------

   --  Convert from Latin-1 String to String_Type
   function From_Latin_1 (Source : String) return String_Type
   is (To_String_Type (Source));

   --  Convert String_Type to Latin-1 String
   function As_Latin_1 (Source : String_Type) return String
   is (To_Latin_1 (Source));

   ---------------------------------------------------------------------------
   --  Extended String Operations
   ---------------------------------------------------------------------------

   --  Hash function for containers
   function Get_Hash (Key : String_Type) return Ada.Containers.Hash_Type
   is (Hash (Key));

   --  Slice extraction
   function Get_Slice (Source : String_Type; Low : Positive; High : Natural) return String_Type
   is (Slice (Source, Low, High));

   --  Search for pattern in string (returns 0 if not found)
   function Find_Index (Source : String_Type; Pattern : String_Type) return Natural
   is (Index (Source, Pattern));

   --  Search with Latin-1 pattern
   function Find_Index_Latin_1 (Source : String_Type; Pattern : String) return Natural
   is (Index_Latin_1 (Source, Pattern));

   --  Check if Source contains Pattern
   function Contains (Source : String_Type; Pattern : String_Type) return Boolean
   is (Index (Source, Pattern) > 0);

   --  Case conversion
   function Lower_Case (Source : String_Type) return String_Type
   is (To_Lower (Source));

   function Upper_Case (Source : String_Type) return String_Type
   is (To_Upper (Source));

   --  Prefix checking
   function Has_Prefix (Source : String_Type; Prefix : String_Type) return Boolean
   is (Starts_With (Source, Prefix));

   function Has_Prefix_Latin_1 (Source : String_Type; Prefix : String) return Boolean
   is (Starts_With_Latin_1 (Source, Prefix));

   --  Suffix checking
   function Has_Suffix (Source : String_Type; Suffix : String_Type) return Boolean
   is (Ends_With (Source, Suffix));

   --  Trim whitespace
   function Trimmed (Source : String_Type) return String_Type
   is (Trim (Source));

   --  Create single-character string
   function Character_To_String (C : Character_Type) return String_Type
   is (From_Character (C));

   ---------------------------------------------------------------------------
   --  Latin-1 Concatenation
   ---------------------------------------------------------------------------

   --  Concatenation with Latin-1 String
   function Concat_With_Latin_1 (Left : String_Type; Right : String) return String_Type
   is (Concat_String_Latin_1 (Left, Right));

   function Concat_Latin_1_With (Left : String; Right : String_Type) return String_Type
   is (Concat_Latin_1_String (Left, Right));

   ---------------------------------------------------------------------------
   --  Character Predicates
   ---------------------------------------------------------------------------

   --  Check if a character is an equals sign
   function Is_Equals_Sign (C : Character_Type) return Boolean
   is (Character_Type'Pos (C) = Character'Pos ('='));

   --  Check if a character is a dash/hyphen
   function Is_Dash (C : Character_Type) return Boolean
   is (Character_Type'Pos (C) = Character'Pos ('-'));

end Anystrings;
