-------------------------------------------------------------------------------
--  Wide_Strings - Wide_String Instantiation
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Anystrings;
with Wide_String_Operations;
with Wide_UTF_8_Results;
with Wide_UTF_8_Bridge;

package Wide_Strings is new Anystrings
  (String_Type              => Wide_String_Operations.Unbounded_Wide_String,
   Character_Type           => Wide_Character,
   Null_String              => Wide_String_Operations.Null_Unbounded_Wide_String,
   Length                   => Wide_String_Operations.Length,
   Is_Empty                 => Wide_String_Operations.Is_Empty,
   Element                  => Wide_String_Operations.Element,
   Concat_Strings           => Wide_String_Operations.Concat_Strings,
   Concat_String_Character  => Wide_String_Operations.Concat_String_Character,
   Concat_Character_String  => Wide_String_Operations.Concat_Character_String,
   "="                      => Wide_String_Operations."=",
   "<"                      => Wide_String_Operations."<",
   "<="                     => Wide_String_Operations."<=",
   ">"                      => Wide_String_Operations.">",
   ">="                     => Wide_String_Operations.">=",
   To_String_Type           => Wide_String_Operations.To_Unbounded_Wide_String,
   To_Latin_1               => Wide_String_Operations.To_String,
   UTF_8                    => Wide_UTF_8_Results,
   To_UTF_8                 => Wide_String_Operations.To_UTF_8,
   From_UTF_8               => Wide_UTF_8_Bridge.From_UTF_8_Wide,
   Hash                     => Wide_String_Operations.Hash,
   Slice                    => Wide_String_Operations.Slice,
   Index                    => Wide_String_Operations.Index,
   Index_Latin_1            => Wide_String_Operations.Index_Latin_1,
   Index_From               => Wide_String_Operations.Index_From,
   Index_Reverse            => Wide_String_Operations.Index_Reverse,
   To_Lower                 => Wide_String_Operations.To_Lower,
   To_Upper                 => Wide_String_Operations.To_Upper,
   Starts_With              => Wide_String_Operations.Starts_With,
   Starts_With_Latin_1      => Wide_String_Operations.Starts_With_Latin_1,
   Ends_With                => Wide_String_Operations.Ends_With,
   Trim                     => Wide_String_Operations.Trim,
   From_Character           => Wide_String_Operations.From_Character,
   Concat_String_Latin_1    => Wide_String_Operations.Concat_String_Latin_1,
   Concat_Latin_1_String    => Wide_String_Operations.Concat_Latin_1_String,
   Is_Alphanumeric          => Wide_String_Operations.Char_Is_Alphanumeric,
   Is_Control               => Wide_String_Operations.Char_Is_Control,
   Is_Digit                 => Wide_String_Operations.Char_Is_Digit,
   Is_Graphic               => Wide_String_Operations.Char_Is_Graphic,
   Is_Hex_Digit             => Wide_String_Operations.Char_Is_Hex_Digit,
   Is_Letter                => Wide_String_Operations.Char_Is_Letter,
   Is_Line_Terminator       => Wide_String_Operations.Char_Is_Line_Terminator,
   Is_Lower                 => Wide_String_Operations.Char_Is_Lower,
   Is_Upper                 => Wide_String_Operations.Char_Is_Upper,
   Is_Whitespace            => Wide_String_Operations.Char_Is_Whitespace,
   Char_To_Lower            => Wide_String_Operations.Char_To_Lower,
   Char_To_Upper            => Wide_String_Operations.Char_To_Upper);
