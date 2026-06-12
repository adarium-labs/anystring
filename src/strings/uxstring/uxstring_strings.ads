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
   File_Type                => UXString_Operations.File_Type,
   File_Mode                => UXString_Operations.File_Mode,
   In_File_Mode            => UXString_Operations.In_File_Mode,
   Out_File_Mode           => UXString_Operations.Out_File_Mode,
   Append_File_Mode        => UXString_Operations.Append_File_Mode,
   Create_File             => UXString_Operations.Create_File,
   Open_File               => UXString_Operations.Open_File,
   Close_File              => UXString_Operations.Close_File,
   Is_Open_File            => UXString_Operations.Is_Open_File,
   Current_Input_File      => UXString_Operations.Current_Input_File,
   Current_Output_File     => UXString_Operations.Current_Output_File,
   Set_Input_File          => UXString_Operations.Set_Input_File,
   Set_Output_File         => UXString_Operations.Set_Output_File,
   Put_File                => UXString_Operations.Put_File,
   Get_Line_File           => UXString_Operations.Get_Line_File,
   New_Line_File           => UXString_Operations.New_Line_File,
   End_Of_File_File        => UXString_Operations.End_Of_File_File,
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
   Char_To_Upper            => UXString_Operations.Char_To_Upper,
   File_Kind                => UXString_Operations.File_Kind,
   Path_Exists              => UXString_Operations.Path_Exists,
   Path_Kind                => UXString_Operations.Path_Kind,
   Create_Directory_Path    => UXString_Operations.Create_Directory_Path,
   Delete_File_Path         => UXString_Operations.Delete_File_Path,
   Rename_Path              => UXString_Operations.Rename_Path);
