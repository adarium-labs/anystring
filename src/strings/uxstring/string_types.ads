-------------------------------------------------------------------------------
--  String_Types - UXString Configuration
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  UXString variant of String_Types: a private wrapper over UXStrings.UXString.
--
--  @description
--  This is the UXString variant of String_Types. It provides full
--  Unicode support with proper code point handling.
--
--  Unlike the other backends, `String_Type` is a PRIVATE type here. Its full
--  view (a record holding a UXStrings.UXString) lives in a SPARK_Mode Off
--  private part. The reason is that UXStrings.UXString carries an Iterable
--  aspect whose functions read globals, which GNATprove refuses in SPARK; a
--  private type with an Off full view keeps that type out of every SPARK
--  client. The length contracts below are therefore usable by SPARK clients
--  on this backend too. They are trusted (the bodies are SPARK_Mode Off) and
--  checked at run time by the tests built with assertions enabled.
--
--  Consequence for users of this backend: `String_Type` is not a
--  UXStrings.UXString any more. Use the operations of this package (or
--  To_String_Type / To_Latin_1 / To_UTF_8 / From_UTF_8) instead of UXStrings
--  operations, string literals, indexing or `for ... of` iteration directly on
--  a `String_Type`.
--
--  To use this variant, set `STRING_TYPE` environment variable to `uxstring`.

with Ada.Containers;
with Anystrings_UTF_8;
with Anystrings_Invalid_Policy;

private with UXStrings;
private with UXString_UTF_8_Results;
private with UXString_WWS_Decode_Results;

package String_Types
  with SPARK_Mode
