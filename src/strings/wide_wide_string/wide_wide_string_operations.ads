-------------------------------------------------------------------------------
--  Wide_Wide_String_Operations - Operations for Wide_Wide_Unbounded_String
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Containers;
with Ada.Wide_Wide_Text_IO;
with Ada.Strings.Wide_Wide_Unbounded;
with Anystrings_Conv;

package Wide_Wide_String_Operations is

   subtype Unbounded_Wide_Wide_String is
     Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String;

   Null_Unbounded_Wide_Wide_String : constant Unbounded_Wide_Wide_String :=
     Ada.Strings.Wide_Wide_Unbounded.Null_Unbounded_Wide_Wide_String;

   function Length (Source : Unbounded_Wide_Wide_String) return Natural
     renames Ada.Strings.Wide_Wide_Unbounded.Length;

   function Is_Empty (Source : Unbounded_Wide_Wide_String) return Boolean
   is (Ada.Strings.Wide_Wide_Unbounded.Length (Source) = 0);

   function Element
     (Source : Unbounded_Wide_Wide_String;
      Index  : Positive) return Wide_Wide_Character
     renames Ada.Strings.Wide_Wide_Unbounded.Element;

   function Concat_Strings
     (Left  : Unbounded_Wide_Wide_String;
      Right : Unbounded_Wide_Wide_String) return Unbounded_Wide_Wide_String
     renames Ada.Strings.Wide_Wide_Unbounded."&";

   function Concat_String_Character
     (Left  : Unbounded_Wide_Wide_String;
      Right : Wide_Wide_Character) return Unbounded_Wide_Wide_String
     renames Ada.Strings.Wide_Wide_Unbounded."&";

   function Concat_Character_String
     (Left  : Wide_Wide_Character;
      Right : Unbounded_Wide_Wide_String) return Unbounded_Wide_Wide_String
     renames Ada.Strings.Wide_Wide_Unbounded."&";

   function Concat_String_Latin_1
     (Left  : Unbounded_Wide_Wide_String;
      Right : String) return Unbounded_Wide_Wide_String;

   function Concat_Latin_1_String
     (Left  : String;
      Right : Unbounded_Wide_Wide_String) return Unbounded_Wide_Wide_String;

   function "="
     (Left, Right : Unbounded_Wide_Wide_String) return Boolean
     renames Ada.Strings.Wide_Wide_Unbounded."=";

   function "<"
     (Left, Right : Unbounded_Wide_Wide_String) return Boolean
     renames Ada.Strings.Wide_Wide_Unbounded."<";

   function "<="
     (Left, Right : Unbounded_Wide_Wide_String) return Boolean
     renames Ada.Strings.Wide_Wide_Unbounded."<=";

   function ">"
     (Left, Right : Unbounded_Wide_Wide_String) return Boolean
     renames Ada.Strings.Wide_Wide_Unbounded.">";

   function ">="
     (Left, Right : Unbounded_Wide_Wide_String) return Boolean
     renames Ada.Strings.Wide_Wide_Unbounded.">=";

   function To_Unbounded_Wide_Wide_String
     (Source : String) return Unbounded_Wide_Wide_String;

   function To_Unbounded_Wide_Wide_String
     (Source : Wide_Wide_String) return Unbounded_Wide_Wide_String;

   --  Latin-1 egress: one byte per Wide_Wide_Character code point. Code
   --  points greater than U+00FF (including surrogates and out-of-range
   --  values) are replaced by '?' (16#3F#) per FUNC-CONV-006.  Total;
   --  never raises.
   function To_String (Source : Unbounded_Wide_Wide_String) return String;

   --  Latin-1 egress with loss detection (FUNC-CONV-008..009).
   function To_Latin_1_If_Possible
     (Source : Unbounded_Wide_Wide_String) return Anystrings_Conv.Latin_1_Conv_Result;

   ---------------------------------------------------------------------------
   --  Environment Operations
   ---------------------------------------------------------------------------

   function Environment_Value
     (Name    : Unbounded_Wide_Wide_String;
      Default : Unbounded_Wide_Wide_String) return Unbounded_Wide_Wide_String;

   function Environment_Exists
     (Name : Unbounded_Wide_Wide_String) return Boolean;

   function Environment_Set
     (Name  : Unbounded_Wide_Wide_String;
      Value : Unbounded_Wide_Wide_String) return Boolean;

   function Environment_Clear
     (Name : Unbounded_Wide_Wide_String) return Boolean;

   function Environment_Clear return Boolean;

   function Environment_Iterate
     (Process : not null access procedure
        (Name  : Unbounded_Wide_Wide_String;
         Value : Unbounded_Wide_Wide_String)) return Boolean;

   ---------------------------------------------------------------------------
   --  Text I/O Operations
   ---------------------------------------------------------------------------

   subtype File_Type is Ada.Wide_Wide_Text_IO.File_Type;
   subtype File_Mode is Ada.Wide_Wide_Text_IO.File_Mode;

   In_File_Mode     : constant File_Mode := Ada.Wide_Wide_Text_IO.In_File;
   Out_File_Mode    : constant File_Mode := Ada.Wide_Wide_Text_IO.Out_File;
   Append_File_Mode : constant File_Mode := Ada.Wide_Wide_Text_IO.Append_File;

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
   renames Ada.Wide_Wide_Text_IO.Close;

   function Is_Open_File
     (File : File_Type) return Boolean
   renames Ada.Wide_Wide_Text_IO.Is_Open;

   function Current_Input_File return File_Type
   renames Ada.Wide_Wide_Text_IO.Current_Input;

   function Current_Output_File return File_Type
   renames Ada.Wide_Wide_Text_IO.Current_Output;

   procedure Set_Input_File
     (File : File_Type)
   renames Ada.Wide_Wide_Text_IO.Set_Input;

   procedure Set_Output_File
     (File : File_Type)
   renames Ada.Wide_Wide_Text_IO.Set_Output;

   procedure Put_File
     (File : File_Type;
      Item : Unbounded_Wide_Wide_String);

   function Get_Line_File
     (File : File_Type) return Unbounded_Wide_Wide_String;

   procedure New_Line_File
     (File : File_Type);

   function End_Of_File_File
     (File : File_Type) return Boolean
   renames Ada.Wide_Wide_Text_IO.End_Of_File;

   function Hash
     (Key : Unbounded_Wide_Wide_String) return Ada.Containers.Hash_Type;

   function Slice
     (Source : Unbounded_Wide_Wide_String;
      Low    : Positive;
      High   : Natural) return Unbounded_Wide_Wide_String;

   function Index
     (Source  : Unbounded_Wide_Wide_String;
      Pattern : Unbounded_Wide_Wide_String) return Natural;

   function Index_Latin_1
     (Source  : Unbounded_Wide_Wide_String;
      Pattern : String) return Natural;

   function Index_From
     (Source      : Unbounded_Wide_Wide_String;
      Pattern     : Unbounded_Wide_Wide_String;
      Starting_At : Positive) return Natural;

   function Index_Reverse
     (Source  : Unbounded_Wide_Wide_String;
      Pattern : Unbounded_Wide_Wide_String) return Natural;

   function To_Lower
     (Source : Unbounded_Wide_Wide_String) return Unbounded_Wide_Wide_String;

   function To_Upper
     (Source : Unbounded_Wide_Wide_String) return Unbounded_Wide_Wide_String;

   function Starts_With
     (Source : Unbounded_Wide_Wide_String;
      Prefix : Unbounded_Wide_Wide_String) return Boolean;

   function Starts_With_Latin_1
     (Source : Unbounded_Wide_Wide_String;
      Prefix : String) return Boolean;

   function Ends_With
     (Source : Unbounded_Wide_Wide_String;
      Suffix : Unbounded_Wide_Wide_String) return Boolean;

   function Trim
     (Source : Unbounded_Wide_Wide_String) return Unbounded_Wide_Wide_String;

   function From_Character
      (C : Wide_Wide_Character) return Unbounded_Wide_Wide_String;

   ---------------------------------------------------------------------------
   --  UTF-8 Boundary Operations (FUNC-UTF8-003, FUNC-UTF8-007)
   ---------------------------------------------------------------------------

   --  @summary Encode an Unbounded_Wide_Wide_String as a UTF-8 String.
   --
   --  @description
   --  Total function; never raises (NFR-UTF8-005). Pre-scans Source
   --  element-by-element:
   --    - Wide_Wide_Character values with Pos in 16#D800#..16#DFFF#
   --      (surrogate range) are substituted with U+FFFD (FUNC-UTF8-007).
   --    - Wide_Wide_Character values with Pos > 16#10FFFF# (beyond Unicode
   --      scalar range, possible because Wide_Wide_Character spans
   --      U+0000..U+7FFFFFFF) are also substituted with U+FFFD before
   --      encoding (FUNC-UTF8-007 extended for symmetry with the wide backend).
   --  After substitution, encodes using
   --  Ada.Strings.UTF_Encoding.Wide_Wide_Strings.Encode (UTF_8, no BOM).
   --  ASCII-only input passes through byte-for-byte (FUNC-UTF8-005).
   --  The result is always well-formed UTF-8 (FUNC-UTF8-006).
   --
   --  @param Source  The Unbounded_Wide_Wide_String to encode.
   --  @return        Well-formed UTF-8 byte sequence as a Standard.String.
   --  @relation FUNC-UTF8-003, FUNC-UTF8-005, FUNC-UTF8-006, FUNC-UTF8-007, NFR-UTF8-005
   function To_UTF_8 (Source : Unbounded_Wide_Wide_String) return String;

   ---------------------------------------------------------------------------
   --  Character Classification & Case Mapping
   ---------------------------------------------------------------------------
   --  Delegates to Ada.Wide_Wide_Characters.Handling. Is_Graphic is not
   --  provided natively; approximated as "not Is_Control". This backend
   --  is Unicode-aware: Is_Whitespace includes ASCII + Unicode space
   --  separators; Is_Line_Terminator covers LF, CR, NEL (U+0085),
   --  LS (U+2028), PS (U+2029).
   --  Wide_Wide_Character values outside U+0000..U+10FFFF or in the
   --  surrogate range U+D800..U+DFFF fall back to safe defaults
   --  (classifiers return False, To_Lower/To_Upper return the input).

   function Char_Is_Alphanumeric (C : Wide_Wide_Character) return Boolean;

   function Char_Is_Control (C : Wide_Wide_Character) return Boolean;

   function Char_Is_Digit (C : Wide_Wide_Character) return Boolean;

   function Char_Is_Graphic (C : Wide_Wide_Character) return Boolean;

   function Char_Is_Hex_Digit (C : Wide_Wide_Character) return Boolean;

   function Char_Is_Letter (C : Wide_Wide_Character) return Boolean;

   function Char_Is_Line_Terminator (C : Wide_Wide_Character) return Boolean;

   function Char_Is_Lower (C : Wide_Wide_Character) return Boolean;

   function Char_Is_Upper (C : Wide_Wide_Character) return Boolean;

   function Char_Is_Whitespace (C : Wide_Wide_Character) return Boolean;

   function Char_To_Lower (C : Wide_Wide_Character) return Wide_Wide_Character;

   function Char_To_Upper (C : Wide_Wide_Character) return Wide_Wide_Character;

   --  Filesystem Operations (FUNC-DIR-002..006, NFR-DIR-001)
   --  Path encoding: To_UTF_8 (surrogate + out-of-range substitution then
   --  Ada.Strings.UTF_Encoding.Wide_Wide_Strings.Encode; unconditional UTF-8
   --  per FUNC-DIR-007).

   --  @relation FUNC-DIR-001
   type File_Kind is (Directory, Ordinary_File, Special_File);

   --  @relation FUNC-DIR-002, NFR-DIR-001
   function Path_Exists (Path : Unbounded_Wide_Wide_String) return Boolean;

   --  @relation FUNC-DIR-003, NFR-DIR-001
   function Path_Kind (Path : Unbounded_Wide_Wide_String) return File_Kind;

   --  @relation FUNC-DIR-004, NFR-DIR-001
   function Create_Directory_Path
     (Path : Unbounded_Wide_Wide_String) return Boolean;

   --  @relation FUNC-DIR-005, NFR-DIR-001
   function Delete_File_Path
     (Path : Unbounded_Wide_Wide_String) return Boolean;

   --  @relation FUNC-DIR-006, NFR-DIR-001
   function Rename_Path
     (Old_Path, New_Path : Unbounded_Wide_Wide_String) return Boolean;

end Wide_Wide_String_Operations;
