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
with UXString_UTF_8_Bridge;
with UXString_WWS_Bridge;

package body String_Types
  with SPARK_Mode => Off
is

   function Wrap (Source : UXStrings.UXString) return String_Type
   is ((Value => Source));

   function Length (Source : String_Type) return Natural
   is (UXString_Operations.Length (Source.Value));

   function Is_Empty (Source : String_Type) return Boolean
   is (UXString_Operations.Is_Empty (Source.Value));

   function Get_Length (Source : String_Type) return Natural
   is (UXString_Strings.Get_Length (Source.Value));

   function Is_Null_Or_Empty (Source : String_Type) return Boolean
   is (UXString_Strings.Is_Null_Or_Empty (Source.Value));

   function Element (Source : String_Type; Index : Positive) return Character_Type
   is (UXString_Operations.Element (Source.Value, Index));

   function Get_Element (Source : String_Type; Index : Positive) return Character_Type
   is (UXString_Strings.Get_Element (Source.Value, Index));

   function First_Index (Source : String_Type) return Positive
   is (UXString_Strings.First_Index (Source.Value));

   function Last_Index (Source : String_Type) return Natural
   is (UXString_Strings.Last_Index (Source.Value));

   function Contains (Source : String_Type; Pattern : String_Type) return Boolean
   is (UXString_Strings.Contains (Source.Value, Pattern.Value));

   function "&" (Left : String_Type; Right : String_Type) return String_Type
   is (Wrap (UXString_Operations.Concat_Strings (Left.Value, Right.Value)));

   function "&" (Left : String_Type; Right : Character_Type) return String_Type
   is (Wrap (UXString_Operations.Concat_String_Character (Left.Value, Right)));

   function "&" (Left : Character_Type; Right : String_Type) return String_Type
   is (Wrap (UXString_Operations.Concat_Character_String (Left, Right.Value)));

   function "&" (Left : String_Type; Right : String) return String_Type
   is (Wrap (UXString_Operations.Concat_String_Latin_1 (Left.Value, Right)));

   function "&" (Left : String; Right : String_Type) return String_Type
   is (Wrap (UXString_Operations.Concat_Latin_1_String (Left, Right.Value)));

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

   overriding function "=" (Left, Right : String_Type) return Boolean
   is (UXString_Strings.Equal (Left.Value, Right.Value));

   function "<" (Left, Right : String_Type) return Boolean
   is (UXString_Strings.Less_Than (Left.Value, Right.Value));

   function "<=" (Left, Right : String_Type) return Boolean
   is (UXString_Strings.Less_Or_Equal (Left.Value, Right.Value));

   function ">" (Left, Right : String_Type) return Boolean
   is (UXString_Strings.Greater_Than (Left.Value, Right.Value));

   function ">=" (Left, Right : String_Type) return Boolean
   is (UXString_Strings.Greater_Or_Equal (Left.Value, Right.Value));

   function To_String_Type (Source : String) return String_Type
   is (Wrap (UXString_Operations.To_UXString (Source)));

   function To_Latin_1 (Source : String_Type) return String
   is (UXString_Operations.To_String (Source.Value));

   function To_UTF_8 (Source : String_Type) return String
   is (UXString_Operations.To_UTF_8 (Source.Value));

   function From_UTF_8 (Source : String) return UTF_8_Decode_Result
   is ((Inner => UXString_UTF_8_Bridge.From_UTF_8_UXString (Source)));

   function To_Wide_Wide_String (Source : String_Type) return Wide_Wide_String
   is (UXString_Operations.To_Wide_Wide_String (Source.Value));

   function From_Wide_Wide_String (Source : Wide_Wide_String) return String_Type
   is (Wrap (UXString_Operations.From_Wide_Wide_String (Source)));

   function Is_Ok (R : WWS_Decode_Result) return Boolean
   is (UXString_WWS_Decode_Results.Is_Ok (R.Inner));

   function Get_Value (R : WWS_Decode_Result) return String_Type
   is (Wrap (UXString_WWS_Decode_Results.Get_Value (R.Inner)));

   function Get_Value_Or (R : WWS_Decode_Result; Fallback : String_Type) return String_Type
   is (Wrap (UXString_WWS_Decode_Results.Get_Value_Or (R.Inner, Fallback.Value)));

   function Get_Error (R : WWS_Decode_Result) return WWS_Failure
   is (UXString_WWS_Decode_Results.Get_Error (R.Inner));

   function From_Wide_Wide_String_With_Substitute
     (Source : Wide_Wide_String; Substitute : Wide_Wide_Character) return String_Type
   is (Wrap (UXString_Operations.From_Wide_Wide_String_With_Substitute (Source, Substitute)));

   function From_Wide_Wide_String_Skip_Invalid (Source : Wide_Wide_String) return String_Type
   is (Wrap (UXString_Operations.From_Wide_Wide_String_Skip_Invalid (Source)));

   function From_Wide_Wide_String_Checked (Source : Wide_Wide_String) return WWS_Decode_Result
   is ((Inner => UXString_WWS_Bridge.From_Wide_Wide_String_UXString_Checked (Source)));

   function Is_Ok (R : UTF_8_Decode_Result) return Boolean
   is (UXString_UTF_8_Results.Is_Ok (R.Inner));

   function Get_Value (R : UTF_8_Decode_Result) return String_Type
   is (Wrap (UXString_UTF_8_Results.Get_Value (R.Inner)));

   function Get_Value_Or (R : UTF_8_Decode_Result; Fallback : String_Type) return String_Type
   is (Wrap (UXString_UTF_8_Results.Get_Value_Or (R.Inner, Fallback.Value)));

   function Get_Error (R : UTF_8_Decode_Result) return UTF_8_Decode_Error
   is (UXString_UTF_8_Results.Get_Error (R.Inner));

   function As_UTF_8 (Source : String_Type) return String
   is (UXString_Strings.As_UTF_8 (Source.Value));

   function Decode_UTF_8 (Source : String) return UTF_8_Decode_Result
   is ((Inner => UXString_Strings.Decode_UTF_8 (Source)));

   function UTF_8_Is_Valid (Source : String) return Boolean
   is (UXString_Strings.UTF_8_Is_Valid (Source));

   function Hash (Key : String_Type) return Ada.Containers.Hash_Type
   is (UXString_Operations.Hash (Key.Value));

   function Slice (Source : String_Type; Low : Positive; High : Natural) return String_Type
   is (Wrap (UXString_Operations.Slice (Source.Value, Low, High)));

   function Index (Source : String_Type; Pattern : String_Type) return Natural
   is (UXString_Operations.Index (Source.Value, Pattern.Value));

   function Index (Source : String_Type; Pattern : String) return Natural
   is (UXString_Operations.Index_Latin_1 (Source.Value, Pattern));

   function Index_From (Source : String_Type; Pattern : String_Type; Starting_At : Positive) return Natural
   is (UXString_Operations.Index_From (Source.Value, Pattern.Value, Starting_At));

   function Index_Reverse (Source : String_Type; Pattern : String_Type) return Natural
   is (UXString_Operations.Index_Reverse (Source.Value, Pattern.Value));

   function Replace (Source : String_Type; Pattern : String_Type; By : String_Type) return String_Type
   is (Wrap (UXString_Strings.Replace (Source.Value, Pattern.Value, By.Value)));

   function Head (Source : String_Type; Count : Natural; Pad : Character_Type) return String_Type
   is (Wrap (UXString_Strings.Head (Source.Value, Count, Pad)));

   function Tail (Source : String_Type; Count : Natural; Pad : Character_Type) return String_Type
   is (Wrap (UXString_Strings.Tail (Source.Value, Count, Pad)));

   function To_Lower (Source : String_Type) return String_Type
   is (Wrap (UXString_Operations.To_Lower (Source.Value)));

   function To_Upper (Source : String_Type) return String_Type
   is (Wrap (UXString_Operations.To_Upper (Source.Value)));

   function Starts_With (Source : String_Type; Prefix : String_Type) return Boolean
   is (UXString_Operations.Starts_With (Source.Value, Prefix.Value));

   function Starts_With (Source : String_Type; Prefix : String) return Boolean
   is (UXString_Operations.Starts_With_Latin_1 (Source.Value, Prefix));

   function Ends_With (Source : String_Type; Suffix : String_Type) return Boolean
   is (UXString_Operations.Ends_With (Source.Value, Suffix.Value));

   function Trim (Source : String_Type) return String_Type
   is (Wrap (UXString_Operations.Trim (Source.Value)));

   function From_Character (C : Character_Type) return String_Type
   is (Wrap (UXString_Operations.From_Character (C)));

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
