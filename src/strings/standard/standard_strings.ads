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
     To_Latin_1              => Standard_String_Operations.To_String,
     UTF_8                   => Standard_UTF_8_Results,
     To_UTF_8                => Standard_String_Operations.To_UTF_8,
     From_UTF_8              => Standard_UTF_8_Bridge.From_UTF_8_Standard,
     Environment_Value       => Standard_String_Operations.Environment_Value,
     Environment_Exists      => Standard_String_Operations.Environment_Exists,
     Environment_Set         => Standard_String_Operations.Environment_Set,
     Environment_Clear       => Standard_String_Operations.Environment_Clear,
     Environment_Clear_All   => Standard_String_Operations.Environment_Clear,
     Environment_Iterate     => Standard_String_Operations.Environment_Iterate,
     File_Type               => Standard_String_Operations.File_Type,
     File_Mode               => Standard_String_Operations.File_Mode,
     In_File_Mode            => Standard_String_Operations.In_File_Mode,
     Out_File_Mode           => Standard_String_Operations.Out_File_Mode,
     Append_File_Mode        => Standard_String_Operations.Append_File_Mode,
     Create_File             => Standard_String_Operations.Create_File,
     Open_File               => Standard_String_Operations.Open_File,
     Close_File              => Standard_String_Operations.Close_File,
     Is_Open_File            => Standard_String_Operations.Is_Open_File,
     Current_Input_File      => Standard_String_Operations.Current_Input_File,
     Current_Output_File     => Standard_String_Operations.Current_Output_File,
     Set_Input_File          => Standard_String_Operations.Set_Input_File,
     Set_Output_File         => Standard_String_Operations.Set_Output_File,
     Put_File                => Standard_String_Operations.Put_File,
     Get_Line_File           => Standard_String_Operations.Get_Line_File,
     New_Line_File           => Standard_String_Operations.New_Line_File,
     End_Of_File_File        => Standard_String_Operations.End_Of_File_File,
     Hash                    => Standard_String_Operations.Hash,
     Slice                   => Standard_String_Operations.Slice,
     Index                   => Standard_String_Operations.Index,
     Index_Latin_1           => Standard_String_Operations.Index_Latin_1,
     To_Lower                => Standard_String_Operations.To_Lower,
     To_Upper                => Standard_String_Operations.To_Upper,
     Starts_With             => Standard_String_Operations.Starts_With,
     Starts_With_Latin_1     => Standard_String_Operations.Starts_With_Latin_1,
     Ends_With               => Standard_String_Operations.Ends_With,
     Trim                    => Standard_String_Operations.Trim,
     From_Character          => Standard_String_Operations.From_Character,
     Concat_String_Latin_1   => Standard_String_Operations.Concat_String_Latin_1,
     Concat_Latin_1_String   => Standard_String_Operations.Concat_Latin_1_String);
