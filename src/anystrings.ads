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
with Anystrings_UTF_8_Results;

generic
   --  The string type being abstracted
   type String_Type is private;

   --  The character type used by this string type
   type Character_Type is (<>);

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
   --  UTF-8 Boundary Operations (FUNC-UTF8-003, FUNC-UTF8-008, NFR-UTF8-009)
   ---------------------------------------------------------------------------

   --  Formal package encapsulating the backend's UTF_8_Decode_Result type and
   --  its accessors (Is_Ok, Get_Value, Get_Error, Make_Ok, Make_Error).
   --  Using a formal package guarantees that String_Type, the result record,
   --  and the accessors are consistent within an instantiation (NFR-UTF8-001).
   --  @relation FUNC-UTF8-002, FUNC-UTF8-003, FUNC-UTF8-008, NFR-UTF8-009
   with package UTF_8 is new Anystrings_UTF_8_Results (String_Type => String_Type, Null_String => Null_String);

   --  Backend-specific UTF-8 encoder; total, never raises (FUNC-UTF8-003,
   --  FUNC-UTF8-005, FUNC-UTF8-006, FUNC-UTF8-007, NFR-UTF8-005).
   --  @relation FUNC-UTF8-003, FUNC-UTF8-005, FUNC-UTF8-006, FUNC-UTF8-007
   with function To_UTF_8 (Source : String_Type) return String;

   --  Backend-specific UTF-8 decoder; total, never raises (FUNC-UTF8-008,
   --  FUNC-UTF8-010, NFR-UTF8-004).
   --  @relation FUNC-UTF8-008, FUNC-UTF8-010, NFR-UTF8-004
   with function From_UTF_8 (Source : String) return UTF_8.UTF_8_Decode_Result;

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

   --  Search starting at an arbitrary position (matches Ada.Strings.Fixed.Index
   --  with From parameter). Total: returns 0 if Pattern is empty, not found,
   --  or Starting_At > Length (Source).
   with function Index_From
     (Source      : String_Type;
      Pattern     : String_Type;
      Starting_At : Positive) return Natural;

   --  Search backwards from end of Source. Total: returns 0 if Pattern is
   --  empty, longer than Source, or not found.
   with function Index_Reverse (Source : String_Type; Pattern : String_Type) return Natural;

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

   ---------------------------------------------------------------------------
   --  Character Classification (FUNC-CHAR-CLASS-001..012)
   ---------------------------------------------------------------------------

   --  Classification predicates. Each backend dispatches to the most
   --  Unicode-aware classifier its character type allows. See
   --  src/strings/AGENTS.md for backend-specific semantics caveats.

   with function Is_Alphanumeric (C : Character_Type) return Boolean;
   with function Is_Control (C : Character_Type) return Boolean;
   with function Is_Digit (C : Character_Type) return Boolean;
   with function Is_Graphic (C : Character_Type) return Boolean;
   with function Is_Hex_Digit (C : Character_Type) return Boolean;
   with function Is_Letter (C : Character_Type) return Boolean;
   with function Is_Line_Terminator (C : Character_Type) return Boolean;
   with function Is_Lower (C : Character_Type) return Boolean;
   with function Is_Upper (C : Character_Type) return Boolean;
   with function Is_Whitespace (C : Character_Type) return Boolean;

   --  Character-level case mapping. The string-level To_Lower / To_Upper
   --  formals above are untouched. These formals use distinct names
   --  (Char_To_Lower / Char_To_Upper) so named instantiations remain
   --  unambiguous; the user-facing API in String_Types still exposes them
   --  as overloads of To_Lower / To_Upper on Character_Type.
   with function Char_To_Lower (C : Character_Type) return Character_Type;
   with function Char_To_Upper (C : Character_Type) return Character_Type;

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
   --  UTF-8 Boundary Wrappers (SPARK_Mode On)
   ---------------------------------------------------------------------------

   --  @summary Convert a String_Type to its UTF-8 byte representation.
   --
   --  @description
   --  Total function; never raises. ASCII code units (U+0000..U+007F) pass
   --  through unchanged (FUNC-UTF8-005). Surrogate code units (if present in
   --  the backend's representation) are substituted with U+FFFD before
   --  encoding (FUNC-UTF8-007, NFR-UTF8-005). The result is always
   --  well-formed UTF-8 (FUNC-UTF8-006).
   --
   --  @param Source  The string to encode.
   --  @return        Well-formed UTF-8 byte sequence as a Standard.String.
   --  @relation FUNC-UTF8-003, FUNC-UTF8-005, FUNC-UTF8-006, FUNC-UTF8-007, NFR-UTF8-002
   function As_UTF_8 (Source : String_Type) return String
   is (To_UTF_8 (Source));

   --  @summary Decode a UTF-8 byte sequence into a Result.
   --
   --  @description
   --  Total function; never raises. Returns a discriminated
   --  UTF_8_Decode_Result: Is_Ok = True on success (Get_Value holds the
   --  decoded String_Type), or Is_Ok = False on error (Get_Error holds
   --  the failure category per FUNC-UTF8-010). Empty input returns
   --  Is_Ok = True with an empty string value (FUNC-UTF8-009).
   --
   --  @param Source  UTF-8 byte sequence to decode.
   --  @return        UTF_8_Decode_Result carrying the decoded value or error.
   --  @relation FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-010, NFR-UTF8-002, NFR-UTF8-004
   function Decode_UTF_8 (Source : String) return UTF_8.UTF_8_Decode_Result
   is (From_UTF_8 (Source));

   --  @summary Convenience predicate: True iff Source is well-formed UTF-8.
   --
   --  @description
   --  Equivalent to UTF_8.Is_Ok (From_UTF_8 (Source)). Useful when the
   --  caller only needs to check validity without extracting a value.
   --
   --  @param Source  UTF-8 byte sequence to validate.
   --  @return        True when Source is well-formed UTF-8; False otherwise.
   --  @relation FUNC-UTF8-008, FUNC-UTF8-010, NFR-UTF8-002
   function UTF_8_Is_Valid (Source : String) return Boolean
   is (UTF_8.Is_Ok (From_UTF_8 (Source)))
   with Post => UTF_8_Is_Valid'Result = UTF_8.Is_Ok (From_UTF_8 (Source));

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

   --  Search starting at an arbitrary position; returns 0 if not found.
   function Find_Index_From
     (Source      : String_Type;
      Pattern     : String_Type;
      Starting_At : Positive) return Natural
   is (Index_From (Source, Pattern, Starting_At));

   --  Search backwards from end of source; returns 0 if not found.
   function Find_Index_Reverse (Source : String_Type; Pattern : String_Type) return Natural
   is (Index_Reverse (Source, Pattern));

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

   --  Character classification and case-mapping predicates are exposed as
   --  generic formal subprograms (Is_Alphanumeric, Is_Control, Is_Digit,
   --  Is_Graphic, Is_Hex_Digit, Is_Letter, Is_Line_Terminator, Is_Lower,
   --  Is_Upper, Is_Whitespace, Char_To_Lower, Char_To_Upper). Consumers
   --  call them directly through the chosen instantiation; String_Types
   --  re-exports them under user-facing names (To_Lower / To_Upper
   --  overload on Character_Type, Is_* unchanged).

   ---------------------------------------------------------------------------
   --  Substitution and Padding Operations
   ---------------------------------------------------------------------------

   --  @summary Substitute every non-overlapping occurrence of Pattern with By.
   --
   --  @description
   --  Total function; never raises. Returns Source unchanged when Pattern is
   --  empty (avoids infinite loop) or longer than Source. Returns Source
   --  unchanged when Pattern is not found.
   function Replace
     (Source  : String_Type;
      Pattern : String_Type;
      By      : String_Type) return String_Type;

   --  @summary Truncate or right-pad Source to exactly Count characters.
   function Head (Source : String_Type; Count : Natural; Pad : Character_Type) return String_Type;

   --  @summary Truncate-from-left or left-pad Source to exactly Count characters.
   function Tail (Source : String_Type; Count : Natural; Pad : Character_Type) return String_Type;

end Anystrings;
