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
with Ada.Text_IO;
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

   function Environment_Value (Name : Unbounded_String; Default : Unbounded_String) return Unbounded_String;

   function Environment_Exists (Name : Unbounded_String) return Boolean;

   function Environment_Set (Name : Unbounded_String; Value : Unbounded_String) return Boolean;

   function Environment_Clear (Name : Unbounded_String) return Boolean;

   function Environment_Clear return Boolean;

   function Environment_Iterate
     (Process : not null access procedure (Name : Unbounded_String; Value : Unbounded_String)) return Boolean;

   ---------------------------------------------------------------------------
   --  Text I/O Operations
   ---------------------------------------------------------------------------

   subtype File_Type is Ada.Text_IO.File_Type;
   subtype File_Mode is Ada.Text_IO.File_Mode;

   In_File_Mode     : constant File_Mode := Ada.Text_IO.In_File;
   Out_File_Mode    : constant File_Mode := Ada.Text_IO.Out_File;
   Append_File_Mode : constant File_Mode := Ada.Text_IO.Append_File;

   procedure Create_File (File : in out File_Type; Mode : File_Mode := Out_File_Mode; Name : String := "");

   procedure Open_File (File : in out File_Type; Mode : File_Mode; Name : String);

   procedure Close_File (File : in out File_Type) renames Ada.Text_IO.Close;

   function Is_Open_File (File : File_Type) return Boolean renames Ada.Text_IO.Is_Open;

   function Current_Input_File return File_Type renames Ada.Text_IO.Current_Input;

   function Current_Output_File return File_Type renames Ada.Text_IO.Current_Output;

   procedure Set_Input_File (File : File_Type) renames Ada.Text_IO.Set_Input;

   procedure Set_Output_File (File : File_Type) renames Ada.Text_IO.Set_Output;

   procedure Put_File (File : File_Type; Item : Unbounded_String);

   function Get_Line_File (File : File_Type) return Unbounded_String;

   procedure New_Line_File (File : File_Type);

   function End_Of_File_File (File : File_Type) return Boolean renames Ada.Text_IO.End_Of_File;

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

   ---------------------------------------------------------------------------
   --  UTF-8 Boundary Operations (FUNC-UTF8-003, FUNC-UTF8-008, NFR-UTF8-007)
   ---------------------------------------------------------------------------

   --  @summary Encode an Unbounded_String (Latin-1 bytes) as a UTF-8 String.
   --
   --  @description
   --  The standard backend stores Latin-1 bytes. This function encodes each
   --  byte as a UTF-8 scalar using Ada.Strings.UTF_Encoding.Strings.Encode,
   --  which expands code points 128..255 to two-byte UTF-8 sequences.
   --  ASCII-only input (0..127) passes through byte-for-byte (FUNC-UTF8-005).
   --  Surrogates cannot occur in Character (range 0..255), so FUNC-UTF8-007
   --  is satisfied vacuously. The result is always well-formed UTF-8
   --  (FUNC-UTF8-006). This function is NOT a rename of To_String (NFR-UTF8-010):
   --  the output differs from To_Latin_1 for code points 128..255 because
   --  UTF-8 expands them to multi-byte sequences whereas Latin-1 maps them 1:1.
   --
   --  @param Source  The Unbounded_String to encode.
   --  @return        Well-formed UTF-8 byte sequence as a Standard.String.
   --  @relation FUNC-UTF8-003, FUNC-UTF8-005, FUNC-UTF8-006, NFR-UTF8-007, NFR-UTF8-010
   function To_UTF_8 (Source : Unbounded_String) return String;

   ---------------------------------------------------------------------------
   --  Character Classification & Case Mapping
   ---------------------------------------------------------------------------
   --  Delegates to Ada.Characters.Handling. Length/Element on this backend
   --  count bytes (Latin-1), so these predicates classify Latin-1 code
   --  points only — code points > U+00FF are not representable here.

   function Char_Is_Alphanumeric (C : Character) return Boolean
   renames Ada.Characters.Handling.Is_Alphanumeric;

   function Char_Is_Control (C : Character) return Boolean
   renames Ada.Characters.Handling.Is_Control;

   function Char_Is_Digit (C : Character) return Boolean
   renames Ada.Characters.Handling.Is_Digit;

   function Char_Is_Graphic (C : Character) return Boolean
   renames Ada.Characters.Handling.Is_Graphic;

   function Char_Is_Hex_Digit (C : Character) return Boolean
   renames Ada.Characters.Handling.Is_Hexadecimal_Digit;

   function Char_Is_Letter (C : Character) return Boolean
   renames Ada.Characters.Handling.Is_Letter;

   function Char_Is_Line_Terminator (C : Character) return Boolean;

   function Char_Is_Lower (C : Character) return Boolean
   renames Ada.Characters.Handling.Is_Lower;

   function Char_Is_Upper (C : Character) return Boolean
   renames Ada.Characters.Handling.Is_Upper;

   --  ASCII whitespace: SP, HT, LF, VT, FF, CR.
   function Char_Is_Whitespace (C : Character) return Boolean;

   function Char_To_Lower (C : Character) return Character
   renames Ada.Characters.Handling.To_Lower;

   function Char_To_Upper (C : Character) return Character
   renames Ada.Characters.Handling.To_Upper;

end Standard_String_Operations;
