-------------------------------------------------------------------------------
--  String_Types.Width - display width and grapheme clusters (bodies)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Bodies of the Width wrappers: unwrap the String_Type operands, call
--  Wide_Wide_Width, and wrap the String_Type results and the Grapheme
--  records.

with String_Empty_Value.Convert;

package body String_Types.Width with SPARK_Mode => Off is

   package Conv renames String_Empty_Value.Convert;

   function To_Grapheme (G : Wide_Wide_Width.Grapheme) return Grapheme
   is ((Width       => G.Width,
        Code_Points => G.Code_Points,
        Slice       => Conv.From_Unbounded (G.Slice)));

   function First (V : Grapheme_View) return Grapheme_Cursor
   is ((Inner => Wide_Wide_Width.First (V.Inner)));

   function Has_Element (V : Grapheme_View; C : Grapheme_Cursor) return Boolean
   is (Wide_Wide_Width.Has_Element (V.Inner, C.Inner));

   function Next (V : Grapheme_View; C : Grapheme_Cursor) return Grapheme_Cursor
   is ((Inner => Wide_Wide_Width.Next (V.Inner, C.Inner)));

   function Element (V : Grapheme_View; C : Grapheme_Cursor) return Grapheme
   is (To_Grapheme (Wide_Wide_Width.Element (V.Inner, C.Inner)));

   function Graphemes
     (S    : String_Type;
      Conf : Width_Configuration := Default_Linux) return Grapheme_View
   is ((Inner => Wide_Wide_Width.Graphemes (Conv.To_Unbounded (S), Conf)));

   function Display_Width
     (S    : String_Type;
      Conf : Width_Configuration := Default_Linux) return Natural
   is (Wide_Wide_Width.Display_Width (Conv.To_Unbounded (S), Conf));

   function Grapheme_Count
     (S    : String_Type;
      Conf : Width_Configuration := Default_Linux) return Natural
   is (Wide_Wide_Width.Grapheme_Count (Conv.To_Unbounded (S), Conf));

   function Cluster_Length
     (S    : String_Type;
      Conf : Width_Configuration := Default_Linux) return Natural
   is (Wide_Wide_Width.Cluster_Length (Conv.To_Unbounded (S), Conf));

   function Cluster_Element
     (S     : String_Type;
      Index : Positive;
      Conf  : Width_Configuration := Default_Linux) return Grapheme
   is (To_Grapheme (Wide_Wide_Width.Cluster_Element (Conv.To_Unbounded (S), Index, Conf)));

   function Cluster_Slice
     (S            : String_Type;
      From_Cluster : Positive;
      To_Cluster   : Natural;
      Conf         : Width_Configuration := Default_Linux) return String_Type
   is (Conv.From_Unbounded
         (Wide_Wide_Width.Cluster_Slice (Conv.To_Unbounded (S), From_Cluster, To_Cluster, Conf)));

   function Cluster_Head
     (S     : String_Type;
      Count : Natural;
      Conf  : Width_Configuration := Default_Linux) return String_Type
   is (Conv.From_Unbounded (Wide_Wide_Width.Cluster_Head (Conv.To_Unbounded (S), Count, Conf)));

   function Cluster_Tail
     (S     : String_Type;
      Count : Natural;
      Conf  : Width_Configuration := Default_Linux) return String_Type
   is (Conv.From_Unbounded (Wide_Wide_Width.Cluster_Tail (Conv.To_Unbounded (S), Count, Conf)));

   function Head_By_Width
     (S                : String_Type;
      Max_Cells        : Natural;
      Allow_Split_Wide : Boolean := False;
      Conf             : Width_Configuration := Default_Linux)
      return Width_Slice_Result
   is
      R : constant Wide_Wide_Width.Width_Slice_Result :=
        Wide_Wide_Width.Head_By_Width (Conv.To_Unbounded (S), Max_Cells, Allow_Split_Wide, Conf);
   begin
      return (Result => Conv.From_Unbounded (R.Result), Width => R.Width, Truncated => R.Truncated);
   end Head_By_Width;

   function Truncate_With_Ellipsis
     (S         : String_Type;
      Max_Cells : Natural;
      Ellipsis  : String_Type := Default_Ellipsis;
      Conf      : Width_Configuration := Default_Linux) return String_Type
   is (Conv.From_Unbounded
         (Wide_Wide_Width.Truncate_With_Ellipsis
            (Conv.To_Unbounded (S), Max_Cells, Conv.To_Unbounded (Ellipsis), Conf)));

   function Pad_To_Width
     (S            : String_Type;
      Target_Cells : Natural;
      Pad          : Character_Type      := ' ';
      Side         : Pad_Side            := Right;
      Conf         : Width_Configuration := Default_Linux) return String_Type
   is (Conv.From_Unbounded
         (Wide_Wide_Width.Pad_To_Width (Conv.To_Unbounded (S), Target_Cells, Pad, Side, Conf)));

end String_Types.Width;
