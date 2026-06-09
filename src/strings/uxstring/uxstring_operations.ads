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
with Ada.Text_IO;
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
   function To_String (Source : UXString) return String;

   ---------------------------------------------------------------------------
   --  Environment Operations
   ---------------------------------------------------------------------------

   function Environment_Value
     (Name    : UXString;
      Default : UXString) return UXString;

   function Environment_Exists
     (Name : UXString) return Boolean;

   function Environment_Set
     (Name  : UXString;
      Value : UXString) return Boolean;

   function Environment_Clear
     (Name : UXString) return Boolean;

   function Environment_Clear return Boolean;

   function Environment_Iterate
     (Process : not null access procedure
        (Name  : UXString;
         Value : UXString)) return Boolean;

   ---------------------------------------------------------------------------
   --  Text I/O Operations
   ---------------------------------------------------------------------------

   subtype File_Type is Ada.Text_IO.File_Type;
   subtype File_Mode is Ada.Text_IO.File_Mode;

   In_File_Mode     : constant File_Mode := Ada.Text_IO.In_File;
   Out_File_Mode    : constant File_Mode := Ada.Text_IO.Out_File;
   Append_File_Mode : constant File_Mode := Ada.Text_IO.Append_File;

   procedure Create_File
     (File : in out File_Type;
      Mode : File_Mode := Out_File_Mode;
      Name : String := "");

   procedure Open_File
     (File : in out File_Type;
      Mode : File_Mode;
      Name : String);

   procedure Close_File
     (File : in out File_Type)
   renames Ada.Text_IO.Close;

   function Is_Open_File
     (File : File_Type) return Boolean
   renames Ada.Text_IO.Is_Open;

   function Current_Input_File return File_Type
   renames Ada.Text_IO.Current_Input;

   function Current_Output_File return File_Type
   renames Ada.Text_IO.Current_Output;

   procedure Set_Input_File
     (File : File_Type)
   renames Ada.Text_IO.Set_Input;

   procedure Set_Output_File
     (File : File_Type)
   renames Ada.Text_IO.Set_Output;

   procedure Put_File
     (File : File_Type;
      Item : UXString);

   function Get_Line_File
     (File : File_Type) return UXString;

   procedure New_Line_File
     (File : File_Type);

   function End_Of_File_File
     (File : File_Type) return Boolean
   renames Ada.Text_IO.End_Of_File;

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

   function Index_From
     (Source      : UXString;
      Pattern     : UXString;
      Starting_At : Positive) return Natural;

   function Index_Reverse
     (Source  : UXString;
      Pattern : UXString) return Natural;

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

   ---------------------------------------------------------------------------
   --  UTF-8 Boundary Operations (FUNC-UTF8-003, FUNC-UTF8-013)
   ---------------------------------------------------------------------------

   --  @summary Encode a UXString as a UTF-8 String.
   --
   --  @description
   --  Total function; never raises (NFR-UTF8-005). UXStrings stores data
   --  internally as UTF-8, so this operation is a direct extraction via
   --  UXStrings.To_UTF_8 — no surrogate pre-scan or substitution is needed
   --  because UXString values are always well-formed by construction.
   --  ASCII-only input passes through byte-for-byte (FUNC-UTF8-005).
   --  The result is always well-formed UTF-8 (FUNC-UTF8-006).
   --  No NFC or NFC normalisation is applied; the caller is responsible
   --  for normalisation before comparison if canonical equivalence is
   --  required (FUNC-UTF8-013).
   --
   --  @param Source  The UXString to encode.
   --  @return        Well-formed UTF-8 byte sequence as a Standard.String.
   --  @relation FUNC-UTF8-003, FUNC-UTF8-005, FUNC-UTF8-006, FUNC-UTF8-013,
   --            NFR-UTF8-005
   function To_UTF_8 (Source : UXString) return String;

   ---------------------------------------------------------------------------
   --  Character Classification & Case Mapping
   ---------------------------------------------------------------------------
   --  Unicode_Character is a Wide_Wide_Character subtype, so we delegate
   --  to Ada.Wide_Wide_Characters.Handling. Unicode-aware: Is_Whitespace
   --  includes ASCII + Unicode Space_Separator; Is_Line_Terminator covers
   --  LF, CR, NEL, LS, PS. Non-scalar code points (surrogates,
   --  > U+10FFFF) cannot occur in a Unicode_Character by construction,
   --  but the implementation still guards against the upper range.

   function Char_Is_Alphanumeric (C : Unicode_Character) return Boolean;

   function Char_Is_Control (C : Unicode_Character) return Boolean;

   function Char_Is_Digit (C : Unicode_Character) return Boolean;

   function Char_Is_Graphic (C : Unicode_Character) return Boolean;

   function Char_Is_Hex_Digit (C : Unicode_Character) return Boolean;

   function Char_Is_Letter (C : Unicode_Character) return Boolean;

   function Char_Is_Line_Terminator (C : Unicode_Character) return Boolean;

   function Char_Is_Lower (C : Unicode_Character) return Boolean;

   function Char_Is_Upper (C : Unicode_Character) return Boolean;

   function Char_Is_Whitespace (C : Unicode_Character) return Boolean;

   function Char_To_Lower (C : Unicode_Character) return Unicode_Character;

   function Char_To_Upper (C : Unicode_Character) return Unicode_Character;

end UXString_Operations;
