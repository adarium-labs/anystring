-------------------------------------------------------------------------------
--  VSS_Strings - Virtual_String Instantiation
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Instantiation of Anystrings for VSS.Strings.Virtual_String.
--
--  @description
--  This package provides the Virtual_String backend with full Unicode
--  support. Length and Element operate on Unicode code points (the same
--  semantics as the uxstring backend), not bytes.

with Anystrings;
with VSS.Strings;
with VSS_Operations;
with VSS_UTF_8_Bridge;
with VSS_UTF_8_Results;

package VSS_Strings is new Anystrings
  (String_Type              => VSS.Strings.Virtual_String,
   Character_Type           => Wide_Wide_Character,
   Null_String              => VSS_Operations.Null_Virtual_String,
   Length                   => VSS_Operations.Length,
   Is_Empty                 => VSS_Operations.Is_Empty,
   Element                  => VSS_Operations.Element,
   Concat_Strings           => VSS_Operations.Concat_Strings,
   Concat_String_Character  => VSS_Operations.Concat_String_Character,
   Concat_Character_String  => VSS_Operations.Concat_Character_String,
   "="                      => VSS_Operations."=",
   "<"                      => VSS_Operations."<",
   "<="                     => VSS_Operations."<=",
   ">"                      => VSS_Operations.">",
   ">="                     => VSS_Operations.">=",
   To_String_Type           => VSS_Operations.To_Virtual_String,
   To_Latin_1               => VSS_Operations.To_String,
   UTF_8                    => VSS_UTF_8_Results,
   To_UTF_8                 => VSS_Operations.To_UTF_8,
   From_UTF_8               => VSS_UTF_8_Bridge.From_UTF_8_VSS,
   Environment_Value        => VSS_Operations.Environment_Value,
   Environment_Exists       => VSS_Operations.Environment_Exists,
   Environment_Set          => VSS_Operations.Environment_Set,
   Environment_Clear        => VSS_Operations.Environment_Clear,
   Environment_Clear_All    => VSS_Operations.Environment_Clear,
   Environment_Iterate      => VSS_Operations.Environment_Iterate,
   File_Type                => VSS_Operations.File_Type,
   File_Mode                => VSS_Operations.File_Mode,
   In_File_Mode             => VSS_Operations.In_File_Mode,
   Out_File_Mode            => VSS_Operations.Out_File_Mode,
   Append_File_Mode         => VSS_Operations.Append_File_Mode,
   Create_File              => VSS_Operations.Create_File,
   Open_File                => VSS_Operations.Open_File,
   Close_File               => VSS_Operations.Close_File,
   Is_Open_File             => VSS_Operations.Is_Open_File,
   Current_Input_File       => VSS_Operations.Current_Input_File,
   Current_Output_File      => VSS_Operations.Current_Output_File,
   Set_Input_File           => VSS_Operations.Set_Input_File,
   Set_Output_File          => VSS_Operations.Set_Output_File,
   Put_File                 => VSS_Operations.Put_File,
   Get_Line_File            => VSS_Operations.Get_Line_File,
   New_Line_File            => VSS_Operations.New_Line_File,
   End_Of_File_File         => VSS_Operations.End_Of_File_File,
   Hash                     => VSS_Operations.Hash,
   Slice                    => VSS_Operations.Slice,
   Index                    => VSS_Operations.Index,
   Index_Latin_1            => VSS_Operations.Index_Latin_1,
   Index_From               => VSS_Operations.Index_From,
   Index_Reverse            => VSS_Operations.Index_Reverse,
   To_Lower                 => VSS_Operations.To_Lower,
   To_Upper                 => VSS_Operations.To_Upper,
   Starts_With              => VSS_Operations.Starts_With,
   Starts_With_Latin_1      => VSS_Operations.Starts_With_Latin_1,
   Ends_With                => VSS_Operations.Ends_With,
   Trim                     => VSS_Operations.Trim,
   From_Character           => VSS_Operations.From_Character,
   Concat_String_Latin_1    => VSS_Operations.Concat_String_Latin_1,
   Concat_Latin_1_String    => VSS_Operations.Concat_Latin_1_String,
   Is_Alphanumeric          => VSS_Operations.Char_Is_Alphanumeric,
   Is_Control               => VSS_Operations.Char_Is_Control,
   Is_Digit                 => VSS_Operations.Char_Is_Digit,
   Is_Graphic               => VSS_Operations.Char_Is_Graphic,
   Is_Hex_Digit             => VSS_Operations.Char_Is_Hex_Digit,
   Is_Letter                => VSS_Operations.Char_Is_Letter,
   Is_Line_Terminator       => VSS_Operations.Char_Is_Line_Terminator,
   Is_Lower                 => VSS_Operations.Char_Is_Lower,
   Is_Upper                 => VSS_Operations.Char_Is_Upper,
   Is_Whitespace            => VSS_Operations.Char_Is_Whitespace,
   Char_To_Lower            => VSS_Operations.Char_To_Lower,
   Char_To_Upper            => VSS_Operations.Char_To_Upper);
