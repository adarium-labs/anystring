--  Standard_Width — Display-width and grapheme-cluster operations (standard backend)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
--
--  @summary
--  Per-backend implementation package for String_Types.Width on the standard
--  (Unbounded_String) backend.
--
--  @description
--  Flat (non-child) implementation unit that declares the real types and
--  subprograms for display-width and grapheme-cluster operations on
--  Standard_String_Operations.Unbounded_String.
--
--  This is the only unit for the standard backend that withs Umwi.
--  All cluster walks route through the UTF-8 path:
--    To_UTF_8 (S) -> Umwi.Clusters (UTF8_String, Conf).
--
--  Purpose: Expose display-width / grapheme-cluster surface for String_Types.Width renames.
--  Responsibilities:
--    * Declare Width_Configuration, Width_Context, Grapheme, Grapheme_View,
--      Width_Slice_Result, Pad_Side types and associated constants.
--    * Declare Display_Width, Grapheme_Count, Cluster_Length, Cluster_Element,
--      Cluster_Slice, Cluster_Head, Cluster_Tail, Head_By_Width,
--      Truncate_With_Ellipsis, Pad_To_Width, Graphemes subprograms.
--    * Declare Default_Ellipsis constant (U+2026 via UTF-8 boundary, §7).
--  External Effects: None (pure computation).
--  Thread Safety: Stateless; safe to call from multiple tasks simultaneously.
--  SPARK Status: SPARK_Mode Off — Umwi uses access types and dispatching
--                constructs incompatible with SPARK.
--
--  @relation FUNC-WIDTH-001, FUNC-WIDTH-002, FUNC-WIDTH-003, FUNC-WIDTH-004,
--            FUNC-WIDTH-005, FUNC-WIDTH-006, FUNC-WIDTH-007, FUNC-WIDTH-010,
--            FUNC-WIDTH-011, FUNC-WIDTH-012, FUNC-WIDTH-013, FUNC-WIDTH-014,
--            FUNC-WIDTH-015, FUNC-WIDTH-016, NFR-WIDTH-001, NFR-WIDTH-003,
--            NFR-WIDTH-004

with Standard_String_Operations;
with Standard_UTF_8_Bridge;
with Standard_UTF_8_Results;
with Umwi;

