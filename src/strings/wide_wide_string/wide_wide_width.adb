--  Wide_Wide_Width body — UMWI-backed display-width and grapheme-cluster operations
--  (wide_wide_string backend)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

package body Wide_Wide_Width with SPARK_Mode => Off is

   use Wide_Wide_String_Operations;

   Empty_String : constant Unbounded_Wide_Wide_String := Null_Unbounded_Wide_Wide_String;

   --  Encode S as a UTF-8 byte sequence for Umwi cluster functions.
   function To_UTF8 (S : Unbounded_Wide_Wide_String) return Umwi.UTF8_String is
   begin
      return Umwi.UTF8_String (To_UTF_8 (S));
   end To_UTF8;

   --  Reconstruct an Unbounded_Wide_Wide_String from a UTF-8 byte sub-range.
   function From_UTF8_Bytes
     (Bytes      : Umwi.UTF8_String;
      First_Byte : Positive;
      Last_Byte  : Positive) return Unbounded_Wide_Wide_String
   is
   begin
      return Wide_Wide_UTF_8_Results.Get_Value_Or
               (Wide_Wide_UTF_8_Bridge.From_UTF_8_Wide_Wide
                  (String (Bytes (First_Byte .. Last_Byte))),
                Empty_String);
   end From_UTF8_Bytes;

   --  ---- Grapheme_View iterable primitives ----

   function First (V : Grapheme_View) return Grapheme_Cursor is
      Bytes : constant Umwi.UTF8_String := To_UTF8 (V.Source);
   begin
      if Bytes'Length = 0 then
         return (Is_Done => True, First_Byte => 1, Last_Byte => 1, Num_Points => 1, Disp_Width => 0);
      end if;
      declare
         Cl : constant Umwi.UTF8_Grapheme_Cluster :=
                Umwi.Next_Cluster (Bytes, Bytes'First, V.Conf);
      begin
         return (Is_Done    => False,
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
      Bytes : constant Umwi.UTF8_String := To_UTF8 (V.Source);
   begin
      if C.Last_Byte >= Bytes'Last then
         return (Is_Done => True, First_Byte => 1, Last_Byte => 1, Num_Points => 1, Disp_Width => 0);
      end if;
      declare
         Next_From : constant Positive                  := C.Last_Byte + 1;
         Cl        : constant Umwi.UTF8_Grapheme_Cluster :=
                       Umwi.Next_Cluster (Bytes, Next_From, V.Conf);
      begin
         return (Is_Done    => False,
                 First_Byte => Cl.First_Byte,
                 Last_Byte  => Cl.Last_Byte,
                 Num_Points => Cl.Points,
                 Disp_Width => Cl.Width);
      end;
   end Next;

   function Element (V : Grapheme_View; C : Grapheme_Cursor) return Grapheme is
      Bytes : constant Umwi.UTF8_String := To_UTF8 (V.Source);
   begin
      return Grapheme'
               (Width       => C.Disp_Width,
                Code_Points => C.Num_Points,
                Slice       => From_UTF8_Bytes (Bytes, C.First_Byte, C.Last_Byte));
   end Element;

   --  ---- Graphemes iterator factory ----

   --  @relation FUNC-WIDTH-005
   function Graphemes
     (S    : Unbounded_Wide_Wide_String;
      Conf : Width_Configuration := Default_Linux) return Grapheme_View
   is
   begin
      return Grapheme_View'(Source => S, Conf => Conf);
   end Graphemes;

   --  ---- Scalar queries ----

   --  @relation FUNC-WIDTH-003
   function Display_Width
     (S    : Unbounded_Wide_Wide_String;
      Conf : Width_Configuration := Default_Linux) return Natural
   is
      Bytes : constant Umwi.UTF8_String := To_UTF8 (S);
      Total : Natural  := 0;
      From  : Positive := Bytes'First;
   begin
      while From <= Bytes'Last loop
         declare
            Cl : constant Umwi.UTF8_Grapheme_Cluster := Umwi.Next_Cluster (Bytes, From, Conf);
         begin
            Total := Total + Cl.Width;
            From  := Cl.Last_Byte + 1;
         end;
      end loop;
      return Total;
   end Display_Width;

   --  @relation FUNC-WIDTH-004
   function Grapheme_Count
     (S    : Unbounded_Wide_Wide_String;
      Conf : Width_Configuration := Default_Linux) return Natural
   is
      Bytes : constant Umwi.UTF8_String := To_UTF8 (S);
      Count : Natural  := 0;
      From  : Positive := Bytes'First;
   begin
      while From <= Bytes'Last loop
         declare
            Cl : constant Umwi.UTF8_Grapheme_Cluster := Umwi.Next_Cluster (Bytes, From, Conf);
         begin
            Count := Count + 1;
            From  := Cl.Last_Byte + 1;
         end;
      end loop;
      return Count;
   end Grapheme_Count;

   --  ---- Cluster-indexed operations ----

   --  @relation FUNC-WIDTH-011
   function Cluster_Element
     (S     : Unbounded_Wide_Wide_String;
      Index : Positive;
      Conf  : Width_Configuration := Default_Linux) return Grapheme
   is
      Bytes : constant Umwi.UTF8_String := To_UTF8 (S);
      I     : Natural  := 0;
      From  : Positive := Bytes'First;
   begin
      while From <= Bytes'Last loop
         declare
            Cl : constant Umwi.UTF8_Grapheme_Cluster := Umwi.Next_Cluster (Bytes, From, Conf);
         begin
            I := I + 1;
            if I = Index then
               return Grapheme'
                        (Width       => Cl.Width,
                         Code_Points => Cl.Points,
                         Slice       => From_UTF8_Bytes (Bytes, Cl.First_Byte, Cl.Last_Byte));
            end if;
            From := Cl.Last_Byte + 1;
         end;
      end loop;
      --  Unreachable when Pre (Index in 1 .. Cluster_Length (S, Conf)) holds.
      return Grapheme'(Width => 0, Code_Points => 1, Slice => Empty_String);
   end Cluster_Element;

   --  @relation FUNC-WIDTH-012
   function Cluster_Slice
     (S            : Unbounded_Wide_Wide_String;
      From_Cluster : Positive;
      To_Cluster   : Natural;
      Conf         : Width_Configuration := Default_Linux)
      return Unbounded_Wide_Wide_String
   is
   begin
      if To_Cluster = 0 then
         return Empty_String;
      end if;
      declare
         Bytes     : constant Umwi.UTF8_String := To_UTF8 (S);
         I         : Natural  := 0;
         From_Byte : Natural  := 0;
         Last_Byte : Natural  := 0;
         From      : Positive := Bytes'First;
      begin
         while From <= Bytes'Last and then I < To_Cluster loop
            declare
               Cl : constant Umwi.UTF8_Grapheme_Cluster := Umwi.Next_Cluster (Bytes, From, Conf);
            begin
               I := I + 1;
               if I = From_Cluster then
                  From_Byte := Cl.First_Byte;
               end if;
               if I >= From_Cluster then
                  Last_Byte := Cl.Last_Byte;
               end if;
               From := Cl.Last_Byte + 1;
            end;
         end loop;
         if From_Byte = 0 then
            return Empty_String;
         end if;
         return From_UTF8_Bytes (Bytes, From_Byte, Last_Byte);
      end;
   end Cluster_Slice;

   --  @relation FUNC-WIDTH-013
   function Cluster_Head
     (S     : Unbounded_Wide_Wide_String;
      Count : Natural;
      Conf  : Width_Configuration := Default_Linux)
      return Unbounded_Wide_Wide_String
   is
   begin
      if Count = 0 then
         return Empty_String;
      end if;
      declare
         Bytes     : constant Umwi.UTF8_String := To_UTF8 (S);
         I         : Natural  := 0;
         Last_Byte : Natural  := 0;
         From      : Positive := Bytes'First;
      begin
         while From <= Bytes'Last and then I < Count loop
            declare
               Cl : constant Umwi.UTF8_Grapheme_Cluster := Umwi.Next_Cluster (Bytes, From, Conf);
            begin
               I         := I + 1;
               Last_Byte := Cl.Last_Byte;
               From      := Cl.Last_Byte + 1;
            end;
         end loop;
         if Last_Byte = 0 then
            return Empty_String;
         end if;
         return From_UTF8_Bytes (Bytes, Bytes'First, Last_Byte);
      end;
   end Cluster_Head;

   --  @relation FUNC-WIDTH-013
   function Cluster_Tail
     (S     : Unbounded_Wide_Wide_String;
      Count : Natural;
      Conf  : Width_Configuration := Default_Linux)
      return Unbounded_Wide_Wide_String
   is
   begin
      if Count = 0 then
         return Empty_String;
      end if;
      declare
         Total : constant Natural := Grapheme_Count (S, Conf);
      begin
         if Total = 0 then
            return Empty_String;
         end if;
         if Count >= Total then
            return S;
         end if;
         declare
            Bytes     : constant Umwi.UTF8_String := To_UTF8 (S);
            Skip      : constant Natural           := Total - Count;
            I         : Natural                    := 0;
            From_Byte : Natural                    := 0;
            From      : Positive                   := Bytes'First;
         begin
            while From <= Bytes'Last loop
               declare
                  Cl : constant Umwi.UTF8_Grapheme_Cluster :=
                         Umwi.Next_Cluster (Bytes, From, Conf);
               begin
                  I := I + 1;
                  if I = Skip + 1 then
                     From_Byte := Cl.First_Byte;
                  end if;
                  From := Cl.Last_Byte + 1;
               end;
            end loop;
            if From_Byte = 0 then
               return Empty_String;
            end if;
            return From_UTF8_Bytes (Bytes, From_Byte, Bytes'Last);
         end;
      end;
   end Cluster_Tail;

   --  ---- Width-budget helpers ----

   --  @relation FUNC-WIDTH-014
   function Head_By_Width
     (S                : Unbounded_Wide_Wide_String;
      Max_Cells        : Natural;
      Allow_Split_Wide : Boolean             := False;
      Conf             : Width_Configuration := Default_Linux)
      return Width_Slice_Result
   is
      pragma Unreferenced (Allow_Split_Wide);
      Bytes     : constant Umwi.UTF8_String := To_UTF8 (S);
      Accum     : Natural  := 0;
      Last_Byte : Natural  := 0;
      From      : Positive := Bytes'First;
      Truncated : Boolean  := False;
   begin
      while From <= Bytes'Last loop
         declare
            Cl : constant Umwi.UTF8_Grapheme_Cluster := Umwi.Next_Cluster (Bytes, From, Conf);
         begin
            if Accum + Cl.Width > Max_Cells then
               Truncated := True;
               exit;
            end if;
            Accum     := Accum + Cl.Width;
            Last_Byte := Cl.Last_Byte;
            From      := Cl.Last_Byte + 1;
         end;
      end loop;
      if Last_Byte = 0 then
         return Width_Slice_Result'(Result => Empty_String, Width => 0, Truncated => Truncated);
      end if;
      return Width_Slice_Result'
               (Result    => From_UTF8_Bytes (Bytes, Bytes'First, Last_Byte),
                Width     => Accum,
                Truncated => Truncated);
   end Head_By_Width;

   --  @relation FUNC-WIDTH-015
   function Truncate_With_Ellipsis
     (S         : Unbounded_Wide_Wide_String;
      Max_Cells : Natural;
      Ellipsis  : Unbounded_Wide_Wide_String := Default_Ellipsis;
      Conf      : Width_Configuration        := Default_Linux)
      return Unbounded_Wide_Wide_String
   is
      S_Width : constant Natural := Display_Width (S, Conf);
   begin
      if S_Width <= Max_Cells then
         return S;
      end if;
      declare
         E_Width : constant Natural := Display_Width (Ellipsis, Conf);
      begin
         if Max_Cells < E_Width then
            return Empty_String;
         end if;
         declare
            Budget : constant Natural            := Max_Cells - E_Width;
            Head   : constant Width_Slice_Result := Head_By_Width (S, Budget, False, Conf);
         begin
            return Concat_Strings (Head.Result, Ellipsis);
         end;
      end;
   end Truncate_With_Ellipsis;

   --  @relation FUNC-WIDTH-016
   function Pad_To_Width
     (S            : Unbounded_Wide_Wide_String;
      Target_Cells : Natural;
      Pad          : Wide_Wide_Character  := ' ';
      Side         : Pad_Side             := Right;
      Conf         : Width_Configuration  := Default_Linux)
      return Unbounded_Wide_Wide_String
   is
      Current : constant Natural := Display_Width (S, Conf);
   begin
      if Current >= Target_Cells then
         return S;
      end if;
      declare
         Needed  : constant Natural                    := Target_Cells - Current;
         Pad_Str : constant Unbounded_Wide_Wide_String := From_Character (Pad);
         Result  : Unbounded_Wide_Wide_String          := S;
      begin
         case Side is
            when Right =>
               for K in 1 .. Needed loop
                  Result := Concat_Strings (Result, Pad_Str);
               end loop;
            when Left =>
               for K in 1 .. Needed loop
                  Result := Concat_Strings (Pad_Str, Result);
               end loop;
            when Both =>
               declare
                  Right_Count : constant Natural := (Needed + 1) / 2;
                  Left_Count  : constant Natural := Needed / 2;
               begin
                  for K in 1 .. Right_Count loop
                     Result := Concat_Strings (Result, Pad_Str);
                  end loop;
                  for K in 1 .. Left_Count loop
                     Result := Concat_Strings (Pad_Str, Result);
                  end loop;
               end;
         end case;
         return Result;
      end;
   end Pad_To_Width;

end Wide_Wide_Width;
