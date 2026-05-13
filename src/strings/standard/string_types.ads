-------------------------------------------------------------------------------
--  String_Types - Standard String Configuration
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Re-exports string types and operations from Standard_Strings.
--
--  @description
--  This is the Standard (Unbounded_String) variant of String_Types.
--  It uses Ada.Strings.Unbounded.Unbounded_String as the underlying type.

with Ada.Containers;
with Standard_Strings;
with Standard_String_Operations;
with Standard_UTF_8_Results;
with Standard_UTF_8_Bridge;
with Anystrings_UTF_8;

package String_Types is

   subtype String_Type is Standard_String_Operations.Unbounded_String;
   subtype Character_Type is Character;
   subtype File_Type is Standard_String_Operations.File_Type;
   subtype File_Mode is Standard_String_Operations.File_Mode;

   Empty_String : constant String_Type := Standard_Strings.Empty_String;
   In_File      : constant File_Mode := Standard_Strings.In_File;
   Out_File     : constant File_Mode := Standard_Strings.Out_File;
   Append_File  : constant File_Mode := Standard_Strings.Append_File;

   function Length (Source : String_Type) return Natural renames Standard_String_Operations.Length;

   function Is_Empty (Source : String_Type) return Boolean renames Standard_String_Operations.Is_Empty;

   function Get_Length (Source : String_Type) return Natural renames Standard_Strings.Get_Length;

   function Is_Null_Or_Empty (Source : String_Type) return Boolean renames Standard_Strings.Is_Null_Or_Empty;

   function Element (Source : String_Type; Index : Positive) return Character_Type
   renames Standard_String_Operations.Element;

   function Get_Element (Source : String_Type; Index : Positive) return Character_Type
   renames Standard_Strings.Get_Element;

   function First_Index (Source : String_Type) return Positive renames Standard_Strings.First_Index;

   function Last_Index (Source : String_Type) return Natural renames Standard_Strings.Last_Index;

   function Get_Env (Name : String_Type) return String_Type renames Standard_Strings.Get_Env;

   function Get_Env (Name : String_Type; Default : String_Type) return String_Type renames Standard_Strings.Get_Env;

   function Env_Exists (Name : String_Type) return Boolean renames Standard_Strings.Env_Exists;

   subtype Env_Processor is Standard_Strings.Env_Processor;
   subtype Env_Filter is Standard_Strings.Env_Filter;

   function Set_Env (Name : String_Type; Value : String_Type) return Boolean renames Standard_Strings.Set_Env;

   function Clear_Env (Name : String_Type) return Boolean renames Standard_Strings.Clear_Env;

   function Clear_Env return Boolean renames Standard_Strings.Clear_Env;

   function Iterate_Env (Process : Env_Processor) return Boolean renames Standard_Strings.Iterate_Env;

   function Iterate_Env (Include : Env_Filter; Process : Env_Processor) return Boolean
   renames Standard_Strings.Iterate_Env;

   procedure Create (File : in out File_Type; Mode : File_Mode := Out_File; Name : String := "")
   renames Standard_Strings.Create;

   procedure Open (File : in out File_Type; Mode : File_Mode; Name : String) renames Standard_Strings.Open;

   procedure Close (File : in out File_Type) renames Standard_Strings.Close;

   function Is_Open (File : File_Type) return Boolean renames Standard_Strings.Is_Open;

   function Current_Input return File_Type renames Standard_Strings.Current_Input;

   function Current_Output return File_Type renames Standard_Strings.Current_Output;

   procedure Set_Input (File : File_Type) renames Standard_Strings.Set_Input;

   procedure Set_Output (File : File_Type) renames Standard_Strings.Set_Output;

   procedure Put (File : File_Type; Item : String_Type) renames Standard_Strings.Put;

   procedure Put (Item : String_Type) renames Standard_Strings.Put;

   procedure Put_Line (File : File_Type; Item : String_Type) renames Standard_Strings.Put_Line;

   procedure Put_Line (Item : String_Type) renames Standard_Strings.Put_Line;

   function Get_Line (File : File_Type) return String_Type renames Standard_String_Operations.Get_Line_File;

   function Get_Line return String_Type renames Standard_Strings.Get_Line;

   procedure Get_Line (File : File_Type; Item : out String_Type) renames Standard_Strings.Get_Line;

   procedure Get_Line (Item : out String_Type) renames Standard_Strings.Get_Line;

   procedure New_Line (File : File_Type) renames Standard_Strings.New_Line;

   procedure New_Line renames Standard_Strings.New_Line;

   function End_Of_File (File : File_Type) return Boolean renames Standard_String_Operations.End_Of_File_File;

   function End_Of_File return Boolean renames Standard_Strings.End_Of_File;

   function Contains (Source : String_Type; Pattern : String_Type) return Boolean renames Standard_Strings.Contains;

   function Concat (Left : String_Type; Right : String_Type) return String_Type renames Standard_Strings.Concat;

   function Append_Character (Left : String_Type; Right : Character_Type) return String_Type
   renames Standard_Strings.Append_Character;

   function Prepend_Character (Left : Character_Type; Right : String_Type) return String_Type
   renames Standard_Strings.Prepend_Character;

   function "&" (Left : String_Type; Right : String_Type) return String_Type
   renames Standard_String_Operations.Concat_Strings;

   function "&" (Left : String_Type; Right : Character_Type) return String_Type
   renames Standard_String_Operations.Concat_String_Character;

   function "&" (Left : Character_Type; Right : String_Type) return String_Type
   renames Standard_String_Operations.Concat_Character_String;

   function "&" (Left : String_Type; Right : String) return String_Type
   renames Standard_String_Operations.Concat_String_Latin_1;

   function "&" (Left : String; Right : String_Type) return String_Type
   renames Standard_String_Operations.Concat_Latin_1_String;

   function "=" (Left, Right : String_Type) return Boolean renames Standard_Strings.Equal;

   function "<" (Left, Right : String_Type) return Boolean renames Standard_Strings.Less_Than;

   function "<=" (Left, Right : String_Type) return Boolean renames Standard_Strings.Less_Or_Equal;

   function ">" (Left, Right : String_Type) return Boolean renames Standard_Strings.Greater_Than;

   function ">=" (Left, Right : String_Type) return Boolean renames Standard_Strings.Greater_Or_Equal;

   function To_String_Type (Source : String) return String_Type renames Standard_String_Operations.To_Unbounded_String;

   function To_Latin_1 (Source : String_Type) return String renames Standard_String_Operations.To_String;

   --  ----- UTF-8 boundary (FUNC-UTF8-001..013, NFR-UTF8-006) -----

   --  @relation FUNC-UTF8-001, FUNC-UTF8-002, FUNC-UTF8-003, FUNC-UTF8-008, NFR-UTF8-006

   subtype UTF_8_Decode_Error is Anystrings_UTF_8.UTF_8_Decode_Error;

   --  Re-export enum literals so that "use String_Types" makes them
   --  directly visible to callers (a subtype alone does not do this in Ada).
   Invalid_Lead_Byte       : constant UTF_8_Decode_Error := Anystrings_UTF_8.Invalid_Lead_Byte;
   Truncated_Sequence      : constant UTF_8_Decode_Error := Anystrings_UTF_8.Truncated_Sequence;
   Invalid_Continuation    : constant UTF_8_Decode_Error := Anystrings_UTF_8.Invalid_Continuation;
   Overlong_Encoding       : constant UTF_8_Decode_Error := Anystrings_UTF_8.Overlong_Encoding;
   Surrogate_Code_Point    : constant UTF_8_Decode_Error := Anystrings_UTF_8.Surrogate_Code_Point;
   Code_Point_Out_Of_Range : constant UTF_8_Decode_Error := Anystrings_UTF_8.Code_Point_Out_Of_Range;

   function "=" (Left, Right : UTF_8_Decode_Error) return Boolean renames Anystrings_UTF_8."=";

   subtype UTF_8_Decode_Result is Standard_UTF_8_Results.UTF_8_Decode_Result;

   function To_UTF_8 (Source : String_Type) return String renames Standard_String_Operations.To_UTF_8;

   function From_UTF_8 (Source : String) return UTF_8_Decode_Result renames Standard_UTF_8_Bridge.From_UTF_8_Standard;

   function Is_Ok (R : UTF_8_Decode_Result) return Boolean renames Standard_UTF_8_Results.Is_Ok;

   function Get_Value (R : UTF_8_Decode_Result) return String_Type renames Standard_UTF_8_Results.Get_Value;

   --  @relation FUNC-UTF8-014, NFR-UTF8-002
   function Get_Value_Or
     (R        : UTF_8_Decode_Result;
      Fallback : String_Type) return String_Type
     renames Standard_UTF_8_Results.Get_Value_Or;

   function Get_Error (R : UTF_8_Decode_Result) return UTF_8_Decode_Error renames Standard_UTF_8_Results.Get_Error;

   function As_UTF_8 (Source : String_Type) return String renames Standard_Strings.As_UTF_8;

   function Decode_UTF_8 (Source : String) return UTF_8_Decode_Result renames Standard_Strings.Decode_UTF_8;

   function UTF_8_Is_Valid (Source : String) return Boolean renames Standard_Strings.UTF_8_Is_Valid;

   function Hash (Key : String_Type) return Ada.Containers.Hash_Type renames Standard_String_Operations.Hash;

   function Slice (Source : String_Type; Low : Positive; High : Natural) return String_Type
   renames Standard_String_Operations.Slice;

   function Index (Source : String_Type; Pattern : String_Type) return Natural renames Standard_String_Operations.Index;

   function Index (Source : String_Type; Pattern : String) return Natural
   renames Standard_String_Operations.Index_Latin_1;

   function To_Lower (Source : String_Type) return String_Type renames Standard_String_Operations.To_Lower;

   function To_Upper (Source : String_Type) return String_Type renames Standard_String_Operations.To_Upper;

   function Starts_With (Source : String_Type; Prefix : String_Type) return Boolean
   renames Standard_String_Operations.Starts_With;

   function Starts_With (Source : String_Type; Prefix : String) return Boolean
   renames Standard_String_Operations.Starts_With_Latin_1;

   function Ends_With (Source : String_Type; Suffix : String_Type) return Boolean
   renames Standard_String_Operations.Ends_With;

   function Trim (Source : String_Type) return String_Type renames Standard_String_Operations.Trim;

   function From_Character (C : Character_Type) return String_Type renames Standard_String_Operations.From_Character;

   function Is_Equals_Sign (C : Character_Type) return Boolean
   is (C = '=');

   function Is_Dash (C : Character_Type) return Boolean
   is (C = '-');

end String_Types;
