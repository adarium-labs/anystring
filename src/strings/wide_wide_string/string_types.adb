-------------------------------------------------------------------------------
--  String_Types - Wide_Wide_String Configuration (bodies)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Bodies of String_Types on the wide_wide_string backend: every operation
--  unwraps its String_Type operands, calls the Unbounded_Wide_Wide_String
--  implementation and wraps the result.
--
--  @description
--  SPARK_Mode is Off: the contracts declared in the specification are
--  trusted, not proved, on this backend. Run-time checks of those contracts
--  are performed by the test suite, which is built with assertions enabled.
--  See src/strings/AGENTS.md ("Proof boundaries").

with Wide_Wide_Strings;
with Wide_Wide_UTF_8_Bridge;
with Wide_Wide_WWS_Bridge;

package body String_Types
  with SPARK_Mode => Off
is

   function Length (Source : String_Type) return Natural
   is (Ada.Strings.Wide_Wide_Unbounded.Length (Unwrap (Source)));

   function Null_String_Value return String_Type
   is (Empty_String);

   function Get_Length (Source : String_Type) return Natural
   is (Wide_Wide_Strings.Get_Length (Unwrap (Source)));

   function Is_Null_Or_Empty (Source : String_Type) return Boolean
   is (Wide_Wide_Strings.Is_Null_Or_Empty (Unwrap (Source)));

   function Is_Empty (Source : String_Type) return Boolean
   is (Wide_Wide_String_Operations.Is_Empty (Unwrap (Source)));

   function Element (Source : String_Type; Index : Positive) return Character_Type
   is (Wide_Wide_String_Operations.Element (Unwrap (Source), Index));

   function Get_Element (Source : String_Type; Index : Positive) return Character_Type
   is (Wide_Wide_Strings.Get_Element (Unwrap (Source), Index));

   function First_Index (Source : String_Type) return Positive
   is (Wide_Wide_Strings.First_Index (Unwrap (Source)));

   function Last_Index (Source : String_Type) return Natural
   is (Wide_Wide_Strings.Last_Index (Unwrap (Source)));

   function Contains (Source : String_Type; Pattern : String_Type) return Boolean
   is (Wide_Wide_Strings.Contains (Unwrap (Source), Unwrap (Pattern)));

   function "&" (Left : String_Type; Right : String_Type) return String_Type
   is (Wrap
         (Wide_Wide_String_Operations.Concat_Strings (Unwrap (Left), Unwrap (Right))));

   function "&" (Left : String_Type; Right : Character_Type) return String_Type
   is (Wrap (Wide_Wide_String_Operations.Concat_String_Character (Unwrap (Left), Right)));

   function "&" (Left : Character_Type; Right : String_Type) return String_Type
   is (Wrap (Wide_Wide_String_Operations.Concat_Character_String (Left, Unwrap (Right))));

   function "&" (Left : String_Type; Right : String) return String_Type
   is (Wrap (Wide_Wide_String_Operations.Concat_String_Latin_1 (Unwrap (Left), Right)));

   function "&" (Left : String; Right : String_Type) return String_Type
   is (Wrap (Wide_Wide_String_Operations.Concat_Latin_1_String (Left, Unwrap (Right))));

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
   is (Wide_Wide_Strings.Equal (Unwrap (Left), Unwrap (Right)));

   function "<" (Left, Right : String_Type) return Boolean
   is (Wide_Wide_Strings.Less_Than (Unwrap (Left), Unwrap (Right)));

   function "<=" (Left, Right : String_Type) return Boolean
   is (Wide_Wide_Strings.Less_Or_Equal (Unwrap (Left), Unwrap (Right)));

   function ">" (Left, Right : String_Type) return Boolean
   is (Wide_Wide_Strings.Greater_Than (Unwrap (Left), Unwrap (Right)));

   function ">=" (Left, Right : String_Type) return Boolean
   is (Wide_Wide_Strings.Greater_Or_Equal (Unwrap (Left), Unwrap (Right)));

   function To_String_Type (Source : String) return String_Type
   is (Wrap (Wide_Wide_String_Operations.To_Unbounded_Wide_Wide_String (Source)));

   function To_Latin_1 (Source : String_Type) return String
   is (Wide_Wide_String_Operations.To_String (Unwrap (Source)));

   function To_Latin_1_If_Possible (Source : String_Type) return Latin_1_Conv_Result
   is (Wide_Wide_String_Operations.To_Latin_1_If_Possible (Unwrap (Source)));

   function To_UTF_8 (Source : String_Type) return String
   is (Wide_Wide_String_Operations.To_UTF_8 (Unwrap (Source)));

   function From_UTF_8 (Source : String) return UTF_8_Decode_Result
   is ((Inner => Wide_Wide_UTF_8_Bridge.From_UTF_8_Wide_Wide (Source)));

   function To_Wide_Wide_String (Source : String_Type) return Wide_Wide_String
   is (Wide_Wide_String_Operations.To_Wide_Wide_String (Unwrap (Source)));

   function Code_Point_Length (Source : String_Type) return Natural
   is (Wide_Wide_String_Operations.Code_Point_Length (Unwrap (Source)));

   function From_Wide_Wide_String (Source : Wide_Wide_String) return String_Type
   is (Wrap (Wide_Wide_String_Operations.From_Wide_Wide_String (Source)));

   function From_Wide_Wide_String_With_Substitute
     (Source : Wide_Wide_String; Substitute : Wide_Wide_Character) return String_Type
   is (Wrap
         (Wide_Wide_String_Operations.From_Wide_Wide_String_With_Substitute (Source, Substitute)));

   function From_Wide_Wide_String_Skip_Invalid (Source : Wide_Wide_String) return String_Type
   is (Wrap (Wide_Wide_String_Operations.From_Wide_Wide_String_Skip_Invalid (Source)));

   function From_Wide_Wide_String_Checked (Source : Wide_Wide_String) return WWS_Decode_Result
   is ((Inner => Wide_Wide_WWS_Bridge.From_Wide_Wide_String_Wide_Wide_Checked (Source)));

   function Is_Ok (R : WWS_Decode_Result) return Boolean
   is (Wide_Wide_WWS_Decode_Results.Is_Ok (R.Inner));

   function Get_Value (R : WWS_Decode_Result) return String_Type
   is (Wrap (Wide_Wide_WWS_Decode_Results.Get_Value (R.Inner)));

   function Get_Value_Or (R : WWS_Decode_Result; Fallback : String_Type) return String_Type
   is (Wrap
         (Wide_Wide_WWS_Decode_Results.Get_Value_Or (R.Inner, Unwrap (Fallback))));

   function Get_Error (R : WWS_Decode_Result) return WWS_Failure
   is (Wide_Wide_WWS_Decode_Results.Get_Error (R.Inner));

   function Is_Ok (R : UTF_8_Decode_Result) return Boolean
   is (Wide_Wide_UTF_8_Results.Is_Ok (R.Inner));

   function Get_Value (R : UTF_8_Decode_Result) return String_Type
   is (Wrap (Wide_Wide_UTF_8_Results.Get_Value (R.Inner)));

   function Get_Value_Or (R : UTF_8_Decode_Result; Fallback : String_Type) return String_Type
   is (Wrap (Wide_Wide_UTF_8_Results.Get_Value_Or (R.Inner, Unwrap (Fallback))));

   function Get_Error (R : UTF_8_Decode_Result) return UTF_8_Decode_Error
   is (Wide_Wide_UTF_8_Results.Get_Error (R.Inner));

   function As_UTF_8 (Source : String_Type) return String
   is (Wide_Wide_Strings.As_UTF_8 (Unwrap (Source)));

   function Decode_UTF_8 (Source : String) return UTF_8_Decode_Result
   is ((Inner => Wide_Wide_Strings.Decode_UTF_8 (Source)));

   function UTF_8_Is_Valid (Source : String) return Boolean
   is (Wide_Wide_Strings.UTF_8_Is_Valid (Source));

   function Hash (Key : String_Type) return Ada.Containers.Hash_Type
   is (Wide_Wide_String_Operations.Hash (Unwrap (Key)));

   function Slice (Source : String_Type; Low : Positive; High : Natural) return String_Type
   is (Wrap (Wide_Wide_String_Operations.Slice (Unwrap (Source), Low, High)));

   function Index (Source : String_Type; Pattern : String_Type) return Natural
   is (Wide_Wide_String_Operations.Index (Unwrap (Source), Unwrap (Pattern)));

   function Index (Source : String_Type; Pattern : String) return Natural
   is (Wide_Wide_String_Operations.Index_Latin_1 (Unwrap (Source), Pattern));

   function Index_From (Source : String_Type; Pattern : String_Type; Starting_At : Positive) return Natural
   is (Wide_Wide_String_Operations.Index_From
         (Unwrap (Source), Unwrap (Pattern), Starting_At));

   function Index_From (Source : String_Type; Pattern : String; Starting_At : Positive) return Natural
   is (Wide_Wide_String_Operations.Index_From
         (Unwrap (Source),
          Wide_Wide_String_Operations.To_Unbounded_Wide_Wide_String (Pattern),
          Starting_At));

   function Index_Reverse (Source : String_Type; Pattern : String_Type) return Natural
   is (Wide_Wide_String_Operations.Index_Reverse (Unwrap (Source), Unwrap (Pattern)));

   function Replace (Source : String_Type; Pattern : String_Type; By : String_Type) return String_Type
   is (Wrap
         (Wide_Wide_Strings.Replace
            (Unwrap (Source), Unwrap (Pattern), Unwrap (By))));

   function Replace (Source : String_Type; Pattern : String; By : String_Type) return String_Type
   is (Wrap
         (Wide_Wide_Strings.Replace
            (Unwrap (Source),
             Wide_Wide_String_Operations.To_Unbounded_Wide_Wide_String (Pattern),
             Unwrap (By))));

   function Replace (Source : String_Type; Pattern : String_Type; By : String) return String_Type
   is (Wrap
         (Wide_Wide_Strings.Replace
            (Unwrap (Source),
             Unwrap (Pattern),
             Wide_Wide_String_Operations.To_Unbounded_Wide_Wide_String (By))));

   function Head (Source : String_Type; Count : Natural; Pad : Character_Type) return String_Type
   is (Wrap (Wide_Wide_Strings.Head (Unwrap (Source), Count, Pad)));

   function Tail (Source : String_Type; Count : Natural; Pad : Character_Type) return String_Type
   is (Wrap (Wide_Wide_Strings.Tail (Unwrap (Source), Count, Pad)));

   function Full_Lower_Length (Source : String_Type) return Long_Long_Integer
   is (Wide_Wide_String_Operations.Full_Lower_Length (Unwrap (Source)));

   function Full_Upper_Length (Source : String_Type) return Long_Long_Integer
   is (Wide_Wide_String_Operations.Full_Upper_Length (Unwrap (Source)));

   function To_Lower (Source : String_Type) return String_Type
   is (Wrap (Wide_Wide_String_Operations.To_Lower (Unwrap (Source))));

   function To_Upper (Source : String_Type) return String_Type
   is (Wrap (Wide_Wide_String_Operations.To_Upper (Unwrap (Source))));

   function Simple_To_Lower (Source : String_Type) return String_Type
   is (Wrap (Wide_Wide_String_Operations.Simple_To_Lower (Unwrap (Source))));

   function Starts_With (Source : String_Type; Prefix : String_Type) return Boolean
   is (Wide_Wide_String_Operations.Starts_With (Unwrap (Source), Unwrap (Prefix)));

   function Starts_With (Source : String_Type; Prefix : String) return Boolean
   is (Wide_Wide_String_Operations.Starts_With_Latin_1 (Unwrap (Source), Prefix));

   function Ends_With (Source : String_Type; Suffix : String_Type) return Boolean
   is (Wide_Wide_String_Operations.Ends_With (Unwrap (Source), Unwrap (Suffix)));

   function Trim (Source : String_Type) return String_Type
   is (Wrap (Wide_Wide_String_Operations.Trim (Unwrap (Source))));

   function From_Character (C : Character_Type) return String_Type
   is (Wrap (Wide_Wide_String_Operations.From_Character (C)));

end String_Types;
