-------------------------------------------------------------------------------
--  String_Types - Standard String Configuration
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Re-exports string types and operations from Standard_Strings.
--
--  @description
--  This is the Standard (Unbounded_String) variant of String_Types.
--  It uses Ada.Strings.Unbounded.Unbounded_String as the underlying type.

with Ada.Containers;
with Standard_Strings;
with Standard_String_Operations;
with Standard_UTF_8_Results;
with Standard_UTF_8_Bridge;
with Anystrings_UTF_8;
with Anystrings_Conv;
package String_Types is

   subtype String_Type is Standard_String_Operations.Unbounded_String;
   subtype Character_Type is Character;

   Empty_String : constant String_Type := Standard_Strings.Empty_String;

   function Length (Source : String_Type) return Natural renames Standard_String_Operations.Length;

   function Is_Empty (Source : String_Type) return Boolean renames Standard_String_Operations.Is_Empty;

   function Get_Length (Source : String_Type) return Natural renames Standard_Strings.Get_Length;

   function Is_Null_Or_Empty (Source : String_Type) return Boolean renames Standard_Strings.Is_Null_Or_Empty;

   function Element (Source : String_Type; Index : Positive) return Character_Type
   renames Standard_String_Operations.Element;

   function Get_Element (Source : String_Type; Index : Positive) return Character_Type
   renames Standard_Strings.Get_Element;

   function First_Index (Source : String_Type) return Positive renames Standard_Strings.First_Index;

   function Last_Index (Source : String_Type) return Natural renames Standard_Strings.Last_Index;


   function Contains (Source : String_Type; Pattern : String_Type) return Boolean renames Standard_Strings.Contains;

   function Concat (Left : String_Type; Right : String_Type) return String_Type renames Standard_Strings.Concat;

   function Append_Character (Left : String_Type; Right : Character_Type) return String_Type
   renames Standard_Strings.Append_Character;

   function Prepend_Character (Left : Character_Type; Right : String_Type) return String_Type
   renames Standard_Strings.Prepend_Character;

   function "&" (Left : String_Type; Right : String_Type) return String_Type
   renames Standard_String_Operations.Concat_Strings;

   function "&" (Left : String_Type; Right : Character_Type) return String_Type
   renames Standard_String_Operations.Concat_String_Character;

   function "&" (Left : Character_Type; Right : String_Type) return String_Type
   renames Standard_String_Operations.Concat_Character_String;

   function "&" (Left : String_Type; Right : String) return String_Type
   renames Standard_String_Operations.Concat_String_Latin_1;

   function "&" (Left : String; Right : String_Type) return String_Type
   renames Standard_String_Operations.Concat_Latin_1_String;

   function "=" (Left, Right : String_Type) return Boolean renames Standard_Strings.Equal;

   function "<" (Left, Right : String_Type) return Boolean renames Standard_Strings.Less_Than;

   function "<=" (Left, Right : String_Type) return Boolean renames Standard_Strings.Less_Or_Equal;

   function ">" (Left, Right : String_Type) return Boolean renames Standard_Strings.Greater_Than;

   function ">=" (Left, Right : String_Type) return Boolean renames Standard_Strings.Greater_Or_Equal;

   function To_String_Type (Source : String) return String_Type renames Standard_String_Operations.To_Unbounded_String;

   function To_Latin_1 (Source : String_Type) return String renames Standard_String_Operations.To_Latin_1;

   --  ----- Lossy-detection Latin-1 conversion (FUNC-CONV-008..010) -----

   --  @relation FUNC-CONV-008, FUNC-CONV-009, FUNC-CONV-010, NFR-CONV-005
   subtype Latin_1_Conv_Status is Anystrings_Conv.Latin_1_Conv_Status;
   subtype Latin_1_Conv_Result is Anystrings_Conv.Latin_1_Conv_Result;

   --  Re-export enumeration literals so they are directly visible to
   --  callers via "use String_Types" (a subtype alone does not do this).
   Ok    : constant Latin_1_Conv_Status := Anystrings_Conv.Ok;
   Lossy : constant Latin_1_Conv_Status := Anystrings_Conv.Lossy;

   function "=" (Left, Right : Latin_1_Conv_Status) return Boolean renames Anystrings_Conv."=";

   function Is_Ok (R : Latin_1_Conv_Result) return Boolean renames Anystrings_Conv.Is_Ok;
   function Get_Value (R : Latin_1_Conv_Result) return String renames Anystrings_Conv.Get_Value;
   function Get_Replaced_Count (R : Latin_1_Conv_Result) return Natural
     renames Anystrings_Conv.Get_Replaced_Count;

   function To_Latin_1_If_Possible (Source : String_Type) return Latin_1_Conv_Result
     renames Standard_String_Operations.To_Latin_1_If_Possible;

   --  ----- UTF-8 boundary (FUNC-UTF8-001..013, NFR-UTF8-006) -----

   --  @relation FUNC-UTF8-001, FUNC-UTF8-002, FUNC-UTF8-003, FUNC-UTF8-008, NFR-UTF8-006

   subtype UTF_8_Decode_Error is Anystrings_UTF_8.UTF_8_Decode_Error;

   --  Re-export enum literals so that "use String_Types" makes them
   --  directly visible to callers (a subtype alone does not do this in Ada).
   Invalid_Lead_Byte       : constant UTF_8_Decode_Error := Anystrings_UTF_8.Invalid_Lead_Byte;
   Truncated_Sequence      : constant UTF_8_Decode_Error := Anystrings_UTF_8.Truncated_Sequence;
   Invalid_Continuation    : constant UTF_8_Decode_Error := Anystrings_UTF_8.Invalid_Continuation;
   Overlong_Encoding       : constant UTF_8_Decode_Error := Anystrings_UTF_8.Overlong_Encoding;
   Surrogate_Code_Point    : constant UTF_8_Decode_Error := Anystrings_UTF_8.Surrogate_Code_Point;
   Code_Point_Out_Of_Range : constant UTF_8_Decode_Error := Anystrings_UTF_8.Code_Point_Out_Of_Range;

   function "=" (Left, Right : UTF_8_Decode_Error) return Boolean renames Anystrings_UTF_8."=";

   subtype UTF_8_Decode_Result is Standard_UTF_8_Results.UTF_8_Decode_Result;

   function To_UTF_8 (Source : String_Type) return String renames Standard_String_Operations.To_UTF_8;

   function From_UTF_8 (Source : String) return UTF_8_Decode_Result renames Standard_UTF_8_Bridge.From_UTF_8_Standard;

   function Is_Ok (R : UTF_8_Decode_Result) return Boolean renames Standard_UTF_8_Results.Is_Ok;

   function Get_Value (R : UTF_8_Decode_Result) return String_Type renames Standard_UTF_8_Results.Get_Value;

   --  @relation FUNC-UTF8-014, NFR-UTF8-002
   function Get_Value_Or
     (R        : UTF_8_Decode_Result;
      Fallback : String_Type) return String_Type
     renames Standard_UTF_8_Results.Get_Value_Or;

   function Get_Error (R : UTF_8_Decode_Result) return UTF_8_Decode_Error renames Standard_UTF_8_Results.Get_Error;

   function As_UTF_8 (Source : String_Type) return String renames Standard_Strings.As_UTF_8;

   function Decode_UTF_8 (Source : String) return UTF_8_Decode_Result renames Standard_Strings.Decode_UTF_8;

   function UTF_8_Is_Valid (Source : String) return Boolean renames Standard_Strings.UTF_8_Is_Valid;

   function Hash (Key : String_Type) return Ada.Containers.Hash_Type renames Standard_String_Operations.Hash;

   function Slice (Source : String_Type; Low : Positive; High : Natural) return String_Type
   renames Standard_String_Operations.Slice;

   function Index (Source : String_Type; Pattern : String_Type) return Natural renames Standard_String_Operations.Index;

   function Index (Source : String_Type; Pattern : String) return Natural
   renames Standard_String_Operations.Index_Latin_1;

   function Index_From
     (Source      : String_Type;
      Pattern     : String_Type;
      Starting_At : Positive) return Natural
   renames Standard_String_Operations.Index_From;

   function Index_From
     (Source      : String_Type;
      Pattern     : String;
      Starting_At : Positive) return Natural
   is (Standard_String_Operations.Index_From
         (Source, Standard_String_Operations.To_Unbounded_String (Pattern), Starting_At));

   function Index_Reverse (Source : String_Type; Pattern : String_Type) return Natural
   renames Standard_String_Operations.Index_Reverse;

   function Replace
     (Source  : String_Type;
      Pattern : String_Type;
      By      : String_Type) return String_Type
   renames Standard_Strings.Replace;

   function Replace
     (Source  : String_Type;
      Pattern : String;
      By      : String_Type) return String_Type
   is (Standard_Strings.Replace (Source, Standard_String_Operations.To_Unbounded_String (Pattern), By));

   function Replace
     (Source  : String_Type;
      Pattern : String_Type;
      By      : String) return String_Type
   is (Standard_Strings.Replace (Source, Pattern, Standard_String_Operations.To_Unbounded_String (By)));

   function Head (Source : String_Type; Count : Natural; Pad : Character_Type) return String_Type
   renames Standard_Strings.Head;

   function Tail (Source : String_Type; Count : Natural; Pad : Character_Type) return String_Type
   renames Standard_Strings.Tail;

   function To_Lower (Source : String_Type) return String_Type renames Standard_String_Operations.To_Lower;

   function To_Upper (Source : String_Type) return String_Type renames Standard_String_Operations.To_Upper;

   function Starts_With (Source : String_Type; Prefix : String_Type) return Boolean
   renames Standard_String_Operations.Starts_With;

   function Starts_With (Source : String_Type; Prefix : String) return Boolean
   renames Standard_String_Operations.Starts_With_Latin_1;

   function Ends_With (Source : String_Type; Suffix : String_Type) return Boolean
   renames Standard_String_Operations.Ends_With;

   function Trim (Source : String_Type) return String_Type renames Standard_String_Operations.Trim;

   function From_Character (C : Character_Type) return String_Type renames Standard_String_Operations.From_Character;

   function Is_Equals_Sign (C : Character_Type) return Boolean
   is (C = '=');

   function Is_Dash (C : Character_Type) return Boolean
   is (C = '-');

   ---------------------------------------------------------------------------
   --  Character Classification & Case Mapping
   ---------------------------------------------------------------------------
   --  The standard backend's Character_Type is Latin-1; predicates classify
   --  Latin-1 code points only. Is_Whitespace = ASCII SP/HT/LF/VT/FF/CR.
   --  Is_Line_Terminator = LF/CR (LS/PS/NEL are not representable here).

   function Is_Alphanumeric (C : Character_Type) return Boolean
   renames Standard_String_Operations.Char_Is_Alphanumeric;

   function Is_Control (C : Character_Type) return Boolean
   renames Standard_String_Operations.Char_Is_Control;

   function Is_Digit (C : Character_Type) return Boolean
   renames Standard_String_Operations.Char_Is_Digit;

   function Is_Graphic (C : Character_Type) return Boolean
   renames Standard_String_Operations.Char_Is_Graphic;

   function Is_Hex_Digit (C : Character_Type) return Boolean
   renames Standard_String_Operations.Char_Is_Hex_Digit;

   function Is_Letter (C : Character_Type) return Boolean
   renames Standard_String_Operations.Char_Is_Letter;

   function Is_Line_Terminator (C : Character_Type) return Boolean
   renames Standard_String_Operations.Char_Is_Line_Terminator;

   function Is_Lower (C : Character_Type) return Boolean
   renames Standard_String_Operations.Char_Is_Lower;

   function Is_Upper (C : Character_Type) return Boolean
   renames Standard_String_Operations.Char_Is_Upper;

   function Is_Whitespace (C : Character_Type) return Boolean
   renames Standard_String_Operations.Char_Is_Whitespace;

   function To_Lower (C : Character_Type) return Character_Type
   renames Standard_String_Operations.Char_To_Lower;

   function To_Upper (C : Character_Type) return Character_Type
   renames Standard_String_Operations.Char_To_Upper;

   ---------------------------------------------------------------------------



end String_Types;
