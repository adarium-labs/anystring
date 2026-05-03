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

   Empty_String : constant String_Type := Wide_Strings.Empty_String;

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
