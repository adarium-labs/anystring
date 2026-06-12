-------------------------------------------------------------------------------
--  UXStrings - UXString Instantiation
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Instantiation of Strings for UXStrings.UXString.
--
--  @description
--  This package provides the UXString string abstraction with full Unicode
--  support. Length and Element operate on Unicode code points, not bytes.

with Anystrings;
with UXString_Operations;
with UXString_UTF_8_Results;
with UXString_UTF_8_Bridge;
with UXStrings;

package UXString_Strings is new Anystrings
  (String_Type              => UXStrings.UXString,
   Character_Type           => UXStrings.Unicode_Character,
   Null_String              => UXString_Operations.Null_UXString,
   Length                   => UXString_Operations.Length,
   Is_Empty                 => UXString_Operations.Is_Empty,
   Element                  => UXString_Operations.Element,
   Concat_Strings           => UXString_Operations.Concat_Strings,
   Concat_String_Character  => UXString_Operations.Concat_String_Character,
   Concat_Character_String  => UXString_Operations.Concat_Character_String,
   "="                      => UXString_Operations."=",
   "<"                      => UXString_Operations."<",
   "<="                     => UXString_Operations."<=",
   ">"                      => UXString_Operations.">",
   ">="                     => UXString_Operations.">=",
   To_String_Type           => UXString_Operations.To_UXString,
   To_Latin_1               => UXString_Operations.To_String,
   UTF_8                    => UXString_UTF_8_Results,
   To_UTF_8                 => UXString_Operations.To_UTF_8,
   From_UTF_8               => UXString_UTF_8_Bridge.From_UTF_8_UXString,
   Environment_Value        => UXString_Operations.Environment_Value,
   Environment_Exists       => UXString_Operations.Environment_Exists,
   Environment_Set          => UXString_Operations.Environment_Set,
   Environment_Clear        => UXString_Operations.Environment_Clear,
   Environment_Clear_All    => UXString_Operations.Environment_Clear,
   Environment_Iterate      => UXString_Operations.Environment_Iterate,
   Hash                     => UXString_Operations.Hash,
   Slice                    => UXString_Operations.Slice,
   Index                    => UXString_Operations.Index,
   Index_Latin_1            => UXString_Operations.Index_Latin_1,
   Index_From               => UXString_Operations.Index_From,
   Index_Reverse            => UXString_Operations.Index_Reverse,
   To_Lower                 => UXString_Operations.To_Lower,
   To_Upper                 => UXString_Operations.To_Upper,
   Starts_With              => UXString_Operations.Starts_With,
   Starts_With_Latin_1      => UXString_Operations.Starts_With_Latin_1,
   Ends_With                => UXString_Operations.Ends_With,
   Trim                     => UXString_Operations.Trim,
   From_Character           => UXString_Operations.From_Character,
   Concat_String_Latin_1    => UXString_Operations.Concat_String_Latin_1,
   Concat_Latin_1_String    => UXString_Operations.Concat_Latin_1_String,
   Is_Alphanumeric          => UXString_Operations.Char_Is_Alphanumeric,
   Is_Control               => UXString_Operations.Char_Is_Control,
   Is_Digit                 => UXString_Operations.Char_Is_Digit,
   Is_Graphic               => UXString_Operations.Char_Is_Graphic,
   Is_Hex_Digit             => UXString_Operations.Char_Is_Hex_Digit,
   Is_Letter                => UXString_Operations.Char_Is_Letter,
   Is_Line_Terminator       => UXString_Operations.Char_Is_Line_Terminator,
   Is_Lower                 => UXString_Operations.Char_Is_Lower,
   Is_Upper                 => UXString_Operations.Char_Is_Upper,
   Is_Whitespace            => UXString_Operations.Char_Is_Whitespace,
   Char_To_Lower            => UXString_Operations.Char_To_Lower,
   Char_To_Upper            => UXString_Operations.Char_To_Upper);
