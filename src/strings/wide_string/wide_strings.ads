-------------------------------------------------------------------------------
--  Wide_Strings - Wide_String Instantiation
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Anystrings;
with Wide_String_Operations;

package Wide_Strings is new Anystrings
  (String_Type              => Wide_String_Operations.Unbounded_Wide_String,
   Character_Type           => Wide_Character,
   Null_String              => Wide_String_Operations.Null_Unbounded_Wide_String,
   --  Core operations
   Length                   => Wide_String_Operations.Length,
   Is_Empty                 => Wide_String_Operations.Is_Empty,
   Element                  => Wide_String_Operations.Element,
   Concat_Strings           => Wide_String_Operations.Concat_Strings,
   Concat_String_Character  => Wide_String_Operations.Concat_String_Character,
   Concat_Character_String  => Wide_String_Operations.Concat_Character_String,
   --  Comparison operations
   "="                      => Wide_String_Operations."=",
   "<"                      => Wide_String_Operations."<",
   "<="                     => Wide_String_Operations."<=",
   ">"                      => Wide_String_Operations.">",
   ">="                     => Wide_String_Operations.">=",
   --  Conversion operations
   To_String_Type           => Wide_String_Operations.To_Unbounded_Wide_String,
   To_Latin_1               => Wide_String_Operations.To_String,
   --  Extended operations
   Hash                     => Wide_String_Operations.Hash,
   Slice                    => Wide_String_Operations.Slice,
   Index                    => Wide_String_Operations.Index,
   Index_Latin_1            => Wide_String_Operations.Index_Latin_1,
   To_Lower                 => Wide_String_Operations.To_Lower,
   To_Upper                 => Wide_String_Operations.To_Upper,
   Starts_With              => Wide_String_Operations.Starts_With,
   Starts_With_Latin_1      => Wide_String_Operations.Starts_With_Latin_1,
   Ends_With                => Wide_String_Operations.Ends_With,
   Trim                     => Wide_String_Operations.Trim,
   From_Character           => Wide_String_Operations.From_Character,
   --  Latin-1 concatenation
   Concat_String_Latin_1    => Wide_String_Operations.Concat_String_Latin_1,
   Concat_Latin_1_String    => Wide_String_Operations.Concat_Latin_1_String);
