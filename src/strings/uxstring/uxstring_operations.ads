-------------------------------------------------------------------------------
--  UXString_Operations - Operations for UXStrings.UXString
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Provides operations required for instantiating Strings with
--  UXStrings.UXString.
--
--  @description
--  This package wraps UXString operations to match the signature required
--  by the Strings generic package. UXString provides full Unicode
--  support with proper code point handling.

with Ada.Containers;
with UXStrings; use UXStrings;

package UXString_Operations is

   ---------------------------------------------------------------------------
   --  Core Operations (required by Strings signature)
   ---------------------------------------------------------------------------

   --  Empty string constant
   Null_UXString : constant UXString := UXStrings.Null_UXString;

   --  Returns the length of the string (in code points)
   function Length (Source : UXString) return Natural
     renames UXStrings.Length;

   --  Returns True if the string is empty
   function Is_Empty (Source : UXString) return Boolean
   is (UXStrings.Length (Source) = 0);

   --  Returns the character at position Index (1-indexed)
   function Element
     (Source : UXString;
      Index  : Positive) return Unicode_Character
     renames UXStrings.Element;

   --  Concatenation of two strings
   function Concat_Strings
     (Left  : UXString;
      Right : UXString) return UXString
     renames UXStrings."&";

   --  Concatenation of a string and a character
   function Concat_String_Character
     (Left  : UXString;
      Right : Unicode_Character) return UXString
     renames UXStrings."&";

   --  Concatenation of a character and a string
   function Concat_Character_String
     (Left  : Unicode_Character;
      Right : UXString) return UXString
     renames UXStrings."&";

   --  Concatenation of UXString and Latin-1 String
   function Concat_String_Latin_1
     (Left  : UXString;
      Right : String) return UXString;

   --  Concatenation of Latin-1 String and UXString
   function Concat_Latin_1_String
     (Left  : String;
      Right : UXString) return UXString;

   --  Comparison operators
   function "="
     (Left, Right : UXString) return Boolean
     renames UXStrings."=";

   function "<"
     (Left, Right : UXString) return Boolean
     renames UXStrings."<";

   function "<="
     (Left, Right : UXString) return Boolean
     renames UXStrings."<=";

   function ">"
     (Left, Right : UXString) return Boolean
     renames UXStrings.">";

   function ">="
     (Left, Right : UXString) return Boolean
     renames UXStrings.">=";

   ---------------------------------------------------------------------------
   --  Conversion Operations
   ---------------------------------------------------------------------------

   --  Convert from String to UXString (assumes UTF-8 encoding)
   function To_UXString (Source : String) return UXString
     renames UXStrings.From_UTF_8;

   --  Convert from UXString to String (UTF-8 encoding)
   function To_String (Source : UXString) return String
     renames UXStrings.To_UTF_8;

   ---------------------------------------------------------------------------
   --  Extended Operations (used by String_Types)
   ---------------------------------------------------------------------------

   --  Hash function for use with hashed containers
   function Hash (Key : UXString) return Ada.Containers.Hash_Type;

   --  Slice extraction
   function Slice
     (Source : UXString;
      Low    : Positive;
      High   : Natural) return UXString;

   --  Index/search operations (returns 0 if not found)
   function Index
     (Source  : UXString;
      Pattern : UXString) return Natural;

   function Index_Latin_1
     (Source  : UXString;
      Pattern : String) return Natural;

   --  Case conversion
   function To_Lower (Source : UXString) return UXString;
   function To_Upper (Source : UXString) return UXString;

   --  Prefix/suffix checking
   function Starts_With
     (Source : UXString;
      Prefix : UXString) return Boolean;

   function Starts_With_Latin_1
     (Source : UXString;
      Prefix : String) return Boolean;

   function Ends_With
     (Source : UXString;
      Suffix : UXString) return Boolean;

   --  Trim whitespace from both ends
   function Trim (Source : UXString) return UXString;

   --  Create a single-character string
   function From_Character (C : Unicode_Character) return UXString;

end UXString_Operations;
