-------------------------------------------------------------------------------
--  Anystrings_Simple_Case - Unicode case mapping of scalar values and runs
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Anystrings_UCD_Case;

package body Anystrings_Simple_Case
  with SPARK_Mode
is
   pragma Assertion_Policy
     (Ghost => Ignore, Post => Ignore, Loop_Invariant => Ignore, Assert => Ignore, Loop_Variant => Ignore);

   function Code (C : Wide_Wide_Character) return Natural
   is (Wide_Wide_Character'Pos (C));

   function Is_Scalar (CP : Natural) return Boolean
   is (CP <= 16#10_FFFF# and then CP not in 16#D800# .. 16#DFFF#);

   function To_Wide_Wide (CP : Natural) return Wide_Wide_Character
   is (Wide_Wide_Character'Val (CP));

   function Simple_Lower_Code_Point (CP : Natural) return Natural is
   begin
      if not Is_Scalar (CP) then
         return CP;
      end if;
      return Anystrings_UCD_Case.Simple_Lower (CP);
   end Simple_Lower_Code_Point;

   function Lower (C : Wide_Wide_Character) return Wide_Wide_Character
   is (To_Wide_Wide (Simple_Lower_Code_Point (Code (C))));

   --  Cased / Case_Ignorable of a Wide_Wide_Character that need not be a code
   --  point: a value above U+10FFFF is neither.
   function Is_Cased (C : Wide_Wide_Character) return Boolean
   is (Code (C) <= 16#10_FFFF# and then Anystrings_UCD_Case.Is_Cased (Code (C)));

   function Is_Case_Ignorable (C : Wide_Wide_Character) return Boolean
   is (Code (C) <= 16#10_FFFF# and then Anystrings_UCD_Case.Is_Case_Ignorable (Code (C)));

   --  Final_Sigma (SpecialCasing, Unicode 3.13): the sigma at Index is preceded
   --  by a cased letter, with only case-ignorable characters between them, and
   --  is not followed by case-ignorable characters and then a cased letter.
   --  Only the context inside Run is used.
   --
   --  No index is formed past Run'Last: the scan forward only steps while
   --  K < Run'Last, and the scan backward only steps while J >= Run'First (so
   --  J - 1 >= 0). A sigma at Index = Natural'Last has no following character
   --  and takes the "end of run" answer.
   function Final_Sigma (Run : Wide_Wide_String; Index : Positive) return Boolean
   with Pre => Index in Run'Range
   is
      Before : Boolean := False;
      J      : Natural := Index - 1;
      K      : Positive := Index;
   begin
      while J >= Run'First loop
         pragma Loop_Invariant (J < Index);
         pragma Loop_Variant (Decreases => J);
         if not Is_Case_Ignorable (Run (J)) then
            Before := Is_Cased (Run (J));
            exit;
         end if;
         J := J - 1;
      end loop;
      if not Before then
         return False;
      end if;

      while K < Run'Last loop
         pragma Loop_Invariant (K in Index .. Run'Last);
         pragma Loop_Variant (Increases => K);
         K := K + 1;
         if not Is_Case_Ignorable (Run (K)) then
            return not Is_Cased (Run (K));
         end if;
      end loop;
      return True;
   end Final_Sigma;

   function Map_At (Run : Wide_Wide_String; I : Positive; Upper : Boolean) return Mapping is
      CP         : constant Natural := Code (Run (I));
      Result     : Mapping := (Chars => (others => Wide_Wide_Character'First), Count => 1);
      Text       : Anystrings_UCD_Case.Mapped_Text;
      Text_Count : Anystrings_UCD_Case.Mapping_Length;
   begin
      if not Is_Scalar (CP) then
         Result.Chars (1) := Run (I);
         return Result;
      end if;

      if Upper then
         Anystrings_UCD_Case.Full_Upper (CP, Text, Text_Count);
      elsif CP = Anystrings_UCD_Case.Final_Sigma_Source and then Final_Sigma (Run, I) then
         Text := (1 => Anystrings_UCD_Case.Final_Sigma_Target, others => 0);
         Text_Count := 1;
      else
         Anystrings_UCD_Case.Full_Lower (CP, Text, Text_Count);
      end if;

      for K in 1 .. Text_Count loop
         pragma Loop_Invariant (for all J in Mapped_Chars'Range => Code (Result.Chars (J)) <= 16#10_FFFF#);
         Result.Chars (K) := To_Wide_Wide (Text (K));
      end loop;
      Result.Count := Text_Count;
      return Result;
   end Map_At;

   function Prefix_Size
     (Run : Wide_Wide_String; Upper : Boolean; Kind : Size_Kind; Last : Natural) return Long_Long_Integer
   is (if Last < Run'First
       then 0
       else Prefix_Size (Run, Upper, Kind, Last - 1) + Long_Long_Integer (Size_At (Run, Last, Upper, Kind)));

   procedure Lemma_Prefix_Monotone
     (Run : Wide_Wide_String; Upper : Boolean; Kind : Size_Kind; First : Natural; Last : Natural) is
   begin
      if First < Last then
         Lemma_Prefix_Monotone (Run, Upper, Kind, First, Last - 1);
      end if;
   end Lemma_Prefix_Monotone;

   function Mapped_Size (Run : Wide_Wide_String; Upper : Boolean; Kind : Size_Kind) return Long_Long_Integer is
      Total : Long_Long_Integer := 0;
   begin
      for I in Run'Range loop
         pragma Loop_Invariant (Total = Prefix_Size (Run, Upper, Kind, I - 1));
         declare
            M : constant Mapping := Map_At (Run, I, Upper);
         begin
            Total := Total + Long_Long_Integer (Partial_Size (M, M.Count, Kind));
         end;
         pragma Assert
           (Total = Prefix_Size (Run, Upper, Kind, I));
      end loop;
      return Total;
   end Mapped_Size;

   function Full_Map (Run : Wide_Wide_String; Upper : Boolean) return Wide_Wide_String is
      Size : constant Natural := Natural (Mapped_Size (Run, Upper, Code_Points));
      Buf  : Wide_Wide_String (1 .. Size) := (others => Wide_Wide_Character'First);
      Pos  : Natural := 0;
   begin
      for I in Run'Range loop
         pragma Loop_Invariant (Long_Long_Integer (Pos) = Prefix_Size (Run, Upper, Code_Points, I - 1));
         declare
            M : constant Mapping := Map_At (Run, I, Upper);
         begin
            Lemma_Prefix_Monotone (Run, Upper, Code_Points, I, Run'Last);
            pragma Assert
              (Prefix_Size (Run, Upper, Code_Points, I)
               = Prefix_Size (Run, Upper, Code_Points, I - 1) + Long_Long_Integer (M.Count));
            for K in 1 .. M.Count loop
               pragma Loop_Invariant
                 (Long_Long_Integer (Pos) = Prefix_Size (Run, Upper, Code_Points, I - 1) + Long_Long_Integer (K - 1));
               Pos := Pos + 1;
               Buf (Pos) := M.Chars (K);
            end loop;
         end;
      end loop;
      return Buf;
   end Full_Map;

   function Full_Map_UTF_16 (Run : Wide_Wide_String; Upper : Boolean) return Wide_String is
      Size : constant Natural := Natural (Mapped_Size (Run, Upper, UTF_16_Units));
      Buf  : Wide_String (1 .. Size) := (others => Wide_Character'First);
      Pos  : Natural := 0;
   begin
      for I in Run'Range loop
         pragma Loop_Invariant (Long_Long_Integer (Pos) = Prefix_Size (Run, Upper, UTF_16_Units, I - 1));
         declare
            M : constant Mapping := Map_At (Run, I, Upper);
         begin
            Lemma_Prefix_Monotone (Run, Upper, UTF_16_Units, I, Run'Last);
            pragma Assert
              (Prefix_Size (Run, Upper, UTF_16_Units, I)
               = Prefix_Size (Run, Upper, UTF_16_Units, I - 1) + Long_Long_Integer (Partial_Size (M, M.Count, UTF_16_Units)));
            for K in 1 .. M.Count loop
               pragma Loop_Invariant
                 (Long_Long_Integer (Pos)
                  = Prefix_Size (Run, Upper, UTF_16_Units, I - 1)
                    + Long_Long_Integer (Partial_Size (M, K - 1, UTF_16_Units)));
               declare
                  P : constant Natural := Code (M.Chars (K));
               begin
                  if P <= 16#FFFF# then
                     Buf (Pos + 1) := Wide_Character'Val (P);
                     Pos := Pos + 1;
                  else
                     declare
                        Off : constant Natural := P - 16#1_0000#;
                     begin
                        Buf (Pos + 1) := Wide_Character'Val (16#D800# + Off / 16#400#);
                        Buf (Pos + 2) := Wide_Character'Val (16#DC00# + Off mod 16#400#);
                        Pos := Pos + 2;
                     end;
                  end if;
               end;
            end loop;
         end;
      end loop;
      return Buf;
   end Full_Map_UTF_16;

   function UTF_8_Of (CP : Natural) return String is
   begin
      if CP <= 16#7F# then
         return (1 => Character'Val (CP));
      elsif CP <= 16#7FF# then
         return (1 => Character'Val (16#C0# + CP / 64), 2 => Character'Val (16#80# + CP mod 64));
      elsif CP <= 16#FFFF# then
         return
           (1 => Character'Val (16#E0# + CP / 4_096),
            2 => Character'Val (16#80# + (CP / 64) mod 64),
            3 => Character'Val (16#80# + CP mod 64));
      else
         return
           (1 => Character'Val (16#F0# + CP / 262_144),
            2 => Character'Val (16#80# + (CP / 4_096) mod 64),
            3 => Character'Val (16#80# + (CP / 64) mod 64),
            4 => Character'Val (16#80# + CP mod 64));
      end if;
   end UTF_8_Of;

   --  Write the UTF-8 bytes of CP to Buf (Pos + 1 ..) and advance Pos.
   procedure Put_UTF_8 (CP : Natural; Buf : in out String; Pos : in out Natural)
   with
     Pre  =>
       Buf'First = 1
       and then CP <= 16#10_FFFF#
       and then Pos <= Buf'Length
       and then Long_Long_Integer (Pos) + Long_Long_Integer (UTF_8_Size (CP)) <= Long_Long_Integer (Buf'Length),
     Post => Pos = Pos'Old + UTF_8_Size (CP)
   is
      Bytes : constant String := UTF_8_Of (CP);
   begin
      for K in Bytes'Range loop
         pragma Loop_Invariant (Pos = Pos'Loop_Entry + (K - 1));
         Pos := Pos + 1;
         Buf (Pos) := Bytes (K);
      end loop;
   end Put_UTF_8;

   procedure Put_Mapped_UTF_8
     (Run : Wide_Wide_String; Upper : Boolean; Buf : in out String; Pos : in out Natural)
   is
      Start : constant Natural := Pos with Ghost;
   begin
      for I in Run'Range loop
         pragma Loop_Invariant (Buf'First = 1);
         pragma Loop_Invariant
           (Long_Long_Integer (Pos) = Long_Long_Integer (Start) + Prefix_Size (Run, Upper, UTF_8_Bytes, I - 1));
         declare
            M : constant Mapping := Map_At (Run, I, Upper);
         begin
            Lemma_Prefix_Monotone (Run, Upper, UTF_8_Bytes, I, Run'Last);
            pragma Assert
              (Prefix_Size (Run, Upper, UTF_8_Bytes, I)
               = Prefix_Size (Run, Upper, UTF_8_Bytes, I - 1) + Long_Long_Integer (Partial_Size (M, M.Count, UTF_8_Bytes)));
            for K in 1 .. M.Count loop
               pragma Loop_Invariant (Buf'First = 1);
               pragma Loop_Invariant
                 (Long_Long_Integer (Pos)
                  = Long_Long_Integer (Start)
                    + Prefix_Size (Run, Upper, UTF_8_Bytes, I - 1)
                    + Long_Long_Integer (Partial_Size (M, K - 1, UTF_8_Bytes)));
               Put_UTF_8 (Code (M.Chars (K)), Buf, Pos);
            end loop;
         end;
      end loop;
   end Put_Mapped_UTF_8;

end Anystrings_Simple_Case;
