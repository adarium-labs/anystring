-------------------------------------------------------------------------------
--  Wide_Wide_Strings - Wide_Wide_String Instantiation
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Anystrings;
with Wide_Wide_String_Operations;
with Wide_Wide_UTF_8_Results;
with Wide_Wide_UTF_8_Bridge;

package Wide_Wide_Strings is new Anystrings
  (String_Type              =>
     Wide_Wide_String_Operations.Unbounded_Wide_Wide_String,
   Character_Type           => Wide_Wide_Character,
   Null_String              =>
     Wide_Wide_String_Operations.Null_Unbounded_Wide_Wide_String,
   Length                   => Wide_Wide_String_Operations.Length,
   Is_Empty                 => Wide_Wide_String_Operations.Is_Empty,
   Element                  => Wide_Wide_String_Operations.Element,
   Concat_Strings           => Wide_Wide_String_Operations.Concat_Strings,
   Concat_String_Character  =>
     Wide_Wide_String_Operations.Concat_String_Character,
   Concat_Character_String  =>
     Wide_Wide_String_Operations.Concat_Character_String,
   "="                      => Wide_Wide_String_Operations."=",
   "<"                      => Wide_Wide_String_Operations."<",
   "<="                     => Wide_Wide_String_Operations."<=",
   ">"                      => Wide_Wide_String_Operations.">",
   ">="                     => Wide_Wide_String_Operations.">=",
   To_String_Type           =>
     Wide_Wide_String_Operations.To_Unbounded_Wide_Wide_String,
   To_Latin_1               => Wide_Wide_String_Operations.To_String,
   UTF_8                    => Wide_Wide_UTF_8_Results,
   To_UTF_8                 => Wide_Wide_String_Operations.To_UTF_8,
   From_UTF_8               => Wide_Wide_UTF_8_Bridge.From_UTF_8_Wide_Wide,
   To_Wide_Wide_String      => Wide_Wide_String_Operations.To_Wide_Wide_String,
   From_Wide_Wide_String    => Wide_Wide_String_Operations.From_Wide_Wide_String,
   Hash                     => Wide_Wide_String_Operations.Hash,
   Slice                    => Wide_Wide_String_Operations.Slice,
   Index                    => Wide_Wide_String_Operations.Index,
   Index_Latin_1            => Wide_Wide_String_Operations.Index_Latin_1,
   Index_From               => Wide_Wide_String_Operations.Index_From,
   Index_Reverse            => Wide_Wide_String_Operations.Index_Reverse,
   To_Lower                 => Wide_Wide_String_Operations.To_Lower,
   To_Upper                 => Wide_Wide_String_Operations.To_Upper,
   Starts_With              => Wide_Wide_String_Operations.Starts_With,
   Starts_With_Latin_1      => Wide_Wide_String_Operations.Starts_With_Latin_1,
   Ends_With                => Wide_Wide_String_Operations.Ends_With,
   Trim                     => Wide_Wide_String_Operations.Trim,
   From_Character           => Wide_Wide_String_Operations.From_Character,
   Concat_String_Latin_1    => Wide_Wide_String_Operations.Concat_String_Latin_1,
   Concat_Latin_1_String    => Wide_Wide_String_Operations.Concat_Latin_1_String,
   Is_Alphanumeric          => Wide_Wide_String_Operations.Char_Is_Alphanumeric,
   Is_Control               => Wide_Wide_String_Operations.Char_Is_Control,
   Is_Digit                 => Wide_Wide_String_Operations.Char_Is_Digit,
   Is_Graphic               => Wide_Wide_String_Operations.Char_Is_Graphic,
   Is_Hex_Digit             => Wide_Wide_String_Operations.Char_Is_Hex_Digit,
   Is_Letter                => Wide_Wide_String_Operations.Char_Is_Letter,
   Is_Line_Terminator       => Wide_Wide_String_Operations.Char_Is_Line_Terminator,
   Is_Lower                 => Wide_Wide_String_Operations.Char_Is_Lower,
   Is_Upper                 => Wide_Wide_String_Operations.Char_Is_Upper,
   Is_Whitespace            => Wide_Wide_String_Operations.Char_Is_Whitespace,
   Char_To_Lower            => Wide_Wide_String_Operations.Char_To_Lower,
   Char_To_Upper            => Wide_Wide_String_Operations.Char_To_Upper);
