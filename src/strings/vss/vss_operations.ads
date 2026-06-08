-------------------------------------------------------------------------------
--  VSS_Operations - Operations for VSS.Strings.Virtual_String
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Provides operations required for instantiating Anystrings with
--  VSS.Strings.Virtual_String.
--
--  @description
--  This package wraps VSS operations to match the signature required by
--  the Anystrings generic. Virtual_String provides full Unicode support:
--  Length and Element operate on Unicode code points (Virtual_Character),
--  matching the semantics of the uxstring backend.
--
--  Several operations (Element, Slice, Index) take integer indexes which
--  VSS does not expose natively (VSS uses cursors for variable-cost
--  iteration). These are implemented by round-tripping through
--  Wide_Wide_String via VSS.Strings.Conversions. This trades performance
--  for API compatibility — VSS-aware callers should bypass String_Types
--  and use VSS.Strings directly when iteration cost matters.
--
--  Latin-1 conversion semantics: To_String_Type maps byte values 0..255 to
--  the matching Unicode code points U+0000..U+00FF. To_Latin_1 truncates
--  code points outside U+0000..U+00FF by substituting '?' so the result
--  always fits the Latin-1 byte range.
--
--  Environment and Text I/O cross the API boundary as UTF-8 byte
--  sequences, matching the uxstring backend convention.

with Ada.Containers;
with Ada.Text_IO;
with VSS.Strings;

package VSS_Operations is

   subtype Virtual_String is VSS.Strings.Virtual_String;

   --  Use Wide_Wide_Character (rather than VSS.Characters.Virtual_Character)
   --  as the character type so the backend behaves like the wide_wide_string
   --  backend at the API edge. VSS.Characters.Virtual_Character is a derived
   --  type with a Static_Predicate excluding surrogates, which makes
   --  attributes like 'First, 'Last, and 'Range illegal in consumer code.
   --  Conversion to a valid Virtual_Character happens internally; invalid
   --  code points (surrogates or values > U+10FFFF) are substituted with
   --  U+FFFD on the input boundary.

   Null_Virtual_String : constant Virtual_String :=
     VSS.Strings.Empty_Virtual_String;

   ---------------------------------------------------------------------------
   --  Core Operations
   ---------------------------------------------------------------------------

   function Length (Source : Virtual_String) return Natural;

   function Is_Empty (Source : Virtual_String) return Boolean;

   function Element
     (Source : Virtual_String;
      Index  : Positive) return Wide_Wide_Character;

   function Concat_Strings
     (Left  : Virtual_String;
      Right : Virtual_String) return Virtual_String;

   function Concat_String_Character
     (Left  : Virtual_String;
      Right : Wide_Wide_Character) return Virtual_String;

   function Concat_Character_String
     (Left  : Wide_Wide_Character;
      Right : Virtual_String) return Virtual_String;

   function Concat_String_Latin_1
     (Left  : Virtual_String;
      Right : String) return Virtual_String;

   function Concat_Latin_1_String
     (Left  : String;
      Right : Virtual_String) return Virtual_String;

   ---------------------------------------------------------------------------
   --  Comparison Operations
   ---------------------------------------------------------------------------

   function "=" (Left, Right : Virtual_String) return Boolean;
   function "<" (Left, Right : Virtual_String) return Boolean;
   function "<=" (Left, Right : Virtual_String) return Boolean;
   function ">" (Left, Right : Virtual_String) return Boolean;
   function ">=" (Left, Right : Virtual_String) return Boolean;

   ---------------------------------------------------------------------------
   --  Conversion Operations
   ---------------------------------------------------------------------------

   --  Convert Latin-1 String to Virtual_String (byte -> code point).
   function To_Virtual_String (Source : String) return Virtual_String;

   --  Convert Virtual_String to Latin-1 String, substituting '?' for code
   --  points outside U+0000..U+00FF.
   function To_String (Source : Virtual_String) return String;

   ---------------------------------------------------------------------------
   --  Environment Operations (UTF-8 boundary)
   ---------------------------------------------------------------------------

   function Environment_Value
     (Name    : Virtual_String;
      Default : Virtual_String) return Virtual_String;

   function Environment_Exists (Name : Virtual_String) return Boolean;

   function Environment_Set
     (Name  : Virtual_String;
      Value : Virtual_String) return Boolean;

   function Environment_Clear (Name : Virtual_String) return Boolean;

   function Environment_Clear return Boolean;

   function Environment_Iterate
     (Process : not null access procedure
        (Name  : Virtual_String;
         Value : Virtual_String)) return Boolean;

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

   procedure Close_File (File : in out File_Type)
     renames Ada.Text_IO.Close;

   function Is_Open_File (File : File_Type) return Boolean
     renames Ada.Text_IO.Is_Open;

   function Current_Input_File return File_Type
     renames Ada.Text_IO.Current_Input;

   function Current_Output_File return File_Type
     renames Ada.Text_IO.Current_Output;

   procedure Set_Input_File (File : File_Type)
     renames Ada.Text_IO.Set_Input;

   procedure Set_Output_File (File : File_Type)
     renames Ada.Text_IO.Set_Output;

   procedure Put_File (File : File_Type; Item : Virtual_String);

   function Get_Line_File (File : File_Type) return Virtual_String;

   procedure New_Line_File (File : File_Type);

   function End_Of_File_File (File : File_Type) return Boolean
     renames Ada.Text_IO.End_Of_File;

   ---------------------------------------------------------------------------
   --  Extended Operations
   ---------------------------------------------------------------------------

   function Hash (Key : Virtual_String) return Ada.Containers.Hash_Type;

   function Slice
     (Source : Virtual_String;
      Low    : Positive;
      High   : Natural) return Virtual_String;

   function Index
     (Source  : Virtual_String;
      Pattern : Virtual_String) return Natural;

   function Index_Latin_1
     (Source  : Virtual_String;
      Pattern : String) return Natural;

   function To_Lower (Source : Virtual_String) return Virtual_String;
   function To_Upper (Source : Virtual_String) return Virtual_String;

   function Starts_With
     (Source : Virtual_String;
      Prefix : Virtual_String) return Boolean;

   function Starts_With_Latin_1
     (Source : Virtual_String;
      Prefix : String) return Boolean;

   function Ends_With
     (Source : Virtual_String;
      Suffix : Virtual_String) return Boolean;

   function Trim (Source : Virtual_String) return Virtual_String;

   function From_Character (C : Wide_Wide_Character) return Virtual_String;

   ---------------------------------------------------------------------------
   --  UTF-8 Boundary Operations
   ---------------------------------------------------------------------------

   --  @summary Encode a Virtual_String as a UTF-8 String.
   --
   --  @description
   --  Total function; never raises (NFR-UTF8-005). VSS stores strings as
   --  validated UTF-8 internally and forbids surrogate code points by
   --  construction (VSS.Characters.Virtual_Character excludes U+D800..U+DFFF
   --  via a Static_Predicate). The result is therefore always well-formed
   --  UTF-8 with no surrogate substitution needed (FUNC-UTF8-006).
   --  ASCII-only input passes through byte-for-byte (FUNC-UTF8-005).
   --
   --  @param Source  The Virtual_String to encode.
   --  @return        Well-formed UTF-8 byte sequence as a Standard.String.
   --  @relation FUNC-UTF8-003, FUNC-UTF8-005, FUNC-UTF8-006, FUNC-UTF8-013
   function To_UTF_8 (Source : Virtual_String) return String;

end VSS_Operations;
