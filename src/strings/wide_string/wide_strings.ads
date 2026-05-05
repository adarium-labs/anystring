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
   Environment_Value        => Wide_String_Operations.Environment_Value,
   Environment_Exists       => Wide_String_Operations.Environment_Exists,
   Environment_Set          => Wide_String_Operations.Environment_Set,
   Environment_Clear        => Wide_String_Operations.Environment_Clear,
   Environment_Clear_All    => Wide_String_Operations.Environment_Clear,
   Environment_Iterate      => Wide_String_Operations.Environment_Iterate,
   File_Type                => Wide_String_Operations.File_Type,
   File_Mode                => Wide_String_Operations.File_Mode,
   In_File_Mode            => Wide_String_Operations.In_File_Mode,
   Out_File_Mode           => Wide_String_Operations.Out_File_Mode,
   Append_File_Mode        => Wide_String_Operations.Append_File_Mode,
   Create_File             => Wide_String_Operations.Create_File,
   Open_File               => Wide_String_Operations.Open_File,
   Close_File              => Wide_String_Operations.Close_File,
   Is_Open_File            => Wide_String_Operations.Is_Open_File,
   Current_Input_File      => Wide_String_Operations.Current_Input_File,
   Current_Output_File     => Wide_String_Operations.Current_Output_File,
   Set_Input_File          => Wide_String_Operations.Set_Input_File,
   Set_Output_File         => Wide_String_Operations.Set_Output_File,
   Put_File                => Wide_String_Operations.Put_File,
   Get_Line_File           => Wide_String_Operations.Get_Line_File,
   New_Line_File           => Wide_String_Operations.New_Line_File,
   End_Of_File_File        => Wide_String_Operations.End_Of_File_File,
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
   Concat_String_Latin_1    => Wide_String_Operations.Concat_String_Latin_1,
   Concat_Latin_1_String    => Wide_String_Operations.Concat_Latin_1_String);
