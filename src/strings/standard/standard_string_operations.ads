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
with Anystrings_Conv;

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
   --
   --  The `standard` backend stores its bytes verbatim. By project convention
   --  (FUNC-CONV-001) the caller passes a well-formed UTF-8 byte sequence;
   --  this function is byte-identity and performs no validation.
   --  @relation FUNC-CONV-001
   function To_Unbounded_String (Source : String) return Unbounded_String
   renames Ada.Strings.Unbounded.To_Unbounded_String;

   --  Byte-identity extraction of the underlying Unbounded_String contents.
   --
   --  This is the raw-bytes accessor used internally by the operations
   --  package (Index, Trim, To_Lower, …) and bound to the `To_UTF_8` formal
   --  of the Anystrings generic instantiation (per FUNC-CONV-003: the
   --  storage is UTF-8, so emission is byte-identity).
   function To_String (Source : Unbounded_String) return String renames Ada.Strings.Unbounded.To_String;

   --  Latin-1 egress: decode UTF-8 storage then transliterate each code
   --  point to a single Latin-1 byte. Code points greater than U+00FF are
   --  replaced by the single byte '?' (16#3F#) per FUNC-CONV-006.
   --
   --  Total; never raises.
   --  @relation FUNC-CONV-006, FUNC-CONV-007
   function To_Latin_1 (Source : Unbounded_String) return String;

   --  Latin-1 egress with loss detection.
   --
   --  Same transliteration as To_Latin_1, but the returned record reports
   --  whether any code point was replaced by '?' and how many. See
   --  Anystrings_Conv.Latin_1_Conv_Result.
   --
   --  Total; never raises.
   --  @relation FUNC-CONV-008, FUNC-CONV-009
   function To_Latin_1_If_Possible
     (Source : Unbounded_String) return Anystrings_Conv.Latin_1_Conv_Result;

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

   function Index_From
     (Source      : Unbounded_String;
      Pattern     : Unbounded_String;
      Starting_At : Positive) return Natural;

   function Index_Reverse (Source : Unbounded_String; Pattern : Unbounded_String) return Natural;

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

   --  @summary Emit the UTF-8 bytes held in the storage.
   --
   --  @description
   --  Per FUNC-CONV-001 / FUNC-CONV-003 the `standard` backend stores its
   --  bytes as a UTF-8 byte sequence (caller's responsibility — guaranteed
   --  by the From_UTF_8 ingestion path, by the Ada.Command_Line bridge per
   --  FUNC-CMDLINE-008, and by the UTF-8 source-file convention recorded in
   --  the root AGENTS.md). To_UTF_8 is therefore byte-identity: it returns
   --  Ada.Strings.Unbounded.To_String (Source) verbatim, with no
   --  transcoding step.
   --
   --  This is observationally equivalent to the prior
   --  Ada.Strings.UTF_Encoding.Strings.Encode-based body on ASCII input,
   --  but produces correct (non-double-encoded) output on UTF-8 input —
   --  the previous behaviour treated stored bytes as Latin-1 code points
   --  and re-encoded them, producing systematic mojibake on any non-ASCII
   --  argv or environment value (FUNC-CONV-011 amendment to FUNC-UTF8-003).
   --
   --  ASCII (U+0000..U+007F) passes through byte-for-byte (FUNC-UTF8-005,
   --  FUNC-CONV-005). Surrogates cannot occur in a Character (range
   --  0..255), so FUNC-UTF8-007 is satisfied vacuously. The result is
   --  well-formed UTF-8 whenever the storage was well-formed UTF-8
   --  (FUNC-UTF8-006).
   --
   --  @param Source  The Unbounded_String whose stored bytes (UTF-8) are
   --                 to be returned.
   --  @return        The stored UTF-8 byte sequence.
   --  @relation FUNC-UTF8-003, FUNC-UTF8-005, FUNC-UTF8-006, FUNC-CONV-001,
   --            FUNC-CONV-003, FUNC-CONV-011, NFR-UTF8-007, NFR-UTF8-010
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

   --  Filesystem Operations (FUNC-DIR-002..006, NFR-DIR-001)
   --  Path encoding: Ada.Strings.Unbounded.To_String (byte-identity; storage
   --  IS UTF-8 per FUNC-CONV-001). Bodies in standard_string_operations.adb.

   --  @relation FUNC-DIR-001
   type File_Kind is (Directory, Ordinary_File, Special_File);

   --  @relation FUNC-DIR-002, NFR-DIR-001
   function Path_Exists (Path : Unbounded_String) return Boolean;

   --  @relation FUNC-DIR-003, NFR-DIR-001
   function Path_Kind (Path : Unbounded_String) return File_Kind;

   --  @relation FUNC-DIR-004, NFR-DIR-001
   function Create_Directory_Path (Path : Unbounded_String) return Boolean;

   --  @relation FUNC-DIR-005, NFR-DIR-001
   function Delete_File_Path (Path : Unbounded_String) return Boolean;

   --  @relation FUNC-DIR-006, NFR-DIR-001
   function Rename_Path (Old_Path, New_Path : Unbounded_String) return Boolean;

end Standard_String_Operations;
