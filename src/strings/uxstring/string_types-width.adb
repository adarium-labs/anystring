-------------------------------------------------------------------------------
--  String_Types.Width - Display-width and grapheme-cluster wrappers (bodies)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with UXString_Wrapper.Convert;

package body String_Types.Width
  with SPARK_Mode => Off
is

   package Conv renames UXString_Wrapper.Convert;

   function Wrap (G : UXString_Width.Grapheme) return Grapheme
   is ((Width => G.Width, Code_Points => G.Code_Points, Slice => Conv.From_UXString (G.Slice)));

   function First (V : Grapheme_View) return Grapheme_Cursor
   is ((Inner => UXString_Width.First (V.Inner)));

   function Has_Element (V : Grapheme_View; C : Grapheme_Cursor) return Boolean
   is (UXString_Width.Has_Element (V.Inner, C.Inner));

   function Next (V : Grapheme_View; C : Grapheme_Cursor) return Grapheme_Cursor
   is ((Inner => UXString_Width.Next (V.Inner, C.Inner)));

   function Element (V : Grapheme_View; C : Grapheme_Cursor) return Grapheme
   is (Wrap (UXString_Width.Element (V.Inner, C.Inner)));

   function Graphemes (S : String_Type; Conf : Width_Configuration := Default_Linux) return Grapheme_View
   is ((Inner => UXString_Width.Graphemes (Conv.To_UXString (S), Conf)));

   function Display_Width (S : String_Type; Conf : Width_Configuration := Default_Linux) return Natural
   is (UXString_Width.Display_Width (Conv.To_UXString (S), Conf));

   function Grapheme_Count (S : String_Type; Conf : Width_Configuration := Default_Linux) return Natural
   is (UXString_Width.Grapheme_Count (Conv.To_UXString (S), Conf));

   function Cluster_Element
     (S : String_Type; Index : Positive; Conf : Width_Configuration := Default_Linux) return Grapheme
   is (Wrap (UXString_Width.Cluster_Element (Conv.To_UXString (S), Index, Conf)));

   function Cluster_Slice
     (S : String_Type; From_Cluster : Positive; To_Cluster : Natural; Conf : Width_Configuration := Default_Linux)
      return String_Type
   is (Conv.From_UXString (UXString_Width.Cluster_Slice (Conv.To_UXString (S), From_Cluster, To_Cluster, Conf)));

   function Cluster_Head
     (S : String_Type; Count : Natural; Conf : Width_Configuration := Default_Linux) return String_Type
   is (Conv.From_UXString (UXString_Width.Cluster_Head (Conv.To_UXString (S), Count, Conf)));

   function Cluster_Tail
     (S : String_Type; Count : Natural; Conf : Width_Configuration := Default_Linux) return String_Type
   is (Conv.From_UXString (UXString_Width.Cluster_Tail (Conv.To_UXString (S), Count, Conf)));

   function Head_By_Width
     (S                : String_Type;
      Max_Cells        : Natural;
      Allow_Split_Wide : Boolean := False;
      Conf             : Width_Configuration := Default_Linux) return Width_Slice_Result
   is
      R : constant UXString_Width.Width_Slice_Result :=
        UXString_Width.Head_By_Width (Conv.To_UXString (S), Max_Cells, Allow_Split_Wide, Conf);
   begin
      return (Result => Conv.From_UXString (R.Result), Width => R.Width, Truncated => R.Truncated);
   end Head_By_Width;

   function Truncate_With_Ellipsis
     (S         : String_Type;
      Max_Cells : Natural;
      Ellipsis  : String_Type := Default_Ellipsis;
      Conf      : Width_Configuration := Default_Linux) return String_Type
   is (Conv.From_UXString
         (UXString_Width.Truncate_With_Ellipsis (Conv.To_UXString (S), Max_Cells, Conv.To_UXString (Ellipsis), Conf)));

   function Pad_To_Width
     (S            : String_Type;
      Target_Cells : Natural;
      Pad          : Character_Type := ' ';
      Side         : Pad_Side := Right;
      Conf         : Width_Configuration := Default_Linux) return String_Type
   is (Conv.From_UXString (UXString_Width.Pad_To_Width (Conv.To_UXString (S), Target_Cells, Pad, Side, Conf)));

end String_Types.Width;
