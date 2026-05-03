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
with UXStrings;

package UXStrings is new Anystrings
  (String_Type              => UXStrings.UXString,
   Character_Type           => UXStrings.Unicode_Character,
   Null_String              => UXString_Operations.Null_UXString,
   --  Core operations
   Length                   => UXString_Operations.Length,
   Is_Empty                 => UXString_Operations.Is_Empty,
   Element                  => UXString_Operations.Element,
   Concat_Strings           => UXString_Operations.Concat_Strings,
   Concat_String_Character  => UXString_Operations.Concat_String_Character,
   Concat_Character_String  => UXString_Operations.Concat_Character_String,
   --  Comparison operations
   "="                      => UXString_Operations."=",
   "<"                      => UXString_Operations."<",
   "<="                     => UXString_Operations."<=",
   ">"                      => UXString_Operations.">",
   ">="                     => UXString_Operations.">=",
   --  Conversion operations
   To_String_Type           => UXString_Operations.To_UXString,
   To_Latin_1               => UXString_Operations.To_String,
   --  Extended operations
   Hash                     => UXString_Operations.Hash,
   Slice                    => UXString_Operations.Slice,
   Index                    => UXString_Operations.Index,
   Index_Latin_1            => UXString_Operations.Index_Latin_1,
   To_Lower                 => UXString_Operations.To_Lower,
   To_Upper                 => UXString_Operations.To_Upper,
   Starts_With              => UXString_Operations.Starts_With,
   Starts_With_Latin_1      => UXString_Operations.Starts_With_Latin_1,
   Ends_With                => UXString_Operations.Ends_With,
   Trim                     => UXString_Operations.Trim,
   From_Character           => UXString_Operations.From_Character,
   --  Latin-1 concatenation
   Concat_String_Latin_1    => UXString_Operations.Concat_String_Latin_1,
   Concat_Latin_1_String    => UXString_Operations.Concat_Latin_1_String);
