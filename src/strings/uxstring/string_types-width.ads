--  String_Types.Width — Display-width and grapheme-cluster re-exports (uxstring backend)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
--
--  @summary
--  Child package of String_Types exposing display-width and grapheme-cluster operations.
--
--  @description
--  Thin wrappers over the per-backend UXString_Width implementation package
--  (String_Type is a private wrapper on this backend, so the subprograms
--  taking or returning it cannot be plain renames), so that consumers can
--  opt in to the width API with "with String_Types.Width;" without forcing
--  Umwi into the dependency closure of every "with String_Types;"
--  (NFR-WIDTH-001).
--
--  Public surface is identical across all five backends (FUNC-WIDTH-002);
--  only the implementation differs.
--
--  SPARK_Mode is Off: the facade adds nothing provable (§9 of the tech-spec).
--
--  @relation FUNC-WIDTH-001, FUNC-WIDTH-002, FUNC-WIDTH-003, FUNC-WIDTH-004,
--            FUNC-WIDTH-005, FUNC-WIDTH-006, FUNC-WIDTH-010, FUNC-WIDTH-011,
--            FUNC-WIDTH-012, FUNC-WIDTH-013, FUNC-WIDTH-014, FUNC-WIDTH-015,
--            FUNC-WIDTH-016, NFR-WIDTH-001, NFR-WIDTH-003, NFR-WIDTH-004,
--            NFR-WIDTH-005

with UXString_Width;

private with UXString_Wrapper.Convert;

package String_Types.Width
  with SPARK_Mode => Off
is

   --  ---- Configuration (FUNC-WIDTH-006, NFR-WIDTH-003) ----

   subtype Width_Configuration is UXString_Width.Width_Configuration;
   subtype Width_Context is UXString_Width.Width_Context;

   Narrow : constant Width_Context := UXString_Width.Narrow;
   Wide   : constant Width_Context := UXString_Width.Wide;

   Default_Linux  : constant Width_Configuration := UXString_Width.Default_Linux;
   Default_Strict : constant Width_Configuration := UXString_Width.Default_Strict;

   --  ---- Grapheme cluster record and iterable view (FUNC-WIDTH-005) ----

   type Grapheme is record
      Width       : Natural;
      Code_Points : Positive;
      Slice       : String_Type;
   end record;

   type Grapheme_Cursor is private;

   type Grapheme_View is private
   with Iterable => (First => First, Next => Next, Has_Element => Has_Element, Element => Element);

   function First (V : Grapheme_View) return Grapheme_Cursor;

   function Has_Element (V : Grapheme_View; C : Grapheme_Cursor) return Boolean;

   function Next (V : Grapheme_View; C : Grapheme_Cursor) return Grapheme_Cursor;

   function Element (V : Grapheme_View; C : Grapheme_Cursor) return Grapheme;

   --  @relation FUNC-WIDTH-005
   function Graphemes (S : String_Type; Conf : Width_Configuration := Default_Linux) return Grapheme_View;

   --  ---- Width_Slice_Result (FUNC-WIDTH-014) ----

   type Width_Slice_Result is record
      Result    : String_Type;
      Width     : Natural;
      Truncated : Boolean;
   end record;

   --  ---- Pad_Side (FUNC-WIDTH-016) ----

   subtype Pad_Side is UXString_Width.Pad_Side;
   Left  : constant Pad_Side := UXString_Width.Left;
   Right : constant Pad_Side := UXString_Width.Right;
   Both  : constant Pad_Side := UXString_Width.Both;

   --  ---- Default_Ellipsis (FUNC-WIDTH-015) ----

   Default_Ellipsis : constant String_Type;

   --  ---- Scalar queries ----

   --  @relation FUNC-WIDTH-003
   function Display_Width (S : String_Type; Conf : Width_Configuration := Default_Linux) return Natural;

   --  @relation FUNC-WIDTH-004
   function Grapheme_Count (S : String_Type; Conf : Width_Configuration := Default_Linux) return Natural;

   --  @relation FUNC-WIDTH-010
   function Cluster_Length (S : String_Type; Conf : Width_Configuration := Default_Linux) return Natural
   renames Grapheme_Count;

   --  ---- Cluster-indexed operations ----

   --  @relation FUNC-WIDTH-011
   function Cluster_Element
     (S : String_Type; Index : Positive; Conf : Width_Configuration := Default_Linux) return Grapheme;

   --  @relation FUNC-WIDTH-012
   function Cluster_Slice
     (S : String_Type; From_Cluster : Positive; To_Cluster : Natural; Conf : Width_Configuration := Default_Linux)
      return String_Type;

   --  @relation FUNC-WIDTH-013
   function Cluster_Head
     (S : String_Type; Count : Natural; Conf : Width_Configuration := Default_Linux) return String_Type;

   --  @relation FUNC-WIDTH-013
   function Cluster_Tail
     (S : String_Type; Count : Natural; Conf : Width_Configuration := Default_Linux) return String_Type;

   --  ---- Width-budget helpers ----

   --  @relation FUNC-WIDTH-014
   function Head_By_Width
     (S                : String_Type;
      Max_Cells        : Natural;
      Allow_Split_Wide : Boolean := False;
      Conf             : Width_Configuration := Default_Linux) return Width_Slice_Result;

   --  @relation FUNC-WIDTH-015
   function Truncate_With_Ellipsis
     (S         : String_Type;
      Max_Cells : Natural;
      Ellipsis  : String_Type := Default_Ellipsis;
      Conf      : Width_Configuration := Default_Linux) return String_Type;

   --  @relation FUNC-WIDTH-016
   function Pad_To_Width
     (S            : String_Type;
      Target_Cells : Natural;
      Pad          : Character_Type := ' ';
      Side         : Pad_Side := Right;
      Conf         : Width_Configuration := Default_Linux) return String_Type;

private

   type Grapheme_Cursor is record
      Inner : UXString_Width.Grapheme_Cursor;
   end record;

   type Grapheme_View is record
      Inner : UXString_Width.Grapheme_View;
   end record;

   Default_Ellipsis : constant String_Type := UXString_Wrapper.Convert.From_UXString (UXString_Width.Default_Ellipsis);

end String_Types.Width;
