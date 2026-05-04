-------------------------------------------------------------------------------
--  Wide_Wide_Strings - Wide_Wide_String Instantiation
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Anystrings;
with Wide_Wide_String_Operations;

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
    Environment_Value        => Wide_Wide_String_Operations.Environment_Value,
    Environment_Exists       => Wide_Wide_String_Operations.Environment_Exists,
    Environment_Set          => Wide_Wide_String_Operations.Environment_Set,
    Environment_Clear        => Wide_Wide_String_Operations.Environment_Clear,
    Environment_Clear_All    => Wide_Wide_String_Operations.Environment_Clear,
    Environment_Iterate      => Wide_Wide_String_Operations.Environment_Iterate,
    Hash                     => Wide_Wide_String_Operations.Hash,
    Slice                    => Wide_Wide_String_Operations.Slice,
   Index                    => Wide_Wide_String_Operations.Index,
   Index_Latin_1            => Wide_Wide_String_Operations.Index_Latin_1,
   To_Lower                 => Wide_Wide_String_Operations.To_Lower,
   To_Upper                 => Wide_Wide_String_Operations.To_Upper,
   Starts_With              => Wide_Wide_String_Operations.Starts_With,
   Starts_With_Latin_1      =>
     Wide_Wide_String_Operations.Starts_With_Latin_1,
   Ends_With                => Wide_Wide_String_Operations.Ends_With,
   Trim                     => Wide_Wide_String_Operations.Trim,
   From_Character           => Wide_Wide_String_Operations.From_Character,
   Concat_String_Latin_1    =>
     Wide_Wide_String_Operations.Concat_String_Latin_1,
   Concat_Latin_1_String    =>
     Wide_Wide_String_Operations.Concat_Latin_1_String);
