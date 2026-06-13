--  UXString_Width body — UMWI-backed display-width and grapheme-cluster implementation.
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

with Ada.Containers.Vectors;

package body UXString_Width
  with SPARK_Mode => Off
is

   Empty_String : constant UXStrings.UXString := UXStrings.Null_UXString;

   --  ---- Internal helpers ----

   function To_UTF8 (S : UXStrings.UXString) return Umwi.UTF8_String
   is (Umwi.UTF8_String (UXString_Operations.To_UTF_8 (S)));

   function From_Bytes (Bytes : String) return UXStrings.UXString
   is (UXString_UTF_8_Results.Get_Value_Or (UXString_UTF_8_Bridge.From_UTF_8_UXString (Bytes), Empty_String));

   --  ---- Cluster collection ----

   function Cluster_Equal (Left, Right : Umwi.UTF8_Grapheme_Cluster) return Boolean
   is (Left.First_Byte = Right.First_Byte
       and then Left.Last_Byte = Right.Last_Byte
       and then Left.Points = Right.Points
       and then Left.Width = Right.Width);

   package Cluster_Vectors is new
     Ada.Containers.Vectors (Index_Type => Positive, Element_Type => Umwi.UTF8_Grapheme_Cluster, "=" => Cluster_Equal);

   --  Walk UTF8 byte-by-byte via Umwi.Next_Cluster and append each result.
   function Collect (UTF8 : Umwi.UTF8_String; Conf : Umwi.Configuration) return Cluster_Vectors.Vector is
      V    : Cluster_Vectors.Vector;
      From : Positive := UTF8'First;
   begin
      while From <= UTF8'Last loop
         declare
            Cl : constant Umwi.UTF8_Grapheme_Cluster := Umwi.Next_Cluster (UTF8, From, Conf);
         begin
            V.Append (Cl);
            From := Cl.Last_Byte + 1;
         end;
      end loop;
      return V;
   end Collect;

   --  ---- Grapheme_View iterable primitives ----

   function First (V : Grapheme_View) return Grapheme_Cursor is
      UTF8 : constant Umwi.UTF8_String := To_UTF8 (V.Source);
   begin
      if UTF8'Length = 0 then
         return (Is_Done => True, First_Byte => 1, Last_Byte => 1, Num_Points => 1, Disp_Width => 0);
      end if;
      declare
         Cl : constant Umwi.UTF8_Grapheme_Cluster := Umwi.Next_Cluster (UTF8, UTF8'First, V.Conf);
      begin
         return
           (Is_Done    => False,
            First_Byte => Cl.First_Byte,
            Last_Byte  => Cl.Last_Byte,
            Num_Points => Cl.Points,
            Disp_Width => Cl.Width);
      end;
   end First;

   function Has_Element (V : Grapheme_View; C : Grapheme_Cursor) return Boolean is
      pragma Unreferenced (V);
   begin
      return not C.Is_Done;
   end Has_Element;

   function Next (V : Grapheme_View; C : Grapheme_Cursor) return Grapheme_Cursor is
      UTF8 : constant Umwi.UTF8_String := To_UTF8 (V.Source);
   begin
      if C.Last_Byte >= UTF8'Last then
         return (Is_Done => True, First_Byte => 1, Last_Byte => 1, Num_Points => 1, Disp_Width => 0);
      end if;
      declare
         Cl : constant Umwi.UTF8_Grapheme_Cluster := Umwi.Next_Cluster (UTF8, C.Last_Byte + 1, V.Conf);
      begin
         return
           (Is_Done    => False,
            First_Byte => Cl.First_Byte,
            Last_Byte  => Cl.Last_Byte,
            Num_Points => Cl.Points,
            Disp_Width => Cl.Width);
      end;
   end Next;

   function Element (V : Grapheme_View; C : Grapheme_Cursor) return Grapheme is
      UTF8  : constant Umwi.UTF8_String := To_UTF8 (V.Source);
      Bytes : constant String := String (UTF8 (C.First_Byte .. C.Last_Byte));
   begin
      return (Width => C.Disp_Width, Code_Points => C.Num_Points, Slice => From_Bytes (Bytes));
   end Element;

   --  ---- Graphemes factory ----

   --  @relation FUNC-WIDTH-005
   function Graphemes (S : UXStrings.UXString; Conf : Width_Configuration := Default_Linux) return Grapheme_View is
   begin
      return Grapheme_View'(Source => S, Conf => Conf);
   end Graphemes;

   --  ---- Scalar queries ----

   --  @relation FUNC-WIDTH-003
   function Display_Width (S : UXStrings.UXString; Conf : Width_Configuration := Default_Linux) return Natural is
      UTF8  : constant Umwi.UTF8_String := To_UTF8 (S);
      Total : Natural := 0;
   begin
      for Cl of Umwi.Clusters (UTF8, Conf) loop
         Total := Total + Cl.Width;
      end loop;
      return Total;
   end Display_Width;

   --  @relation FUNC-WIDTH-004
   function Grapheme_Count (S : UXStrings.UXString; Conf : Width_Configuration := Default_Linux) return Natural is
      UTF8  : constant Umwi.UTF8_String := To_UTF8 (S);
      Count : Natural := 0;
   begin
      for Cl of Umwi.Clusters (UTF8, Conf) loop
         Count := Count + 1;
      end loop;
      return Count;
   end Grapheme_Count;

   --  ---- Cluster-indexed operations ----

   --  @relation FUNC-WIDTH-011
   function Cluster_Element
     (S : UXStrings.UXString; Index : Positive; Conf : Width_Configuration := Default_Linux) return Grapheme
   is
      UTF8 : constant Umwi.UTF8_String := To_UTF8 (S);
      Clus : constant Cluster_Vectors.Vector := Collect (UTF8, Conf);
      Cl   : constant Umwi.UTF8_Grapheme_Cluster := Clus (Index);
   begin
      return
        (Width       => Cl.Width,
         Code_Points => Cl.Points,
         Slice       => From_Bytes (String (UTF8 (Cl.First_Byte .. Cl.Last_Byte))));
   end Cluster_Element;

   --  @relation FUNC-WIDTH-012
   function Cluster_Slice
     (S            : UXStrings.UXString;
      From_Cluster : Positive;
      To_Cluster   : Natural;
      Conf         : Width_Configuration := Default_Linux) return UXStrings.UXString is
   begin
      if To_Cluster = 0 then
         return Empty_String;
      end if;
      declare
         UTF8     : constant Umwi.UTF8_String := To_UTF8 (S);
         Clus     : constant Cluster_Vectors.Vector := Collect (UTF8, Conf);
         First_Cl : constant Umwi.UTF8_Grapheme_Cluster := Clus (From_Cluster);
         Last_Cl  : constant Umwi.UTF8_Grapheme_Cluster := Clus (To_Cluster);
      begin
         return From_Bytes (String (UTF8 (First_Cl.First_Byte .. Last_Cl.Last_Byte)));
      end;
   end Cluster_Slice;

   --  @relation FUNC-WIDTH-013
   function Cluster_Head
     (S : UXStrings.UXString; Count : Natural; Conf : Width_Configuration := Default_Linux) return UXStrings.UXString is
   begin
      if Count = 0 then
         return Empty_String;
      end if;
      declare
         UTF8   : constant Umwi.UTF8_String := To_UTF8 (S);
         Clus   : constant Cluster_Vectors.Vector := Collect (UTF8, Conf);
         Actual : constant Natural := Natural'Min (Count, Natural (Clus.Length));
      begin
         if Actual = 0 then
            return Empty_String;
         end if;
         declare
            Last_Cl : constant Umwi.UTF8_Grapheme_Cluster := Clus (Actual);
         begin
            return From_Bytes (String (UTF8 (UTF8'First .. Last_Cl.Last_Byte)));
         end;
      end;
   end Cluster_Head;

   --  @relation FUNC-WIDTH-013
   function Cluster_Tail
     (S : UXStrings.UXString; Count : Natural; Conf : Width_Configuration := Default_Linux) return UXStrings.UXString is
   begin
      if Count = 0 then
         return Empty_String;
      end if;
      declare
         UTF8   : constant Umwi.UTF8_String := To_UTF8 (S);
         Clus   : constant Cluster_Vectors.Vector := Collect (UTF8, Conf);
         Total  : constant Natural := Natural (Clus.Length);
         Actual : constant Natural := Natural'Min (Count, Total);
      begin
         if Total = 0 then
            return Empty_String;
         end if;
         declare
            Start_Idx : constant Positive := Total - Actual + 1;
            First_Cl  : constant Umwi.UTF8_Grapheme_Cluster := Clus (Start_Idx);
         begin
            return From_Bytes (String (UTF8 (First_Cl.First_Byte .. UTF8'Last)));
         end;
      end;
   end Cluster_Tail;

   --  ---- Width-budget helpers ----

   --  @relation FUNC-WIDTH-014
   function Head_By_Width
     (S                : UXStrings.UXString;
      Max_Cells        : Natural;
      Allow_Split_Wide : Boolean := False;
      Conf             : Width_Configuration := Default_Linux) return Width_Slice_Result
   is
      pragma Unreferenced (Allow_Split_Wide);
      UTF8      : constant Umwi.UTF8_String := To_UTF8 (S);
      Acc_Width : Natural := 0;
      Last_Byte : Natural := 0;
      Truncated : Boolean := False;
   begin
      if UTF8'Length = 0 then
         return (Result => Empty_String, Width => 0, Truncated => False);
      end if;
      if Max_Cells = 0 then
         return (Result => Empty_String, Width => 0, Truncated => True);
      end if;
      for Cl of Umwi.Clusters (UTF8, Conf) loop
         if Acc_Width + Cl.Width > Max_Cells then
            Truncated := True;
            exit;
         end if;
         Acc_Width := Acc_Width + Cl.Width;
         Last_Byte := Cl.Last_Byte;
      end loop;
      if Last_Byte = 0 then
         return (Result => Empty_String, Width => 0, Truncated => Truncated);
      end if;
      return
        (Result => From_Bytes (String (UTF8 (UTF8'First .. Last_Byte))), Width => Acc_Width, Truncated => Truncated);
   end Head_By_Width;

   --  @relation FUNC-WIDTH-015
   function Truncate_With_Ellipsis
     (S         : UXStrings.UXString;
      Max_Cells : Natural;
      Ellipsis  : UXStrings.UXString := Default_Ellipsis;
      Conf      : Width_Configuration := Default_Linux) return UXStrings.UXString
   is
      S_Width   : constant Natural := Display_Width (S, Conf);
      Ell_Width : constant Natural := Display_Width (Ellipsis, Conf);
   begin
      if S_Width <= Max_Cells then
         return S;
      end if;
      if Ell_Width > Max_Cells then
         return Empty_String;
      end if;
      if Ell_Width = Max_Cells then
         return Ellipsis;
      end if;
      declare
         Budget : constant Natural := Max_Cells - Ell_Width;
         Sliced : constant Width_Slice_Result := Head_By_Width (S, Budget, False, Conf);
      begin
         return UXString_Operations.Concat_Strings (Sliced.Result, Ellipsis);
      end;
   end Truncate_With_Ellipsis;

   --  @relation FUNC-WIDTH-016
   function Pad_To_Width
     (S            : UXStrings.UXString;
      Target_Cells : Natural;
      Pad          : UXStrings.Unicode_Character := ' ';
      Side         : Pad_Side := Right;
      Conf         : Width_Configuration := Default_Linux) return UXStrings.UXString
   is
      Current : constant Natural := Display_Width (S, Conf);
      Needed  : Natural;
   begin
      if Current >= Target_Cells then
         return S;
      end if;
      Needed := Target_Cells - Current;
      case Side is
         when Left  =>
            declare
               P : UXStrings.UXString := Empty_String;
            begin
               for I in 1 .. Needed loop
                  P := UXString_Operations.Concat_String_Character (P, Pad);
               end loop;
               return UXString_Operations.Concat_Strings (P, S);
            end;

         when Right =>
            declare
               P : UXStrings.UXString := Empty_String;
            begin
               for I in 1 .. Needed loop
                  P := UXString_Operations.Concat_String_Character (P, Pad);
               end loop;
               return UXString_Operations.Concat_Strings (S, P);
            end;

         when Both  =>
            --  Right-biased: left gets floor(Needed/2), right gets ceil(Needed/2).
            declare
               Left_Pad  : constant Natural := Needed / 2;
               Right_Pad : constant Natural := Needed - Left_Pad;
               L         : UXStrings.UXString := Empty_String;
               R         : UXStrings.UXString := Empty_String;
            begin
               for I in 1 .. Left_Pad loop
                  L := UXString_Operations.Concat_String_Character (L, Pad);
               end loop;
               for I in 1 .. Right_Pad loop
                  R := UXString_Operations.Concat_String_Character (R, Pad);
               end loop;
               return UXString_Operations.Concat_Strings (UXString_Operations.Concat_Strings (L, S), R);
            end;
      end case;
   end Pad_To_Width;

end UXString_Width;
