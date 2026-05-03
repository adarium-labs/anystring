-------------------------------------------------------------------------------
--  String_Types - UXString Configuration
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Re-exports string types and operations from UXStrings instantiation.
--
--  @description
--  This is the UXString variant of String_Types. It provides full
--  Unicode support with proper code point handling.
--
--  To use this variant, set `STRING_TYPE` environment variable to `uxstring`.

with Ada.Containers;
with UXStrings;
with UXString_Operations;
with UXStrings;

package String_Types is

   ---------------------------------------------------------------------------
   --  Core Types (from the underlying string implementation)
   ---------------------------------------------------------------------------

   subtype String_Type is UXStrings.UXString;
   subtype Character_Type is UXStrings.Unicode_Character;

   ---------------------------------------------------------------------------
   --  Constants
   ---------------------------------------------------------------------------

   Empty_String : constant String_Type := UXStrings.Empty_String;

   ---------------------------------------------------------------------------
   --  Query Operations
   ---------------------------------------------------------------------------

   function Length (Source : String_Type) return Natural
     renames UXString_Operations.Length;

   function Is_Empty (Source : String_Type) return Boolean
     renames UXString_Operations.Is_Empty;

   function Get_Length (Source : String_Type) return Natural
     renames UXStrings.Get_Length;

   function Is_Null_Or_Empty (Source : String_Type) return Boolean
     renames UXStrings.Is_Null_Or_Empty;

   function Element
     (Source : String_Type;
      Index  : Positive) return Character_Type
     renames UXString_Operations.Element;

   function Get_Element
     (Source : String_Type;
      Index  : Positive) return Character_Type
     renames UXStrings.Get_Element;

   function First_Index (Source : String_Type) return Positive
     renames UXStrings.First_Index;

   function Last_Index (Source : String_Type) return Natural
     renames UXStrings.Last_Index;

   --  Check if Source contains Pattern
   function Contains (Source : String_Type; Pattern : String_Type) return Boolean
     renames UXStrings.Contains;

   ---------------------------------------------------------------------------
   --  Concatenation Operations
   ---------------------------------------------------------------------------

   function Concat
     (Left  : String_Type;
      Right : String_Type) return String_Type
     renames UXStrings.Concat;

   function Append_Character
     (Left  : String_Type;
      Right : Character_Type) return String_Type
     renames UXStrings.Append_Character;

   function Prepend_Character
     (Left  : Character_Type;
      Right : String_Type) return String_Type
     renames UXStrings.Prepend_Character;

   function "&"
     (Left  : String_Type;
      Right : String_Type) return String_Type
     renames UXString_Operations.Concat_Strings;

   function "&"
     (Left  : String_Type;
      Right : Character_Type) return String_Type
     renames UXString_Operations.Concat_String_Character;

   function "&"
     (Left  : Character_Type;
      Right : String_Type) return String_Type
     renames UXString_Operations.Concat_Character_String;

   --  Concatenation with Latin-1 String
   function "&"
     (Left  : String_Type;
      Right : String) return String_Type
     renames UXString_Operations.Concat_String_Latin_1;

   function "&"
     (Left  : String;
      Right : String_Type) return String_Type
     renames UXString_Operations.Concat_Latin_1_String;

   ---------------------------------------------------------------------------
   --  Comparison Operations
   ---------------------------------------------------------------------------

   function "=" (Left, Right : String_Type) return Boolean
     renames UXStrings.Equal;

   function "<" (Left, Right : String_Type) return Boolean
     renames UXStrings.Less_Than;

   function "<=" (Left, Right : String_Type) return Boolean
     renames UXStrings.Less_Or_Equal;

   function ">" (Left, Right : String_Type) return Boolean
     renames UXStrings.Greater_Than;

   function ">=" (Left, Right : String_Type) return Boolean
     renames UXStrings.Greater_Or_Equal;

   ---------------------------------------------------------------------------
   --  Conversion Operations
   ---------------------------------------------------------------------------

   --  Convert from Latin-1/UTF-8 String to String_Type
   function To_String_Type (Source : String) return String_Type
     renames UXString_Operations.To_UXString;

   --  Convert from String_Type to Latin-1/UTF-8 String
   function To_Latin_1 (Source : String_Type) return String
     renames UXString_Operations.To_String;

   ---------------------------------------------------------------------------
   --  Extended String Operations
   ---------------------------------------------------------------------------

   --  Hash function for use with hashed containers
   function Hash (Key : String_Type) return Ada.Containers.Hash_Type
     renames UXString_Operations.Hash;

   --  Slice extraction
   function Slice
     (Source : String_Type;
      Low    : Positive;
      High   : Natural) return String_Type
     renames UXString_Operations.Slice;

   --  Index/search operations
   function Index
     (Source  : String_Type;
      Pattern : String_Type) return Natural
     renames UXString_Operations.Index;

   function Index
     (Source  : String_Type;
      Pattern : String) return Natural
     renames UXString_Operations.Index_Latin_1;

   --  Case conversion
   function To_Lower (Source : String_Type) return String_Type
     renames UXString_Operations.To_Lower;

   function To_Upper (Source : String_Type) return String_Type
     renames UXString_Operations.To_Upper;

   --  Prefix/suffix checking
   function Starts_With
     (Source : String_Type;
      Prefix : String_Type) return Boolean
     renames UXString_Operations.Starts_With;

   function Starts_With
     (Source : String_Type;
      Prefix : String) return Boolean
     renames UXString_Operations.Starts_With_Latin_1;

   function Ends_With
     (Source : String_Type;
      Suffix : String_Type) return Boolean
     renames UXString_Operations.Ends_With;

   --  Trim operations
   function Trim (Source : String_Type) return String_Type
     renames UXString_Operations.Trim;

   --  Character operations
   function From_Character (C : Character_Type) return String_Type
     renames UXString_Operations.From_Character;

   --  Character predicates
   function Is_Equals_Sign (C : Character_Type) return Boolean
   is (UXStrings.To_Unicode (C) = Character'Pos ('='));

   function Is_Dash (C : Character_Type) return Boolean
   is (UXStrings.To_Unicode (C) = Character'Pos ('-'));

end String_Types;