package Standard_Width with SPARK_Mode => Off is

   --  ---- Configuration (FUNC-WIDTH-006, NFR-WIDTH-003) ----

   subtype Width_Configuration is Umwi.Configuration;
   subtype Width_Context       is Umwi.Contexts;

   Narrow : constant Width_Context := Umwi.Narrow;
   Wide   : constant Width_Context := Umwi.Wide;

   Default_Linux  : constant Width_Configuration := Umwi.Defaults.Linux;
   Default_Strict : constant Width_Configuration := Umwi.Defaults.Strict;

   --  @relation NFR-WIDTH-004
   Encoding_Error : exception renames Umwi.Encoding_Error;

   --  ---- Grapheme cluster record and iterable view (FUNC-WIDTH-005) ----

   type Grapheme is record
      Width       : Natural;                                      -- display columns (0, 1, or 2)
      Code_Points : Positive;                                     -- number of code points in the cluster
      Slice       : Standard_String_Operations.Unbounded_String;  -- cluster text as String_Type
   end record;

   type Grapheme_Cursor is private;
   type Grapheme_View is private
     with Iterable => (First       => First,
                       Next        => Next,
                       Has_Element => Has_Element,
                       Element     => Element);

   function First
     (V : Grapheme_View) return Grapheme_Cursor;
   function Has_Element
     (V : Grapheme_View; C : Grapheme_Cursor) return Boolean;
   function Next
     (V : Grapheme_View; C : Grapheme_Cursor) return Grapheme_Cursor;
   function Element
     (V : Grapheme_View; C : Grapheme_Cursor) return Grapheme;

   --  @relation FUNC-WIDTH-005
   function Graphemes
     (S    : Standard_String_Operations.Unbounded_String;
      Conf : Width_Configuration := Default_Linux) return Grapheme_View;

   --  ---- Width_Slice_Result (FUNC-WIDTH-014) ----

   type Width_Slice_Result is record
      Result    : Standard_String_Operations.Unbounded_String;
      Width     : Natural;
      Truncated : Boolean;
   end record;

   --  ---- Pad_Side (FUNC-WIDTH-016) ----

   type Pad_Side is (Left, Right, Both);

   --  ---- Default_Ellipsis (FUNC-WIDTH-015, §7) ----
   --  U+2026 HORIZONTAL ELLIPSIS via From_UTF_8; ASCII "..." fallback (never triggered).
   Default_Ellipsis : constant Standard_String_Operations.Unbounded_String :=
     Standard_UTF_8_Results.Get_Value_Or
       (Standard_UTF_8_Bridge.From_UTF_8_Standard
          (String'(Character'Val (16#E2#), Character'Val (16#80#), Character'Val (16#A6#))),
        Standard_String_Operations.To_Unbounded_String ("..."));

   --  ---- Scalar queries ----

   --  @relation FUNC-WIDTH-003
   function Display_Width
     (S    : Standard_String_Operations.Unbounded_String;
      Conf : Width_Configuration := Default_Linux) return Natural;

   --  @relation FUNC-WIDTH-004
   function Grapheme_Count
     (S    : Standard_String_Operations.Unbounded_String;
      Conf : Width_Configuration := Default_Linux) return Natural;

   --  @relation FUNC-WIDTH-010
   function Cluster_Length
     (S    : Standard_String_Operations.Unbounded_String;
      Conf : Width_Configuration := Default_Linux) return Natural
     renames Grapheme_Count;

   --  ---- Cluster-indexed operations ----

   --  @relation FUNC-WIDTH-011
   function Cluster_Element
     (S     : Standard_String_Operations.Unbounded_String;
      Index : Positive;
      Conf  : Width_Configuration := Default_Linux) return Grapheme
     with Pre => Index in 1 .. Cluster_Length (S, Conf);

   --  @relation FUNC-WIDTH-012
   function Cluster_Slice
     (S            : Standard_String_Operations.Unbounded_String;
      From_Cluster : Positive;
      To_Cluster   : Natural;
      Conf         : Width_Configuration := Default_Linux)
      return Standard_String_Operations.Unbounded_String
     with Pre =>
       (To_Cluster = 0 or else From_Cluster <= To_Cluster)
       and then To_Cluster <= Cluster_Length (S, Conf);

   --  @relation FUNC-WIDTH-013
   function Cluster_Head
     (S     : Standard_String_Operations.Unbounded_String;
      Count : Natural;
      Conf  : Width_Configuration := Default_Linux)
      return Standard_String_Operations.Unbounded_String;

   --  @relation FUNC-WIDTH-013
   function Cluster_Tail
     (S     : Standard_String_Operations.Unbounded_String;
      Count : Natural;
      Conf  : Width_Configuration := Default_Linux)
      return Standard_String_Operations.Unbounded_String;

   --  ---- Width-budget helpers ----

   --  @relation FUNC-WIDTH-014
   --  Allow_Split_Wide: reserved flag; v1 treats True identically to False (§2.3).
   function Head_By_Width
     (S                : Standard_String_Operations.Unbounded_String;
      Max_Cells        : Natural;
      Allow_Split_Wide : Boolean := False;
      Conf             : Width_Configuration := Default_Linux)
      return Width_Slice_Result;

   --  @relation FUNC-WIDTH-015
   function Truncate_With_Ellipsis
     (S         : Standard_String_Operations.Unbounded_String;
      Max_Cells : Natural;
      Ellipsis  : Standard_String_Operations.Unbounded_String := Default_Ellipsis;
      Conf      : Width_Configuration := Default_Linux)
      return Standard_String_Operations.Unbounded_String;

   --  @relation FUNC-WIDTH-016
   function Pad_To_Width
     (S            : Standard_String_Operations.Unbounded_String;
      Target_Cells : Natural;
      Pad          : Character := ' ';
      Side         : Pad_Side  := Right;
      Conf         : Width_Configuration := Default_Linux)
      return Standard_String_Operations.Unbounded_String
     with Pre => Display_Width (Standard_String_Operations.From_Character (Pad), Conf) = 1;

private

   type Grapheme_Cursor is record
      Is_Done    : Boolean  := True;
      First_Byte : Positive := 1;
      Last_Byte  : Positive := 1;
      Num_Points : Positive := 1;
      Disp_Width : Natural  := 0;
   end record;

   type Grapheme_View is record
      Source : Standard_String_Operations.Unbounded_String;
      Conf   : Umwi.Configuration;
   end record;

end Standard_Width;
