-------------------------------------------------------------------------------
--  String_Types.Width - display width and grapheme clusters
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Child package of String_Types for display width, grapheme clusters and the
--  width-budget helpers.
--
--  @description
--  The public types expose String_Type, not the unbounded representation of
--  the implementation package Wide_Wide_Width: Grapheme.Slice,
--  Width_Slice_Result.Result and Default_Ellipsis are String_Type values.
--  Grapheme_Cursor and Grapheme_View are private; the iterator functions
--  wrap the implementation's (see the body). The subprograms are wrappers,
--  so this package is SPARK_Mode Off like Wide_Wide_Width.
--
--  Public surface is identical across all five backends
--  (FUNC-FACADE-003, FUNC-WIDTH-001..016).
--
--  @relation FUNC-WIDTH-001, FUNC-WIDTH-002, FUNC-WIDTH-003, FUNC-WIDTH-004,
--            FUNC-WIDTH-005, FUNC-WIDTH-006, FUNC-WIDTH-010, FUNC-WIDTH-011,
--            FUNC-WIDTH-012, FUNC-WIDTH-013, FUNC-WIDTH-014, FUNC-WIDTH-015,
--            FUNC-WIDTH-016, NFR-WIDTH-001, NFR-WIDTH-003, NFR-WIDTH-004,
--            NFR-WIDTH-005

with Wide_Wide_Width;

package String_Types.Width
  with SPARK_Mode => Off
is

   --  ---- Configuration (FUNC-WIDTH-006, NFR-WIDTH-003) ----

   subtype Width_Configuration is Wide_Wide_Width.Width_Configuration;
   subtype Width_Context       is Wide_Wide_Width.Width_Context;

   Narrow : constant Width_Context := Wide_Wide_Width.Narrow;
   Wide   : constant Width_Context := Wide_Wide_Width.Wide;

   Default_Linux  : constant Width_Configuration := Wide_Wide_Width.Default_Linux;
   Default_Strict : constant Width_Configuration := Wide_Wide_Width.Default_Strict;

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
   function Graphemes
     (S    : String_Type;
      Conf : Width_Configuration := Default_Linux) return Grapheme_View;

   --  ---- Width_Slice_Result (FUNC-WIDTH-014) ----

   type Width_Slice_Result is record
      Result    : String_Type;
      Width     : Natural;
      Truncated : Boolean;
   end record;

   --  ---- Pad_Side (FUNC-WIDTH-016) ----

   subtype Pad_Side is Wide_Wide_Width.Pad_Side;
   Left  : constant Pad_Side := Wide_Wide_Width.Left;
   Right : constant Pad_Side := Wide_Wide_Width.Right;
   Both  : constant Pad_Side := Wide_Wide_Width.Both;

   --  ---- Default_Ellipsis (FUNC-WIDTH-015) ----

   --  Completed in the private part (it needs the private bridge of String_Types).
   Default_Ellipsis : constant String_Type;

   --  ---- Scalar queries ----

   --  @relation FUNC-WIDTH-003
   function Display_Width
     (S    : String_Type;
      Conf : Width_Configuration := Default_Linux) return Natural;

   --  @relation FUNC-WIDTH-004
   function Grapheme_Count
     (S    : String_Type;
      Conf : Width_Configuration := Default_Linux) return Natural;

   --  @relation FUNC-WIDTH-010
   function Cluster_Length
     (S    : String_Type;
      Conf : Width_Configuration := Default_Linux) return Natural;

   --  ---- Cluster-indexed operations ----

   --  @relation FUNC-WIDTH-011
   function Cluster_Element
     (S     : String_Type;
      Index : Positive;
      Conf  : Width_Configuration := Default_Linux) return Grapheme;

   --  @relation FUNC-WIDTH-012
   function Cluster_Slice
     (S            : String_Type;
      From_Cluster : Positive;
      To_Cluster   : Natural;
      Conf         : Width_Configuration := Default_Linux) return String_Type;

   --  @relation FUNC-WIDTH-013
   function Cluster_Head
     (S     : String_Type;
      Count : Natural;
      Conf  : Width_Configuration := Default_Linux) return String_Type;

   --  @relation FUNC-WIDTH-013
   function Cluster_Tail
     (S     : String_Type;
      Count : Natural;
      Conf  : Width_Configuration := Default_Linux) return String_Type;

   --  ---- Width-budget helpers ----

   --  @relation FUNC-WIDTH-014
   function Head_By_Width
     (S                : String_Type;
      Max_Cells        : Natural;
      Allow_Split_Wide : Boolean := False;
      Conf             : Width_Configuration := Default_Linux)
      return Width_Slice_Result;

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
      Pad          : Character_Type      := ' ';
      Side         : Pad_Side            := Right;
      Conf         : Width_Configuration := Default_Linux) return String_Type;

private

   type Grapheme_Cursor is record
      Inner : Wide_Wide_Width.Grapheme_Cursor;
   end record;

   type Grapheme_View is record
      Inner : Wide_Wide_Width.Grapheme_View;
   end record;

   Default_Ellipsis : constant String_Type := Wrap (Wide_Wide_Width.Default_Ellipsis);

end String_Types.Width;
