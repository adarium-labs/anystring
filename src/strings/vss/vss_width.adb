--  VSS_Width body — Display-width and grapheme-cluster operations (vss backend)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

package body VSS_Width
  with SPARK_Mode => Off
is

   --  Encode S to UTF-8 bytes for Umwi consumption.
   function To_UTF8_Bytes (S : VSS.Strings.Virtual_String) return Umwi.UTF8_String
   is (Umwi.UTF8_String (VSS_Operations.To_UTF_8 (S)));

   --  Reconstruct a Virtual_String from a UTF-8 byte sequence.
   function From_UTF8_Bytes (Bytes : String) return VSS.Strings.Virtual_String is
   begin
      return VSS_UTF_8_Results.Get_Value_Or (VSS_UTF_8_Bridge.From_UTF_8_VSS (Bytes), VSS.Strings.Empty_Virtual_String);
   end From_UTF8_Bytes;

   --  Build a Virtual_String of Count copies of Wide_Wide_Character C.
   function Repeat_Char (C : Wide_Wide_Character; Count : Natural) return VSS.Strings.Virtual_String is
      Result : VSS.Strings.Virtual_String := VSS.Strings.Empty_Virtual_String;
   begin
      for J in 1 .. Count loop
         Result := VSS_Operations.Concat_String_Character (Result, C);
      end loop;
      return Result;
   end Repeat_Char;

   --  ---- Grapheme_View iterable primitives ----

   function First (V : Grapheme_View) return Grapheme_Cursor is
      Bytes : constant Umwi.UTF8_String := To_UTF8_Bytes (V.Source);
   begin
      if Bytes'Length = 0 then
         return (Is_Done => True, others => <>);
      end if;
      declare
         Cl : constant Umwi.UTF8_Grapheme_Cluster := Umwi.Next_Cluster (Bytes, Bytes'First, V.Conf);
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
      Bytes    : constant Umwi.UTF8_String := To_UTF8_Bytes (V.Source);
      Next_Pos : constant Natural := C.Last_Byte + 1;
   begin
      if Next_Pos > Bytes'Last then
         return (Is_Done => True, others => <>);
      end if;
      declare
         Cl : constant Umwi.UTF8_Grapheme_Cluster := Umwi.Next_Cluster (Bytes, Next_Pos, V.Conf);
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
      Bytes : constant Umwi.UTF8_String := To_UTF8_Bytes (V.Source);
   begin
      return
        (Width       => C.Disp_Width,
         Code_Points => C.Num_Points,
         Slice       => From_UTF8_Bytes (String (Bytes (C.First_Byte .. C.Last_Byte))));
   end Element;

   --  @relation(FUNC-WIDTH-005)
   function Graphemes (S : VSS.Strings.Virtual_String; Conf : Width_Configuration := Default_Linux) return Grapheme_View
   is
   begin
      return (Source => S, Conf => Conf);
   end Graphemes;

   --  ---- Scalar queries ----

   --  @relation(FUNC-WIDTH-003)
   function Display_Width (S : VSS.Strings.Virtual_String; Conf : Width_Configuration := Default_Linux) return Natural
   is
      Bytes  : constant Umwi.UTF8_String := To_UTF8_Bytes (S);
      Total  : Natural := 0;
      Cursor : Positive := Bytes'First;
   begin
      if Bytes'Length = 0 then
         return 0;
      end if;
      while Cursor <= Bytes'Last loop
         declare
            Cl : constant Umwi.UTF8_Grapheme_Cluster := Umwi.Next_Cluster (Bytes, Cursor, Conf);
         begin
            Total := Total + Cl.Width;
            Cursor := Cl.Last_Byte + 1;
         end;
      end loop;
      return Total;
   end Display_Width;

   --  @relation(FUNC-WIDTH-004)
   function Grapheme_Count (S : VSS.Strings.Virtual_String; Conf : Width_Configuration := Default_Linux) return Natural
   is
      Bytes  : constant Umwi.UTF8_String := To_UTF8_Bytes (S);
      Count  : Natural := 0;
      Cursor : Positive := Bytes'First;
   begin
      if Bytes'Length = 0 then
         return 0;
      end if;
      while Cursor <= Bytes'Last loop
         declare
            Cl : constant Umwi.UTF8_Grapheme_Cluster := Umwi.Next_Cluster (Bytes, Cursor, Conf);
         begin
            Count := Count + 1;
            Cursor := Cl.Last_Byte + 1;
         end;
      end loop;
      return Count;
   end Grapheme_Count;

   --  ---- Cluster-indexed operations ----

   --  @relation(FUNC-WIDTH-011)
   function Cluster_Element
     (S : VSS.Strings.Virtual_String; Index : Positive; Conf : Width_Configuration := Default_Linux) return Grapheme
   is
      Bytes  : constant Umwi.UTF8_String := To_UTF8_Bytes (S);
      I      : Natural := 0;
      Cursor : Positive := Bytes'First;
   begin
      while Cursor <= Bytes'Last loop
         declare
            Cl : constant Umwi.UTF8_Grapheme_Cluster := Umwi.Next_Cluster (Bytes, Cursor, Conf);
         begin
            I := I + 1;
            if I = Index then
               return
                 (Width       => Cl.Width,
                  Code_Points => Cl.Points,
                  Slice       => From_UTF8_Bytes (String (Bytes (Cl.First_Byte .. Cl.Last_Byte))));
            end if;
            Cursor := Cl.Last_Byte + 1;
         end;
      end loop;
      --  Unreachable: precondition guarantees Index in 1 .. Cluster_Length (S).
      return (Width => 0, Code_Points => 1, Slice => VSS.Strings.Empty_Virtual_String);
   end Cluster_Element;

   --  @relation(FUNC-WIDTH-012)
   function Cluster_Slice
     (S            : VSS.Strings.Virtual_String;
      From_Cluster : Positive;
      To_Cluster   : Natural;
      Conf         : Width_Configuration := Default_Linux) return VSS.Strings.Virtual_String is
   begin
      if To_Cluster = 0 then
         return VSS.Strings.Empty_Virtual_String;
      end if;
      declare
         Bytes      : constant Umwi.UTF8_String := To_UTF8_Bytes (S);
         I          : Natural := 0;
         Cursor     : Positive := Bytes'First;
         First_Byte : Positive := Bytes'First;
      begin
         if Bytes'Length = 0 then
            return VSS.Strings.Empty_Virtual_String;
         end if;
         while Cursor <= Bytes'Last loop
            declare
               Cl : constant Umwi.UTF8_Grapheme_Cluster := Umwi.Next_Cluster (Bytes, Cursor, Conf);
            begin
               I := I + 1;
               if I = From_Cluster then
                  First_Byte := Cl.First_Byte;
               end if;
               if I = To_Cluster then
                  return From_UTF8_Bytes (String (Bytes (First_Byte .. Cl.Last_Byte)));
               end if;
               Cursor := Cl.Last_Byte + 1;
            end;
         end loop;
         return VSS.Strings.Empty_Virtual_String;
      end;
   end Cluster_Slice;

   --  @relation(FUNC-WIDTH-013)
   function Cluster_Head
     (S : VSS.Strings.Virtual_String; Count : Natural; Conf : Width_Configuration := Default_Linux)
      return VSS.Strings.Virtual_String
   is
      Total : constant Natural := Grapheme_Count (S, Conf);
   begin
      if Count = 0 then
         return VSS.Strings.Empty_Virtual_String;
      end if;
      if Count >= Total then
         return S;
      end if;
      return Cluster_Slice (S, 1, Count, Conf);
   end Cluster_Head;

   --  @relation(FUNC-WIDTH-013)
   function Cluster_Tail
     (S : VSS.Strings.Virtual_String; Count : Natural; Conf : Width_Configuration := Default_Linux)
      return VSS.Strings.Virtual_String
   is
      Total : constant Natural := Grapheme_Count (S, Conf);
   begin
      if Count = 0 or else Total = 0 then
         return VSS.Strings.Empty_Virtual_String;
      end if;
      if Count >= Total then
         return S;
      end if;
      return Cluster_Slice (S, Total - Count + 1, Total, Conf);
   end Cluster_Tail;

   --  ---- Width-budget helpers ----

   --  @relation(FUNC-WIDTH-014)
   function Head_By_Width
     (S                : VSS.Strings.Virtual_String;
      Max_Cells        : Natural;
      Allow_Split_Wide : Boolean := False;
      Conf             : Width_Configuration := Default_Linux) return Width_Slice_Result
   is
      pragma Unreferenced (Allow_Split_Wide);
      Bytes     : constant Umwi.UTF8_String := To_UTF8_Bytes (S);
      Cursor    : Positive := Bytes'First;
      Acc_Width : Natural := 0;
      Last_Good : Natural := 0;
   begin
      if Max_Cells = 0 or else Bytes'Length = 0 then
         return (Result => VSS.Strings.Empty_Virtual_String, Width => 0, Truncated => Bytes'Length > 0);
      end if;
      while Cursor <= Bytes'Last loop
         declare
            Cl : constant Umwi.UTF8_Grapheme_Cluster := Umwi.Next_Cluster (Bytes, Cursor, Conf);
         begin
            if Acc_Width + Cl.Width > Max_Cells then
               return
                 (Result    => From_UTF8_Bytes (String (Bytes (Bytes'First .. Last_Good))),
                  Width     => Acc_Width,
                  Truncated => True);
            end if;
            Acc_Width := Acc_Width + Cl.Width;
            Last_Good := Cl.Last_Byte;
            Cursor := Cl.Last_Byte + 1;
         end;
      end loop;
      return (Result => S, Width => Acc_Width, Truncated => False);
   end Head_By_Width;

   --  @relation(FUNC-WIDTH-015)
   function Truncate_With_Ellipsis
     (S         : VSS.Strings.Virtual_String;
      Max_Cells : Natural;
      Ellipsis  : VSS.Strings.Virtual_String := Default_Ellipsis;
      Conf      : Width_Configuration := Default_Linux) return VSS.Strings.Virtual_String
   is
      S_Width : constant Natural := Display_Width (S, Conf);
      E_Width : constant Natural := Display_Width (Ellipsis, Conf);
   begin
      if S_Width <= Max_Cells then
         return S;
      end if;
      if Max_Cells = 0 then
         return VSS.Strings.Empty_Virtual_String;
      end if;
      if E_Width >= Max_Cells then
         --  Budget too tight to fit content + ellipsis; truncate the ellipsis itself.
         return Head_By_Width (Ellipsis, Max_Cells, False, Conf).Result;
      end if;
      return VSS_Operations.Concat_Strings (Head_By_Width (S, Max_Cells - E_Width, False, Conf).Result, Ellipsis);
   end Truncate_With_Ellipsis;

   --  @relation(FUNC-WIDTH-016)
   function Pad_To_Width
     (S            : VSS.Strings.Virtual_String;
      Target_Cells : Natural;
      Pad          : Wide_Wide_Character := ' ';
      Side         : Pad_Side := Right;
      Conf         : Width_Configuration := Default_Linux) return VSS.Strings.Virtual_String
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
            when Left  =>
               return VSS_Operations.Concat_Strings (Repeat_Char (Pad, Needed), S);

            when Right =>
               return VSS_Operations.Concat_Strings (S, Repeat_Char (Pad, Needed));

            when Both  =>
               declare
                  Left_Count  : constant Natural := Needed / 2;
                  Right_Count : constant Natural := Needed - Left_Count;
               begin
                  return
                    VSS_Operations.Concat_Strings
                      (VSS_Operations.Concat_Strings (Repeat_Char (Pad, Left_Count), S),
                       Repeat_Char (Pad, Right_Count));
               end;
         end case;
      end;
   end Pad_To_Width;

end VSS_Width;
