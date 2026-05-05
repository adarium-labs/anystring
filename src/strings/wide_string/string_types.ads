-------------------------------------------------------------------------------
--  String_Types - Wide_String Configuration
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Re-exports string types and operations from Wide_Strings.
--
--  @description
--  This is the Wide_String variant of String_Types.

with Ada.Containers;
with Wide_Strings;
with Wide_String_Operations;

package String_Types is

   subtype String_Type is Wide_String_Operations.Unbounded_Wide_String;
   subtype Character_Type is Wide_Character;
   subtype File_Type is Wide_String_Operations.File_Type;
   subtype File_Mode is Wide_String_Operations.File_Mode;

   Empty_String : constant String_Type := Wide_Strings.Empty_String;
   In_File      : constant File_Mode := Wide_Strings.In_File;
   Out_File     : constant File_Mode := Wide_Strings.Out_File;
   Append_File  : constant File_Mode := Wide_Strings.Append_File;

   function Length (Source : String_Type) return Natural
     renames Wide_String_Operations.Length;

   function Is_Empty (Source : String_Type) return Boolean
     renames Wide_String_Operations.Is_Empty;

   function Get_Length (Source : String_Type) return Natural
     renames Wide_Strings.Get_Length;

   function Is_Null_Or_Empty (Source : String_Type) return Boolean
     renames Wide_Strings.Is_Null_Or_Empty;

   function Element
     (Source : String_Type;
      Index  : Positive) return Character_Type
     renames Wide_String_Operations.Element;

   function Get_Element
     (Source : String_Type;
      Index  : Positive) return Character_Type
     renames Wide_Strings.Get_Element;

   function First_Index (Source : String_Type) return Positive
     renames Wide_Strings.First_Index;

   function Last_Index (Source : String_Type) return Natural
     renames Wide_Strings.Last_Index;

   function Get_Env (Name : String_Type) return String_Type
     renames Wide_Strings.Get_Env;

   function Get_Env
     (Name    : String_Type;
      Default : String_Type) return String_Type
     renames Wide_Strings.Get_Env;

   function Env_Exists (Name : String_Type) return Boolean
     renames Wide_Strings.Env_Exists;

   subtype Env_Processor is Wide_Strings.Env_Processor;
   subtype Env_Filter is Wide_Strings.Env_Filter;

   function Set_Env
     (Name  : String_Type;
      Value : String_Type) return Boolean
     renames Wide_Strings.Set_Env;

   function Clear_Env (Name : String_Type) return Boolean
     renames Wide_Strings.Clear_Env;

   function Clear_Env return Boolean
     renames Wide_Strings.Clear_Env;

   function Iterate_Env (Process : Env_Processor) return Boolean
     renames Wide_Strings.Iterate_Env;

   function Iterate_Env
     (Include : Env_Filter;
      Process : Env_Processor) return Boolean
     renames Wide_Strings.Iterate_Env;

   procedure Create
     (File : in out File_Type;
      Mode : File_Mode := Out_File;
      Name : String := "")
     renames Wide_Strings.Create;

   procedure Open
     (File : in out File_Type;
      Mode : File_Mode;
      Name : String)
     renames Wide_Strings.Open;

   procedure Close
     (File : in out File_Type)
     renames Wide_Strings.Close;

   function Is_Open (File : File_Type) return Boolean
     renames Wide_Strings.Is_Open;

   function Current_Input return File_Type
     renames Wide_Strings.Current_Input;

   function Current_Output return File_Type
     renames Wide_Strings.Current_Output;

   procedure Set_Input (File : File_Type)
     renames Wide_Strings.Set_Input;

   procedure Set_Output (File : File_Type)
     renames Wide_Strings.Set_Output;

   procedure Put
     (File : File_Type;
      Item : String_Type)
     renames Wide_Strings.Put;

   procedure Put (Item : String_Type)
     renames Wide_Strings.Put;

   procedure Put_Line
     (File : File_Type;
      Item : String_Type)
     renames Wide_Strings.Put_Line;

   procedure Put_Line (Item : String_Type)
     renames Wide_Strings.Put_Line;

   function Get_Line (File : File_Type) return String_Type
     renames Wide_Strings.Get_Line;

   function Get_Line return String_Type
     renames Wide_Strings.Get_Line;

   procedure Get_Line
     (File : File_Type;
      Item : out String_Type)
     renames Wide_Strings.Get_Line;

   procedure Get_Line (Item : out String_Type)
     renames Wide_Strings.Get_Line;

   procedure New_Line (File : File_Type)
     renames Wide_Strings.New_Line;

   procedure New_Line
     renames Wide_Strings.New_Line;

   function End_Of_File (File : File_Type) return Boolean
     renames Wide_Strings.End_Of_File;

   function End_Of_File return Boolean
     renames Wide_Strings.End_Of_File;

   function Contains (Source : String_Type; Pattern : String_Type) return Boolean
     renames Wide_Strings.Contains;

   function Concat
     (Left  : String_Type;
      Right : String_Type) return String_Type
     renames Wide_Strings.Concat;

   function Append_Character
     (Left  : String_Type;
      Right : Character_Type) return String_Type
     renames Wide_Strings.Append_Character;

   function Prepend_Character
     (Left  : Character_Type;
      Right : String_Type) return String_Type
     renames Wide_Strings.Prepend_Character;

   function "&"
     (Left  : String_Type;
      Right : String_Type) return String_Type
     renames Wide_String_Operations.Concat_Strings;

   function "&"
     (Left  : String_Type;
      Right : Character_Type) return String_Type
     renames Wide_String_Operations.Concat_String_Character;

   function "&"
     (Left  : Character_Type;
      Right : String_Type) return String_Type
     renames Wide_String_Operations.Concat_Character_String;

   function "&"
     (Left  : String_Type;
      Right : String) return String_Type
     renames Wide_String_Operations.Concat_String_Latin_1;

   function "&"
     (Left  : String;
      Right : String_Type) return String_Type
     renames Wide_String_Operations.Concat_Latin_1_String;

   function "=" (Left, Right : String_Type) return Boolean
     renames Wide_Strings.Equal;

   function "<" (Left, Right : String_Type) return Boolean
     renames Wide_Strings.Less_Than;

   function "<=" (Left, Right : String_Type) return Boolean
     renames Wide_Strings.Less_Or_Equal;

   function ">" (Left, Right : String_Type) return Boolean
     renames Wide_Strings.Greater_Than;

   function ">=" (Left, Right : String_Type) return Boolean
     renames Wide_Strings.Greater_Or_Equal;

   function To_String_Type (Source : String) return String_Type
     renames Wide_String_Operations.To_Unbounded_Wide_String;

   function To_Latin_1 (Source : String_Type) return String
     renames Wide_String_Operations.To_String;

   function Hash (Key : String_Type) return Ada.Containers.Hash_Type
     renames Wide_String_Operations.Hash;

   function Slice
     (Source : String_Type;
      Low    : Positive;
      High   : Natural) return String_Type
     renames Wide_String_Operations.Slice;

   function Index
     (Source  : String_Type;
      Pattern : String_Type) return Natural
     renames Wide_String_Operations.Index;

   function Index
     (Source  : String_Type;
      Pattern : String) return Natural
     renames Wide_String_Operations.Index_Latin_1;

   function To_Lower (Source : String_Type) return String_Type
     renames Wide_String_Operations.To_Lower;

   function To_Upper (Source : String_Type) return String_Type
     renames Wide_String_Operations.To_Upper;

   function Starts_With
     (Source : String_Type;
      Prefix : String_Type) return Boolean
     renames Wide_String_Operations.Starts_With;

   function Starts_With
     (Source : String_Type;
      Prefix : String) return Boolean
     renames Wide_String_Operations.Starts_With_Latin_1;

   function Ends_With
     (Source : String_Type;
      Suffix : String_Type) return Boolean
     renames Wide_String_Operations.Ends_With;

   function Trim (Source : String_Type) return String_Type
     renames Wide_String_Operations.Trim;

   function From_Character (C : Character_Type) return String_Type
     renames Wide_String_Operations.From_Character;

   function Is_Equals_Sign (C : Character_Type) return Boolean
   is (C = '=');

   function Is_Dash (C : Character_Type) return Boolean
   is (C = '-');

end String_Types;
