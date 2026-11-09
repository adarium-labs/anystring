-------------------------------------------------------------------------------
--  String_Types - UXString Configuration (bodies)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Bodies of String_Types on the uxstring backend: every operation unwraps its
--  String_Type operands, calls the UXStrings-typed implementation and wraps
--  the result.
--
--  @description
--  SPARK_Mode is Off: the contracts declared in the specification are
--  trusted, not proved, on this backend. Run-time checks of those contracts
--  are performed by the test suite, which is built with assertions enabled.
--  See src/strings/AGENTS.md ("Proof boundaries").

with UXString_Operations;
with UXString_Strings;
with UXString_Wrapper.Convert;
with UXString_UTF_8_Bridge;
with UXString_WWS_Bridge;

package body String_Types
  with SPARK_Mode => Off
is

   package Conv renames UXString_Wrapper.Convert;

   function Is_Empty (Source : String_Type) return Boolean
   is (UXString_Operations.Is_Empty (Conv.To_UXString (Source)));

   function Get_Length (Source : String_Type) return Natural
   is (UXString_Strings.Get_Length (Conv.To_UXString (Source)));

   function Is_Null_Or_Empty (Source : String_Type) return Boolean
   is (UXString_Strings.Is_Null_Or_Empty (Conv.To_UXString (Source)));

   function Element (Source : String_Type; Index : Positive) return Character_Type
   is (UXString_Operations.Element (Conv.To_UXString (Source), Index));

   function Get_Element (Source : String_Type; Index : Positive) return Character_Type
   is (UXString_Strings.Get_Element (Conv.To_UXString (Source), Index));

   function First_Index (Source : String_Type) return Positive
   is (UXString_Strings.First_Index (Conv.To_UXString (Source)));

   function Last_Index (Source : String_Type) return Natural
   is (UXString_Strings.Last_Index (Conv.To_UXString (Source)));

   function Contains (Source : String_Type; Pattern : String_Type) return Boolean
   is (UXString_Strings.Contains (Conv.To_UXString (Source), Conv.To_UXString (Pattern)));

   function "&" (Left : String_Type; Right : String_Type) return String_Type
   is (Conv.From_UXString (UXString_Operations.Concat_Strings (Conv.To_UXString (Left), Conv.To_UXString (Right))));

   function "&" (Left : String_Type; Right : Character_Type) return String_Type
   is (Conv.From_UXString (UXString_Operations.Concat_String_Character (Conv.To_UXString (Left), Right)));

   function "&" (Left : Character_Type; Right : String_Type) return String_Type
   is (Conv.From_UXString (UXString_Operations.Concat_Character_String (Left, Conv.To_UXString (Right))));

   function "&" (Left : String_Type; Right : String) return String_Type
   is (Conv.From_UXString (UXString_Operations.Concat_String_Latin_1 (Conv.To_UXString (Left), Right)));

   function "&" (Left : String; Right : String_Type) return String_Type
   is (Conv.From_UXString (UXString_Operations.Concat_Latin_1_String (Left, Conv.To_UXString (Right))));

   function Concat (Left : String_Type; Right : String_Type) return String_Type
   is (Left & Right);

   function Append_Character (Left : String_Type; Right : Character_Type) return String_Type
   is (Left & Right);

   function Prepend_Character (Left : Character_Type; Right : String_Type) return String_Type
   is (Left & Right);

   procedure Append (Source : in out String_Type; New_Item : String_Type) is
   begin
      Source := Source & New_Item;
   end Append;

   function "=" (Left, Right : String_Type) return Boolean
   is (UXString_Strings.Equal (Conv.To_UXString (Left), Conv.To_UXString (Right)));

   function "<" (Left, Right : String_Type) return Boolean
   is (UXString_Strings.Less_Than (Conv.To_UXString (Left), Conv.To_UXString (Right)));

   function "<=" (Left, Right : String_Type) return Boolean
   is (UXString_Strings.Less_Or_Equal (Conv.To_UXString (Left), Conv.To_UXString (Right)));

   function ">" (Left, Right : String_Type) return Boolean
   is (UXString_Strings.Greater_Than (Conv.To_UXString (Left), Conv.To_UXString (Right)));

   function ">=" (Left, Right : String_Type) return Boolean
   is (UXString_Strings.Greater_Or_Equal (Conv.To_UXString (Left), Conv.To_UXString (Right)));

   function To_String_Type (Source : String) return String_Type
   is (Conv.From_UXString (UXString_Operations.To_UXString (Source)));

   function To_Latin_1 (Source : String_Type) return String
   is (UXString_Operations.To_String (Conv.To_UXString (Source)));

   function To_UTF_8 (Source : String_Type) return String
   is (UXString_Operations.To_UTF_8 (Conv.To_UXString (Source)));

   function From_UTF_8 (Source : String) return UTF_8_Decode_Result
   is ((Inner => UXString_UTF_8_Bridge.From_UTF_8_UXString (Source)));

   function To_Wide_Wide_String (Source : String_Type) return Wide_Wide_String
   is (UXString_Operations.To_Wide_Wide_String (Conv.To_UXString (Source)));

   function From_Wide_Wide_String (Source : Wide_Wide_String) return String_Type
   is (Conv.From_UXString (UXString_Operations.From_Wide_Wide_String (Source)));

   function Is_Ok (R : WWS_Decode_Result) return Boolean
   is (UXString_WWS_Decode_Results.Is_Ok (R.Inner));

   function Get_Value (R : WWS_Decode_Result) return String_Type
   is (Conv.From_UXString (UXString_WWS_Decode_Results.Get_Value (R.Inner)));

   function Get_Value_Or (R : WWS_Decode_Result; Fallback : String_Type) return String_Type
   is (Conv.From_UXString (UXString_WWS_Decode_Results.Get_Value_Or (R.Inner, Conv.To_UXString (Fallback))));

   function Get_Error (R : WWS_Decode_Result) return WWS_Failure
   is (UXString_WWS_Decode_Results.Get_Error (R.Inner));

   function From_Wide_Wide_String_With_Substitute
     (Source : Wide_Wide_String; Substitute : Wide_Wide_Character) return String_Type
   is (Conv.From_UXString (UXString_Operations.From_Wide_Wide_String_With_Substitute (Source, Substitute)));

   function From_Wide_Wide_String_Skip_Invalid (Source : Wide_Wide_String) return String_Type
   is (Conv.From_UXString (UXString_Operations.From_Wide_Wide_String_Skip_Invalid (Source)));

   function From_Wide_Wide_String_Checked (Source : Wide_Wide_String) return WWS_Decode_Result
   is ((Inner => UXString_WWS_Bridge.From_Wide_Wide_String_UXString_Checked (Source)));

   function Is_Ok (R : UTF_8_Decode_Result) return Boolean
   is (UXString_UTF_8_Results.Is_Ok (R.Inner));

   function Get_Value (R : UTF_8_Decode_Result) return String_Type
   is (Conv.From_UXString (UXString_UTF_8_Results.Get_Value (R.Inner)));

   function Get_Value_Or (R : UTF_8_Decode_Result; Fallback : String_Type) return String_Type
   is (Conv.From_UXString (UXString_UTF_8_Results.Get_Value_Or (R.Inner, Conv.To_UXString (Fallback))));

   function Get_Error (R : UTF_8_Decode_Result) return UTF_8_Decode_Error
   is (UXString_UTF_8_Results.Get_Error (R.Inner));

   function As_UTF_8 (Source : String_Type) return String
   is (UXString_Strings.As_UTF_8 (Conv.To_UXString (Source)));

   function Decode_UTF_8 (Source : String) return UTF_8_Decode_Result
   is ((Inner => UXString_Strings.Decode_UTF_8 (Source)));

   function UTF_8_Is_Valid (Source : String) return Boolean
   is (UXString_Strings.UTF_8_Is_Valid (Source));

   function Hash (Key : String_Type) return Ada.Containers.Hash_Type
   is (UXString_Operations.Hash (Conv.To_UXString (Key)));

   function Slice (Source : String_Type; Low : Positive; High : Natural) return String_Type
   is (Conv.From_UXString (UXString_Operations.Slice (Conv.To_UXString (Source), Low, High)));

   function Index (Source : String_Type; Pattern : String_Type) return Natural
   is (UXString_Operations.Index (Conv.To_UXString (Source), Conv.To_UXString (Pattern)));

   function Index (Source : String_Type; Pattern : String) return Natural
   is (UXString_Operations.Index_Latin_1 (Conv.To_UXString (Source), Pattern));

   function Index_From (Source : String_Type; Pattern : String_Type; Starting_At : Positive) return Natural
   is (UXString_Operations.Index_From (Conv.To_UXString (Source), Conv.To_UXString (Pattern), Starting_At));

   function Index_Reverse (Source : String_Type; Pattern : String_Type) return Natural
   is (UXString_Operations.Index_Reverse (Conv.To_UXString (Source), Conv.To_UXString (Pattern)));

   function Replace (Source : String_Type; Pattern : String_Type; By : String_Type) return String_Type
   is (Conv.From_UXString
         (UXString_Strings.Replace (Conv.To_UXString (Source), Conv.To_UXString (Pattern), Conv.To_UXString (By))));

   function Head (Source : String_Type; Count : Natural; Pad : Character_Type) return String_Type
   is (Conv.From_UXString (UXString_Strings.Head (Conv.To_UXString (Source), Count, Pad)));

   function Tail (Source : String_Type; Count : Natural; Pad : Character_Type) return String_Type
   is (Conv.From_UXString (UXString_Strings.Tail (Conv.To_UXString (Source), Count, Pad)));

   function To_Lower (Source : String_Type) return String_Type
   is (Conv.From_UXString (UXString_Operations.To_Lower (Conv.To_UXString (Source))));

   function To_Upper (Source : String_Type) return String_Type
   is (Conv.From_UXString (UXString_Operations.To_Upper (Conv.To_UXString (Source))));

   function Starts_With (Source : String_Type; Prefix : String_Type) return Boolean
   is (UXString_Operations.Starts_With (Conv.To_UXString (Source), Conv.To_UXString (Prefix)));

   function Starts_With (Source : String_Type; Prefix : String) return Boolean
   is (UXString_Operations.Starts_With_Latin_1 (Conv.To_UXString (Source), Prefix));

   function Ends_With (Source : String_Type; Suffix : String_Type) return Boolean
   is (UXString_Operations.Ends_With (Conv.To_UXString (Source), Conv.To_UXString (Suffix)));

   function Trim (Source : String_Type) return String_Type
   is (Conv.From_UXString (UXString_Operations.Trim (Conv.To_UXString (Source))));

   function From_Character (C : Character_Type) return String_Type
   is (Conv.From_UXString (UXString_Operations.From_Character (C)));

   function Is_Alphanumeric (C : Character_Type) return Boolean
   is (UXString_Operations.Char_Is_Alphanumeric (C));

   function Is_Control (C : Character_Type) return Boolean
   is (UXString_Operations.Char_Is_Control (C));

   function Is_Digit (C : Character_Type) return Boolean
   is (UXString_Operations.Char_Is_Digit (C));

   function Is_Graphic (C : Character_Type) return Boolean
   is (UXString_Operations.Char_Is_Graphic (C));

   function Is_Hex_Digit (C : Character_Type) return Boolean
   is (UXString_Operations.Char_Is_Hex_Digit (C));

   function Is_Letter (C : Character_Type) return Boolean
   is (UXString_Operations.Char_Is_Letter (C));

   function Is_Line_Terminator (C : Character_Type) return Boolean
   is (UXString_Operations.Char_Is_Line_Terminator (C));

   function Is_Lower (C : Character_Type) return Boolean
   is (UXString_Operations.Char_Is_Lower (C));

   function Is_Upper (C : Character_Type) return Boolean
   is (UXString_Operations.Char_Is_Upper (C));

   function Is_Whitespace (C : Character_Type) return Boolean
   is (UXString_Operations.Char_Is_Whitespace (C));

   function To_Lower (C : Character_Type) return Character_Type
   is (UXString_Operations.Char_To_Lower (C));

   function To_Upper (C : Character_Type) return Character_Type
   is (UXString_Operations.Char_To_Upper (C));

end String_Types;
