--  Wide_Width body -- UMWI-backed display-width and grapheme-cluster operations.
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

package body Wide_Width with SPARK_Mode => Off is

   use Wide_String_Operations;

   Empty_Str : constant Unbounded_Wide_String := Null_Unbounded_Wide_String;

   function To_UTF8 (S : Unbounded_Wide_String) return Umwi.UTF8_String is
   begin
      return Umwi.UTF8_String (Wide_String_Operations.To_UTF_8 (S));
   end To_UTF8;

   function From_UTF8_Bytes
     (UTF8  : Umwi.UTF8_String;
      First : Positive;
      Last  : Positive) return Unbounded_Wide_String
   is
   begin
      return Wide_UTF_8_Results.Get_Value_Or
        (Wide_UTF_8_Bridge.From_UTF_8_Wide (String (UTF8 (First .. Last))),
         Empty_Str);
   end From_UTF8_Bytes;

   function Repeat_Char (C : Wide_Character; N : Natural) return Unbounded_Wide_String is
      Result : Unbounded_Wide_String := Null_Unbounded_Wide_String;
   begin
      for I in 1 .. N loop
         Result := Concat_String_Character (Result, C);
      end loop;
      return Result;
   end Repeat_Char;

   --  ---- Grapheme_View iterable primitives ----

   --  @relation FUNC-WIDTH-005
   function First (V : Grapheme_View) return Grapheme_Cursor is
      UTF8 : constant String := Wide_String_Operations.To_UTF_8 (V.Source);
   begin
      if UTF8'Length = 0 then
         return (Is_Done => True, First_Byte => 1, Last_Byte => 1, Num_Points => 1, Disp_Width => 0);
      end if;
      declare
         C : constant Umwi.UTF8_Grapheme_Cluster :=
           Umwi.Next_Cluster (Umwi.UTF8_String (UTF8), UTF8'First, V.Conf);
      begin
         return
           (Is_Done    => False,
            First_Byte => C.First_Byte,
            Last_Byte  => C.Last_Byte,
            Num_Points => C.Points,
            Disp_Width => C.Width);
      end;
   end First;

   function Has_Element (V : Grapheme_View; C : Grapheme_Cursor) return Boolean is
      pragma Unreferenced (V);
   begin
      return not C.Is_Done;
   end Has_Element;

   function Next (V : Grapheme_View; C : Grapheme_Cursor) return Grapheme_Cursor is
      UTF8     : constant String   := Wide_String_Operations.To_UTF_8 (V.Source);
      Next_Pos : constant Positive := C.Last_Byte + 1;
   begin
      if Next_Pos > UTF8'Last then
         return (Is_Done => True, First_Byte => 1, Last_Byte => 1, Num_Points => 1, Disp_Width => 0);
      end if;
      declare
         NC : constant Umwi.UTF8_Grapheme_Cluster :=
           Umwi.Next_Cluster (Umwi.UTF8_String (UTF8), Next_Pos, V.Conf);
      begin
         return
           (Is_Done    => False,
            First_Byte => NC.First_Byte,
            Last_Byte  => NC.Last_Byte,
            Num_Points => NC.Points,
            Disp_Width => NC.Width);
      end;
   end Next;

   function Element (V : Grapheme_View; C : Grapheme_Cursor) return Grapheme is
      UTF8 : constant Umwi.UTF8_String := To_UTF8 (V.Source);
   begin
      return
        (Width       => C.Disp_Width,
         Code_Points => C.Num_Points,
         Slice       => From_UTF8_Bytes (UTF8, C.First_Byte, C.Last_Byte));
   end Element;

   --  ---- Graphemes iterator factory ----

   --  @relation FUNC-WIDTH-005
   function Graphemes
     (S    : Unbounded_Wide_String;
      Conf : Width_Configuration := Default_Linux) return Grapheme_View
   is
   begin
      return Grapheme_View'(Source => S, Conf => Conf);
   end Graphemes;

   --  ---- Scalar queries ----

   --  @relation FUNC-WIDTH-003
   function Display_Width
     (S    : Unbounded_Wide_String;
      Conf : Width_Configuration := Default_Linux) return Natural
   is
      UTF8  : constant Umwi.UTF8_String := To_UTF8 (S);
      Total : Natural := 0;
   begin
      for C of Umwi.Clusters (UTF8, Conf) loop
         Total := Total + C.Width;
      end loop;
      return Total;
   end Display_Width;

   --  @relation FUNC-WIDTH-004
   function Grapheme_Count
     (S    : Unbounded_Wide_String;
      Conf : Width_Configuration := Default_Linux) return Natural
   is
      UTF8  : constant Umwi.UTF8_String := To_UTF8 (S);
      Count : Natural := 0;
   begin
      for C of Umwi.Clusters (UTF8, Conf) loop
         Count := Count + C.Points / C.Points;
      end loop;
      return Count;
   end Grapheme_Count;

   --  ---- Cluster-indexed operations ----

   --  @relation FUNC-WIDTH-011
   function Cluster_Element
     (S     : Unbounded_Wide_String;
      Index : Positive;
      Conf  : Width_Configuration := Default_Linux) return Grapheme
   is
      UTF8 : constant Umwi.UTF8_String := To_UTF8 (S);
      I    : Positive := 1;
   begin
      for C of Umwi.Clusters (UTF8, Conf) loop
         if I = Index then
            return
              (Width       => C.Width,
               Code_Points => C.Points,
               Slice       => From_UTF8_Bytes (UTF8, C.First_Byte, C.Last_Byte));
         end if;
         I := I + 1;
      end loop;
      raise Constraint_Error with "Cluster_Element: index exceeds cluster count";
   end Cluster_Element;

   --  @relation FUNC-WIDTH-012
   function Cluster_Slice
     (S            : Unbounded_Wide_String;
      From_Cluster : Positive;
      To_Cluster   : Natural;
      Conf         : Width_Configuration := Default_Linux)
      return Unbounded_Wide_String
   is
      UTF8   : constant Umwi.UTF8_String := To_UTF8 (S);
      Result : Unbounded_Wide_String     := Empty_Str;
      I      : Positive                  := 1;
   begin
      if To_Cluster = 0 then
         return Empty_Str;
      end if;
      for C of Umwi.Clusters (UTF8, Conf) loop
         if I in From_Cluster .. To_Cluster then
            Result := Concat_Strings (Result, From_UTF8_Bytes (UTF8, C.First_Byte, C.Last_Byte));
         end if;
         exit when I = To_Cluster;
         I := I + 1;
      end loop;
      return Result;
   end Cluster_Slice;

   --  @relation FUNC-WIDTH-013
   function Cluster_Head
     (S     : Unbounded_Wide_String;
      Count : Natural;
      Conf  : Width_Configuration := Default_Linux)
      return Unbounded_Wide_String
   is
   begin
      if Count = 0 then
         return Empty_Str;
      end if;
      if Count >= Cluster_Length (S, Conf) then
         return S;
      end if;
      return Cluster_Slice (S, 1, Count, Conf);
   end Cluster_Head;

   --  @relation FUNC-WIDTH-013
   function Cluster_Tail
     (S     : Unbounded_Wide_String;
      Count : Natural;
      Conf  : Width_Configuration := Default_Linux)
      return Unbounded_Wide_String
   is
      Total : constant Natural := Cluster_Length (S, Conf);
   begin
      if Count = 0 then
         return Empty_Str;
      end if;
      if Count >= Total then
         return S;
      end if;
      return Cluster_Slice (S, Total - Count + 1, Total, Conf);
   end Cluster_Tail;

   --  ---- Width-budget helpers ----

   --  @relation FUNC-WIDTH-014
   function Head_By_Width
     (S                : Unbounded_Wide_String;
      Max_Cells        : Natural;
      Allow_Split_Wide : Boolean             := False;
      Conf             : Width_Configuration := Default_Linux)
      return Width_Slice_Result
   is
      pragma Unreferenced (Allow_Split_Wide);
      UTF8     : constant Umwi.UTF8_String := To_UTF8 (S);
      Acc_W    : Natural           := 0;
      Result   : Unbounded_Wide_String := Empty_Str;
      Has_More : Boolean           := False;
   begin
      for C of Umwi.Clusters (UTF8, Conf) loop
         if Acc_W + C.Width <= Max_Cells then
            Result := Concat_Strings (Result, From_UTF8_Bytes (UTF8, C.First_Byte, C.Last_Byte));
            Acc_W  := Acc_W + C.Width;
         else
            Has_More := True;
         end if;
      end loop;
      return (Result => Result, Width => Acc_W, Truncated => Has_More);
   end Head_By_Width;

   --  @relation FUNC-WIDTH-015
   function Truncate_With_Ellipsis
     (S         : Unbounded_Wide_String;
      Max_Cells : Natural;
      Ellipsis  : Unbounded_Wide_String    := Default_Ellipsis;
      Conf      : Width_Configuration := Default_Linux)
      return Unbounded_Wide_String
   is
      S_Width   : constant Natural := Display_Width (S, Conf);
      Ell_Width : constant Natural := Display_Width (Ellipsis, Conf);
   begin
      if S_Width <= Max_Cells then
         return S;
      end if;
      if Max_Cells < Ell_Width then
         return Empty_Str;
      end if;
      return Concat_Strings
               (Head_By_Width (S, Max_Cells - Ell_Width, False, Conf).Result, Ellipsis);
   end Truncate_With_Ellipsis;

   --  @relation FUNC-WIDTH-016
   function Pad_To_Width
     (S            : Unbounded_Wide_String;
      Target_Cells : Natural;
      Pad          : Wide_Character      := ' ';
      Side         : Pad_Side            := Right;
      Conf         : Width_Configuration := Default_Linux)
      return Unbounded_Wide_String
   is
      Current : constant Natural := Display_Width (S, Conf);
   begin
      if Current >= Target_Cells then
         return S;
      end if;
      declare
         Needed : constant Natural := Target_Cells - Current;
      begin
         case Side is
            when Left =>
               return Concat_Strings (Repeat_Char (Pad, Needed), S);
            when Right =>
               return Concat_Strings (S, Repeat_Char (Pad, Needed));
            when Both =>
               declare
                  L_N : constant Natural := Needed / 2;
                  R_N : constant Natural := (Needed + 1) / 2;
               begin
                  return Concat_Strings
                           (Concat_Strings (Repeat_Char (Pad, L_N), S),
                            Repeat_Char (Pad, R_N));
               end;
         end case;
      end;
   end Pad_To_Width;

end Wide_Width;
