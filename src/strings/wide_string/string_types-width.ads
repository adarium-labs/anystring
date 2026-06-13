--  String_Types.Width — Display-width and grapheme-cluster re-exports (wide_string backend)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
--
--  @summary
--  Child package of String_Types exposing display-width and grapheme-cluster operations.
--
--  @description
--  Pure renames of the per-backend Wide_Width implementation package,
--  so that consumers can opt in to the width API with
--  "with String_Types.Width;" without forcing Umwi into the dependency
--  closure of every "with String_Types;" (NFR-WIDTH-001).
--
--  Public surface is byte-identical across all five backends (FUNC-WIDTH-002);
--  only the with clause and rename targets differ.
--
--  This package intentionally has no SPARK_Mode pragma: the renames carry
--  through whatever the impl package declares (SPARK_Mode Off), and the
--  facade itself adds nothing provable (§9 of the tech-spec).
--
--  @relation FUNC-WIDTH-001, FUNC-WIDTH-002, FUNC-WIDTH-003, FUNC-WIDTH-004,
--            FUNC-WIDTH-005, FUNC-WIDTH-006, FUNC-WIDTH-010, FUNC-WIDTH-011,
--            FUNC-WIDTH-012, FUNC-WIDTH-013, FUNC-WIDTH-014, FUNC-WIDTH-015,
--            FUNC-WIDTH-016, NFR-WIDTH-001, NFR-WIDTH-003, NFR-WIDTH-004,
--            NFR-WIDTH-005

with Wide_Width;

package String_Types.Width is

   --  ---- Configuration (FUNC-WIDTH-006, NFR-WIDTH-003) ----

   subtype Width_Configuration is Wide_Width.Width_Configuration;
   subtype Width_Context       is Wide_Width.Width_Context;

   Narrow : constant Width_Context := Wide_Width.Narrow;
   Wide   : constant Width_Context := Wide_Width.Wide;

   Default_Linux  : constant Width_Configuration := Wide_Width.Default_Linux;
   Default_Strict : constant Width_Configuration := Wide_Width.Default_Strict;

   --  ---- Grapheme cluster record and iterable view (FUNC-WIDTH-005) ----

   subtype Grapheme      is Wide_Width.Grapheme;
   subtype Grapheme_View is Wide_Width.Grapheme_View;

   --  @relation FUNC-WIDTH-005
   function Graphemes
     (S    : String_Type;
      Conf : Width_Configuration := Default_Linux) return Grapheme_View
     renames Wide_Width.Graphemes;

   --  ---- Width_Slice_Result (FUNC-WIDTH-014) ----

   subtype Width_Slice_Result is Wide_Width.Width_Slice_Result;

   --  ---- Pad_Side (FUNC-WIDTH-016) ----

   subtype Pad_Side is Wide_Width.Pad_Side;
   Left  : constant Pad_Side := Wide_Width.Left;
   Right : constant Pad_Side := Wide_Width.Right;
   Both  : constant Pad_Side := Wide_Width.Both;

   --  ---- Default_Ellipsis (FUNC-WIDTH-015) ----

   Default_Ellipsis : constant String_Type := Wide_Width.Default_Ellipsis;

   --  ---- Scalar queries ----

   --  @relation FUNC-WIDTH-003
   function Display_Width
     (S    : String_Type;
      Conf : Width_Configuration := Default_Linux) return Natural
     renames Wide_Width.Display_Width;

   --  @relation FUNC-WIDTH-004
   function Grapheme_Count
     (S    : String_Type;
      Conf : Width_Configuration := Default_Linux) return Natural
     renames Wide_Width.Grapheme_Count;

   --  @relation FUNC-WIDTH-010
   function Cluster_Length
     (S    : String_Type;
      Conf : Width_Configuration := Default_Linux) return Natural
     renames Wide_Width.Cluster_Length;

   --  ---- Cluster-indexed operations ----

   --  @relation FUNC-WIDTH-011
   function Cluster_Element
     (S     : String_Type;
      Index : Positive;
      Conf  : Width_Configuration := Default_Linux) return Grapheme
     renames Wide_Width.Cluster_Element;

   --  @relation FUNC-WIDTH-012
   function Cluster_Slice
     (S            : String_Type;
      From_Cluster : Positive;
      To_Cluster   : Natural;
      Conf         : Width_Configuration := Default_Linux) return String_Type
     renames Wide_Width.Cluster_Slice;

   --  @relation FUNC-WIDTH-013
   function Cluster_Head
     (S     : String_Type;
      Count : Natural;
      Conf  : Width_Configuration := Default_Linux) return String_Type
     renames Wide_Width.Cluster_Head;

   --  @relation FUNC-WIDTH-013
   function Cluster_Tail
     (S     : String_Type;
      Count : Natural;
      Conf  : Width_Configuration := Default_Linux) return String_Type
     renames Wide_Width.Cluster_Tail;

   --  ---- Width-budget helpers ----

   --  @relation FUNC-WIDTH-014
   function Head_By_Width
     (S                : String_Type;
      Max_Cells        : Natural;
      Allow_Split_Wide : Boolean := False;
      Conf             : Width_Configuration := Default_Linux)
      return Width_Slice_Result
     renames Wide_Width.Head_By_Width;

   --  @relation FUNC-WIDTH-015
   function Truncate_With_Ellipsis
     (S         : String_Type;
      Max_Cells : Natural;
      Ellipsis  : String_Type := Default_Ellipsis;
      Conf      : Width_Configuration := Default_Linux) return String_Type
     renames Wide_Width.Truncate_With_Ellipsis;

   --  @relation FUNC-WIDTH-016
   function Pad_To_Width
     (S            : String_Type;
      Target_Cells : Natural;
      Pad          : Character_Type     := ' ';
      Side         : Pad_Side           := Right;
      Conf         : Width_Configuration := Default_Linux) return String_Type
     renames Wide_Width.Pad_To_Width;

end String_Types.Width;