is

   type String_Type is private;
   subtype Character_Type is Wide_Wide_Character;

   function Length (Source : String_Type) return Natural
   with Global => null;

   function Is_Empty (Source : String_Type) return Boolean
   with Global => null, Post => Is_Empty'Result = (Length (Source) = 0);

   function Null_String_Value return String_Type
   with Global => null, Post => Length (Null_String_Value'Result) = 0;

   --  A function, not a constant: a constant of a private type cannot be
   --  initialised in the visible part, and a deferred constant would hide its
   --  value from SPARK clients. Call syntax is identical (`Empty_String`).
   function Empty_String return String_Type
   with Global => null, Post => Length (Empty_String'Result) = 0;

   function Get_Length (Source : String_Type) return Natural;

   function Is_Null_Or_Empty (Source : String_Type) return Boolean;

   function Element (Source : String_Type; Index : Positive) return Character_Type;

   function Get_Element (Source : String_Type; Index : Positive) return Character_Type;

   function First_Index (Source : String_Type) return Positive;

   function Last_Index (Source : String_Type) return Natural;

   function Contains (Source : String_Type; Pattern : String_Type) return Boolean;

   function Concat (Left : String_Type; Right : String_Type) return String_Type
   with
     Global => null,
     Pre    => Length (Right) <= Natural'Last - Length (Left),
     Post   => Length (Concat'Result) = Length (Left) + Length (Right);

   function "&" (Left : String_Type; Right : String_Type) return String_Type
   with
     Global => null,
     Pre    => Length (Right) <= Natural'Last - Length (Left),
     Post   => Length ("&"'Result) = Length (Left) + Length (Right);

   function "&" (Left : String_Type; Right : Character_Type) return String_Type
   with Global => null, Pre => Length (Left) < Natural'Last, Post => Length ("&"'Result) = Length (Left) + 1;

   function "&" (Left : Character_Type; Right : String_Type) return String_Type
   with Global => null, Pre => Length (Right) < Natural'Last, Post => Length ("&"'Result) = 1 + Length (Right);

   function "&" (Left : String_Type; Right : String) return String_Type
   with
     Global => null,
     Pre    => Right'Length <= Natural'Last - Length (Left),
     Post   => Length ("&"'Result) = Length (Left) + Right'Length;

   function "&" (Left : String; Right : String_Type) return String_Type
   with
     Global => null,
     Pre    => Left'Length <= Natural'Last - Length (Right),
     Post   => Length ("&"'Result) = Left'Length + Length (Right);

   function Append_Character (Left : String_Type; Right : Character_Type) return String_Type
   with
     Global => null,
     Pre    => Length (Left) < Natural'Last,
     Post   => Length (Append_Character'Result) = Length (Left) + 1;

   function Prepend_Character (Left : Character_Type; Right : String_Type) return String_Type
   with
     Global => null,
     Pre    => Length (Right) < Natural'Last,
     Post   => Length (Prepend_Character'Result) = 1 + Length (Right);

   procedure Append (Source : in out String_Type; New_Item : String_Type)
   with
     Global => null,
     Pre    => Length (New_Item) <= Natural'Last - Length (Source),
     Post   => Length (Source) = Length (Source'Old) + Length (New_Item);

   overriding
   function "=" (Left, Right : String_Type) return Boolean;

   function "<" (Left, Right : String_Type) return Boolean;

   function "<=" (Left, Right : String_Type) return Boolean;

   function ">" (Left, Right : String_Type) return Boolean;

   function ">=" (Left, Right : String_Type) return Boolean;

   --  UXStrings.From_UTF_8 decodes UTF-8, so a Latin-1 byte above 0x7F is not
   --  one code point. The length equality therefore holds only for ASCII input.
   function To_String_Type (Source : String) return String_Type
   with
     Global => null,
     Post   =>
       (if (for all C of Source => Character'Pos (C) < 128) then Length (To_String_Type'Result) = Source'Length);

   function To_Latin_1 (Source : String_Type) return String;

   --  ----- UTF-8 boundary (FUNC-UTF8-001..013, NFR-UTF8-006) -----

   --  @relation FUNC-UTF8-001, FUNC-UTF8-002, FUNC-UTF8-003, FUNC-UTF8-008,
   --            FUNC-UTF8-013, NFR-UTF8-006

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

   --  Private on this backend (it holds a String_Type); accessed through
   --  Is_Ok / Get_Value / Get_Value_Or / Get_Error.
   type UTF_8_Decode_Result is private;

   function To_UTF_8 (Source : String_Type) return String;

   function From_UTF_8 (Source : String) return UTF_8_Decode_Result;

   --  ----- Wide_Wide_String boundary (code-point interchange) -----

   --  @summary Extract the storage as a Wide_Wide_String of code-points.
   --  Total; never raises. UXString stores validated Unicode scalars.
   function To_Wide_Wide_String (Source : String_Type) return Wide_Wide_String;

   --  @summary Build a String_Type from a Wide_Wide_String. Total; never
   --  raises. Surrogate code-points and values greater than U+10FFFF are
   --  substituted with `Invalid_Substitute_Codepoint` before being
   --  embedded in the result.
   function From_Wide_Wide_String (Source : Wide_Wide_String) return String_Type;

   --  @summary The Unicode code-point this backend emits for invalid input
   --  code-points (surrogates or values > U+10FFFF). The uxstring backend
   --  uses U+FFFD REPLACEMENT CHARACTER.
   Invalid_Substitute_Codepoint : constant Wide_Wide_Character := Wide_Wide_Character'Val (16#FFFD#);

   --  ----- Wide_Wide_String boundary - per-call invalid-code-point policy -----
   --  (Fix 2 Tier 2)

   subtype Invalid_Codepoint_Policy is Anystrings_Invalid_Policy.Invalid_Codepoint_Policy;

   Backend_Default : constant Invalid_Codepoint_Policy := Anystrings_Invalid_Policy.Backend_Default;
   Substitute_With : constant Invalid_Codepoint_Policy := Anystrings_Invalid_Policy.Substitute_With;
   Skip            : constant Invalid_Codepoint_Policy := Anystrings_Invalid_Policy.Skip;
   Report_As_Error : constant Invalid_Codepoint_Policy := Anystrings_Invalid_Policy.Report_As_Error;

   function "=" (Left, Right : Invalid_Codepoint_Policy) return Boolean renames Anystrings_Invalid_Policy."=";

   subtype WWS_Error_Kind is Anystrings_Invalid_Policy.WWS_Error_Kind;

   Surrogate_Codepoint    : constant WWS_Error_Kind := Anystrings_Invalid_Policy.Surrogate_Codepoint;
   Out_Of_Range_Codepoint : constant WWS_Error_Kind := Anystrings_Invalid_Policy.Out_Of_Range_Codepoint;

   function "=" (Left, Right : WWS_Error_Kind) return Boolean renames Anystrings_Invalid_Policy."=";

   subtype WWS_Failure is Anystrings_Invalid_Policy.WWS_Failure;

   --  Private on this backend (it holds a String_Type), like UTF_8_Decode_Result.
   type WWS_Decode_Result is private;

   function Is_Ok (R : WWS_Decode_Result) return Boolean;

   function Get_Value (R : WWS_Decode_Result) return String_Type
   with Pre => Is_Ok (R);

   function Get_Value_Or (R : WWS_Decode_Result; Fallback : String_Type) return String_Type;

   function Get_Error (R : WWS_Decode_Result) return WWS_Failure
   with Pre => not Is_Ok (R);

   function From_Wide_Wide_String_With_Substitute
     (Source : Wide_Wide_String; Substitute : Wide_Wide_Character) return String_Type
   with Pre => Anystrings_Invalid_Policy.Is_Valid_Scalar (Substitute);

   function From_Wide_Wide_String_Skip_Invalid (Source : Wide_Wide_String) return String_Type;

   function From_Wide_Wide_String_Checked (Source : Wide_Wide_String) return WWS_Decode_Result;

   function From_Wide_Wide_String_Policy
     (Source     : Wide_Wide_String;
      Policy     : Invalid_Codepoint_Policy;
      Substitute : Wide_Wide_Character := Wide_Wide_Character'Val (16#FFFD#)) return String_Type
   is (if Policy = Backend_Default
       then From_Wide_Wide_String (Source)
       elsif Policy = Substitute_With
       then From_Wide_Wide_String_With_Substitute (Source, Substitute)
       else From_Wide_Wide_String_Skip_Invalid (Source))
   with
     Pre =>
       Policy /= Report_As_Error
       and then (if Policy = Substitute_With then Anystrings_Invalid_Policy.Is_Valid_Scalar (Substitute));

   function Is_Ok (R : UTF_8_Decode_Result) return Boolean;

   function Get_Value (R : UTF_8_Decode_Result) return String_Type
   with Pre => Is_Ok (R);

   --  @relation FUNC-UTF8-014, NFR-UTF8-002
   function Get_Value_Or (R : UTF_8_Decode_Result; Fallback : String_Type) return String_Type;

   function Get_Error (R : UTF_8_Decode_Result) return UTF_8_Decode_Error
   with Pre => not Is_Ok (R);

   function As_UTF_8 (Source : String_Type) return String;

   function Decode_UTF_8 (Source : String) return UTF_8_Decode_Result;

   function UTF_8_Is_Valid (Source : String) return Boolean;

   function Hash (Key : String_Type) return Ada.Containers.Hash_Type;

   function Slice (Source : String_Type; Low : Positive; High : Natural) return String_Type
   with
     Global => null,
     Pre    => Low - 1 <= Length (Source) and then High <= Length (Source),
     Post   => Length (Slice'Result) = (if High < Low then 0 else High - Low + 1);

   function Index (Source : String_Type; Pattern : String_Type) return Natural;

   function Index (Source : String_Type; Pattern : String) return Natural;

   function Index_From (Source : String_Type; Pattern : String_Type; Starting_At : Positive) return Natural;

   function Index_From (Source : String_Type; Pattern : String; Starting_At : Positive) return Natural
   is (Index_From (Source, To_String_Type (Pattern), Starting_At));

   function Index_Reverse (Source : String_Type; Pattern : String_Type) return Natural;

   function Replace (Source : String_Type; Pattern : String_Type; By : String_Type) return String_Type;

   function Replace (Source : String_Type; Pattern : String; By : String_Type) return String_Type
   is (Replace (Source, To_String_Type (Pattern), By));

   function Replace (Source : String_Type; Pattern : String_Type; By : String) return String_Type
   is (Replace (Source, Pattern, To_String_Type (By)));

   function Head (Source : String_Type; Count : Natural; Pad : Character_Type) return String_Type;

   function Tail (Source : String_Type; Count : Natural; Pad : Character_Type) return String_Type;

   function To_Lower (Source : String_Type) return String_Type;

   function To_Upper (Source : String_Type) return String_Type;

   function Starts_With (Source : String_Type; Prefix : String_Type) return Boolean;

   function Starts_With (Source : String_Type; Prefix : String) return Boolean;

   function Ends_With (Source : String_Type; Suffix : String_Type) return Boolean;

   function Trim (Source : String_Type) return String_Type;

   function From_Character (C : Character_Type) return String_Type;

   function Is_Equals_Sign (C : Character_Type) return Boolean
   is (Wide_Wide_Character'Pos (C) = Character'Pos ('='));

   function Is_Dash (C : Character_Type) return Boolean
   is (Wide_Wide_Character'Pos (C) = Character'Pos ('-'));

   ---------------------------------------------------------------------------
   --  Character Classification & Case Mapping
   ---------------------------------------------------------------------------
   --  Unicode-aware via Ada.Wide_Wide_Characters.Handling. Is_Whitespace
   --  includes ASCII + Unicode Space_Separator. Is_Line_Terminator
   --  covers LF, CR, NEL (U+0085), LS (U+2028), PS (U+2029).

   function Is_Alphanumeric (C : Character_Type) return Boolean;

   function Is_Control (C : Character_Type) return Boolean;

   function Is_Digit (C : Character_Type) return Boolean;

   function Is_Graphic (C : Character_Type) return Boolean;

   function Is_Hex_Digit (C : Character_Type) return Boolean;

   function Is_Letter (C : Character_Type) return Boolean;

   function Is_Line_Terminator (C : Character_Type) return Boolean;

   function Is_Lower (C : Character_Type) return Boolean;

   function Is_Upper (C : Character_Type) return Boolean;

   function Is_Whitespace (C : Character_Type) return Boolean;

   function To_Lower (C : Character_Type) return Character_Type;

   function To_Upper (C : Character_Type) return Character_Type;

   ---------------------------------------------------------------------------

private
   pragma SPARK_Mode (Off);

   --  The full views are outside SPARK: UXStrings.UXString has an Iterable
   --  aspect whose functions read globals, which GNATprove rejects.

   type String_Type is record
      Value : UXStrings.UXString;
   end record;

   type UTF_8_Decode_Result is record
      Inner : UXString_UTF_8_Results.UTF_8_Decode_Result;
   end record;

   type WWS_Decode_Result is record
      Inner : UXString_WWS_Decode_Results.WWS_Decode_Result;
   end record;

end String_Types;
