-------------------------------------------------------------------------------
--  Standard_Strings - Default String Instantiation
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Instantiation of Strings for Ada.Strings.Unbounded.Unbounded_String.
--
--  @description
--  This package provides the default string abstraction using Unbounded_String.
--  String content is assumed to be UTF-8 encoded, which is the common modern
--  usage. Note that Length and Element operate on bytes (Character values),
--  not Unicode code points.
--
--  For full Unicode support, use the VSS or UXStrings instantiation.
--
--  We use Unbounded_String instead of Standard.String because String is an
--  unconstrained array type which cannot be used as a generic formal private
--  type.
--
--  **Usage:**
--  This is the default instantiation. To use a different string type:
--  1. Create your own operations package (like Standard_String_Operations)
--  2. Create your own instantiation of Strings
--  3. Use GPR source directory configuration to swap String_Types

with Anystrings;
with Standard_String_Operations;
with Standard_UTF_8_Results;
with Standard_UTF_8_Bridge;
with Standard_WWS_Decode_Results;
with Standard_WWS_Bridge;

package Standard_Strings is new
  Anystrings
    (String_Type             => Standard_String_Operations.Unbounded_String,
     Character_Type          => Character,
     Null_String             => Standard_String_Operations.Null_Unbounded_String,
     Length                  => Standard_String_Operations.Length,
     Is_Empty                => Standard_String_Operations.Is_Empty,
     Element                 => Standard_String_Operations.Element,
     Concat_Strings          => Standard_String_Operations.Concat_Strings,
     Concat_String_Character => Standard_String_Operations.Concat_String_Character,
     Concat_Character_String => Standard_String_Operations.Concat_Character_String,
     "="                     => Standard_String_Operations."=",
     "<"                     => Standard_String_Operations."<",
     "<="                    => Standard_String_Operations."<=",
     ">"                     => Standard_String_Operations.">",
     ">="                    => Standard_String_Operations.">=",
     To_String_Type          => Standard_String_Operations.To_Unbounded_String,
     To_Latin_1              => Standard_String_Operations.To_Latin_1,
     UTF_8                   => Standard_UTF_8_Results,
     To_UTF_8                => Standard_String_Operations.To_UTF_8,
     From_UTF_8              => Standard_UTF_8_Bridge.From_UTF_8_Standard,
     To_Wide_Wide_String     => Standard_String_Operations.To_Wide_Wide_String,
     From_Wide_Wide_String   => Standard_String_Operations.From_Wide_Wide_String,
     WWS                                   => Standard_WWS_Decode_Results,
     From_Wide_Wide_String_With_Substitute =>
       Standard_String_Operations.From_Wide_Wide_String_With_Substitute,
     From_Wide_Wide_String_Skip_Invalid    =>
       Standard_String_Operations.From_Wide_Wide_String_Skip_Invalid,
     From_Wide_Wide_String_Checked         =>
       Standard_WWS_Bridge.From_Wide_Wide_String_Standard_Checked,
     Hash                    => Standard_String_Operations.Hash,
     Slice                   => Standard_String_Operations.Slice,
     Index                   => Standard_String_Operations.Index,
     Index_Latin_1           => Standard_String_Operations.Index_Latin_1,
     Index_From              => Standard_String_Operations.Index_From,
     Index_Reverse           => Standard_String_Operations.Index_Reverse,
     To_Lower                => Standard_String_Operations.To_Lower,
     To_Upper                => Standard_String_Operations.To_Upper,
     Starts_With             => Standard_String_Operations.Starts_With,
     Starts_With_Latin_1     => Standard_String_Operations.Starts_With_Latin_1,
     Ends_With               => Standard_String_Operations.Ends_With,
     Trim                    => Standard_String_Operations.Trim,
     From_Character          => Standard_String_Operations.From_Character,
     Concat_String_Latin_1   => Standard_String_Operations.Concat_String_Latin_1,
     Concat_Latin_1_String   => Standard_String_Operations.Concat_Latin_1_String,
     Is_Alphanumeric         => Standard_String_Operations.Char_Is_Alphanumeric,
     Is_Control              => Standard_String_Operations.Char_Is_Control,
     Is_Digit                => Standard_String_Operations.Char_Is_Digit,
     Is_Graphic              => Standard_String_Operations.Char_Is_Graphic,
     Is_Hex_Digit            => Standard_String_Operations.Char_Is_Hex_Digit,
     Is_Letter               => Standard_String_Operations.Char_Is_Letter,
     Is_Line_Terminator      => Standard_String_Operations.Char_Is_Line_Terminator,
     Is_Lower                => Standard_String_Operations.Char_Is_Lower,
     Is_Upper                => Standard_String_Operations.Char_Is_Upper,
     Is_Whitespace           => Standard_String_Operations.Char_Is_Whitespace,
     Char_To_Lower           => Standard_String_Operations.Char_To_Lower,
     Char_To_Upper           => Standard_String_Operations.Char_To_Upper);
