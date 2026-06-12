-------------------------------------------------------------------------------
--  String_Types - VSS Configuration
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Re-exports string types and operations from the VSS instantiation.
--
--  @description
--  This is the VSS variant of String_Types. It provides full Unicode
--  support backed by VSS.Strings.Virtual_String. Length and Element
--  operate on Unicode code points (Virtual_Character), matching the
--  uxstring backend's semantics.
--
--  To use this variant, set `STRING_TYPE` environment variable to `vss`.

with Ada.Containers;
with Anystrings_UTF_8;
with VSS.Strings;
with VSS_Operations;
with VSS_Strings;
with VSS_UTF_8_Bridge;
with VSS_UTF_8_Results;
package String_Types is

   subtype String_Type is VSS.Strings.Virtual_String;
   subtype Character_Type is Wide_Wide_Character;

   Empty_String : constant String_Type := VSS_Strings.Empty_String;

   function Length (Source : String_Type) return Natural
     renames VSS_Operations.Length;

   function Is_Empty (Source : String_Type) return Boolean
     renames VSS_Operations.Is_Empty;

   function Get_Length (Source : String_Type) return Natural
     renames VSS_Strings.Get_Length;

   function Is_Null_Or_Empty (Source : String_Type) return Boolean
     renames VSS_Strings.Is_Null_Or_Empty;

   function Element
     (Source : String_Type;
      Index  : Positive) return Character_Type
     renames VSS_Operations.Element;

   function Get_Element
     (Source : String_Type;
      Index  : Positive) return Character_Type
     renames VSS_Strings.Get_Element;

   function First_Index (Source : String_Type) return Positive
     renames VSS_Strings.First_Index;

   function Last_Index (Source : String_Type) return Natural
     renames VSS_Strings.Last_Index;


   function Contains (Source : String_Type; Pattern : String_Type) return Boolean
     renames VSS_Strings.Contains;

   function Concat
     (Left  : String_Type;
      Right : String_Type) return String_Type
     renames VSS_Strings.Concat;

   function Append_Character
     (Left  : String_Type;
      Right : Character_Type) return String_Type
     renames VSS_Strings.Append_Character;

   function Prepend_Character
     (Left  : Character_Type;
      Right : String_Type) return String_Type
     renames VSS_Strings.Prepend_Character;

   function "&"
     (Left  : String_Type;
      Right : String_Type) return String_Type
     renames VSS_Operations.Concat_Strings;

   function "&"
     (Left  : String_Type;
      Right : Character_Type) return String_Type
     renames VSS_Operations.Concat_String_Character;

   function "&"
     (Left  : Character_Type;
      Right : String_Type) return String_Type
     renames VSS_Operations.Concat_Character_String;

   function "&"
     (Left  : String_Type;
      Right : String) return String_Type
     renames VSS_Operations.Concat_String_Latin_1;

   function "&"
     (Left  : String;
      Right : String_Type) return String_Type
     renames VSS_Operations.Concat_Latin_1_String;

   function "=" (Left, Right : String_Type) return Boolean
     renames VSS_Strings.Equal;

   function "<" (Left, Right : String_Type) return Boolean
     renames VSS_Strings.Less_Than;

   function "<=" (Left, Right : String_Type) return Boolean
     renames VSS_Strings.Less_Or_Equal;

   function ">" (Left, Right : String_Type) return Boolean
     renames VSS_Strings.Greater_Than;

   function ">=" (Left, Right : String_Type) return Boolean
     renames VSS_Strings.Greater_Or_Equal;

   function To_String_Type (Source : String) return String_Type
     renames VSS_Operations.To_Virtual_String;

   function To_Latin_1 (Source : String_Type) return String
     renames VSS_Operations.To_String;

   --  ----- UTF-8 boundary (FUNC-UTF8-001..013, NFR-UTF8-006) -----

   --  @relation FUNC-UTF8-001, FUNC-UTF8-002, FUNC-UTF8-003, FUNC-UTF8-008,
   --            FUNC-UTF8-013, NFR-UTF8-006

   subtype UTF_8_Decode_Error is Anystrings_UTF_8.UTF_8_Decode_Error;

   --  Re-export enum literals so that "use String_Types" makes them
   --  directly visible to callers (a subtype alone does not do this in Ada).
   Invalid_Lead_Byte      : constant UTF_8_Decode_Error :=
     Anystrings_UTF_8.Invalid_Lead_Byte;
   Truncated_Sequence     : constant UTF_8_Decode_Error :=
     Anystrings_UTF_8.Truncated_Sequence;
   Invalid_Continuation   : constant UTF_8_Decode_Error :=
     Anystrings_UTF_8.Invalid_Continuation;
   Overlong_Encoding      : constant UTF_8_Decode_Error :=
     Anystrings_UTF_8.Overlong_Encoding;
   Surrogate_Code_Point   : constant UTF_8_Decode_Error :=
     Anystrings_UTF_8.Surrogate_Code_Point;
   Code_Point_Out_Of_Range : constant UTF_8_Decode_Error :=
     Anystrings_UTF_8.Code_Point_Out_Of_Range;

   function "=" (Left, Right : UTF_8_Decode_Error) return Boolean
     renames Anystrings_UTF_8."=";

   subtype UTF_8_Decode_Result is VSS_UTF_8_Results.UTF_8_Decode_Result;

   function To_UTF_8 (Source : String_Type) return String
     renames VSS_Operations.To_UTF_8;

   function From_UTF_8 (Source : String) return UTF_8_Decode_Result
     renames VSS_UTF_8_Bridge.From_UTF_8_VSS;

   function Is_Ok (R : UTF_8_Decode_Result) return Boolean
     renames VSS_UTF_8_Results.Is_Ok;

   function Get_Value (R : UTF_8_Decode_Result) return String_Type
     renames VSS_UTF_8_Results.Get_Value;

   --  @relation FUNC-UTF8-014, NFR-UTF8-002
   function Get_Value_Or
     (R        : UTF_8_Decode_Result;
      Fallback : String_Type) return String_Type
     renames VSS_UTF_8_Results.Get_Value_Or;

   function Get_Error (R : UTF_8_Decode_Result) return UTF_8_Decode_Error
     renames VSS_UTF_8_Results.Get_Error;

   function As_UTF_8 (Source : String_Type) return String
     renames VSS_Strings.As_UTF_8;

   function Decode_UTF_8 (Source : String) return UTF_8_Decode_Result
     renames VSS_Strings.Decode_UTF_8;

   function UTF_8_Is_Valid (Source : String) return Boolean
     renames VSS_Strings.UTF_8_Is_Valid;

   function Hash (Key : String_Type) return Ada.Containers.Hash_Type
     renames VSS_Operations.Hash;

   function Slice
     (Source : String_Type;
      Low    : Positive;
      High   : Natural) return String_Type
     renames VSS_Operations.Slice;

   function Index
     (Source  : String_Type;
      Pattern : String_Type) return Natural
     renames VSS_Operations.Index;

   function Index
     (Source  : String_Type;
      Pattern : String) return Natural
     renames VSS_Operations.Index_Latin_1;

   function Index_From
     (Source      : String_Type;
      Pattern     : String_Type;
      Starting_At : Positive) return Natural
     renames VSS_Operations.Index_From;

   function Index_From
     (Source      : String_Type;
      Pattern     : String;
      Starting_At : Positive) return Natural
   is (VSS_Operations.Index_From
         (Source, VSS_Operations.To_Virtual_String (Pattern), Starting_At));

   function Index_Reverse (Source : String_Type; Pattern : String_Type) return Natural
     renames VSS_Operations.Index_Reverse;

   function Replace
     (Source  : String_Type;
      Pattern : String_Type;
      By      : String_Type) return String_Type
     renames VSS_Strings.Replace;

   function Replace
     (Source  : String_Type;
      Pattern : String;
      By      : String_Type) return String_Type
   is (VSS_Strings.Replace (Source, VSS_Operations.To_Virtual_String (Pattern), By));

   function Replace
     (Source  : String_Type;
      Pattern : String_Type;
      By      : String) return String_Type
   is (VSS_Strings.Replace (Source, Pattern, VSS_Operations.To_Virtual_String (By)));

   function Head (Source : String_Type; Count : Natural; Pad : Character_Type) return String_Type
     renames VSS_Strings.Head;

   function Tail (Source : String_Type; Count : Natural; Pad : Character_Type) return String_Type
     renames VSS_Strings.Tail;

   function To_Lower (Source : String_Type) return String_Type
     renames VSS_Operations.To_Lower;

   function To_Upper (Source : String_Type) return String_Type
     renames VSS_Operations.To_Upper;

   function Starts_With
     (Source : String_Type;
      Prefix : String_Type) return Boolean
     renames VSS_Operations.Starts_With;

   function Starts_With
     (Source : String_Type;
      Prefix : String) return Boolean
     renames VSS_Operations.Starts_With_Latin_1;

   function Ends_With
     (Source : String_Type;
      Suffix : String_Type) return Boolean
     renames VSS_Operations.Ends_With;

   function Trim (Source : String_Type) return String_Type
     renames VSS_Operations.Trim;

   function From_Character (C : Character_Type) return String_Type
     renames VSS_Operations.From_Character;

   function Is_Equals_Sign (C : Character_Type) return Boolean
   is (Wide_Wide_Character'Pos (C) = Character'Pos ('='));

   function Is_Dash (C : Character_Type) return Boolean
   is (Wide_Wide_Character'Pos (C) = Character'Pos ('-'));

   ---------------------------------------------------------------------------
   --  Character Classification & Case Mapping
   ---------------------------------------------------------------------------
   --  Unicode-aware via Ada.Wide_Wide_Characters.Handling (guarded against
   --  surrogates and code points > U+10FFFF). Is_Whitespace includes
   --  ASCII + Unicode Space_Separator. Is_Line_Terminator covers LF, CR,
   --  NEL (U+0085), LS (U+2028), PS (U+2029).

   function Is_Alphanumeric (C : Character_Type) return Boolean
     renames VSS_Operations.Char_Is_Alphanumeric;

   function Is_Control (C : Character_Type) return Boolean
     renames VSS_Operations.Char_Is_Control;

   function Is_Digit (C : Character_Type) return Boolean
     renames VSS_Operations.Char_Is_Digit;

   function Is_Graphic (C : Character_Type) return Boolean
     renames VSS_Operations.Char_Is_Graphic;

   function Is_Hex_Digit (C : Character_Type) return Boolean
     renames VSS_Operations.Char_Is_Hex_Digit;

   function Is_Letter (C : Character_Type) return Boolean
     renames VSS_Operations.Char_Is_Letter;

   function Is_Line_Terminator (C : Character_Type) return Boolean
     renames VSS_Operations.Char_Is_Line_Terminator;

   function Is_Lower (C : Character_Type) return Boolean
     renames VSS_Operations.Char_Is_Lower;

   function Is_Upper (C : Character_Type) return Boolean
     renames VSS_Operations.Char_Is_Upper;

   function Is_Whitespace (C : Character_Type) return Boolean
     renames VSS_Operations.Char_Is_Whitespace;

   function To_Lower (C : Character_Type) return Character_Type
     renames VSS_Operations.Char_To_Lower;

   function To_Upper (C : Character_Type) return Character_Type
     renames VSS_Operations.Char_To_Upper;

   ---------------------------------------------------------------------------



end String_Types;
