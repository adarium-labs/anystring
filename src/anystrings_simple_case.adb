-------------------------------------------------------------------------------
--  Anystrings_Simple_Case - Unicode case mapping of scalar values and runs
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Anystrings_UCD_Case;

package body Anystrings_Simple_Case is

   subtype Scalar_Code is Natural range 0 .. 16#10_FFFF#;

   function Code (C : Wide_Wide_Character) return Natural is
   begin
      return Wide_Wide_Character'Pos (C);
   end Code;

   function Is_Scalar (CP : Natural) return Boolean is
   begin
      return CP <= 16#10_FFFF# and then CP not in 16#D800# .. 16#DFFF#;
   end Is_Scalar;

   function To_Wide_Wide (CP : Scalar_Code) return Wide_Wide_Character is
   begin
      return Wide_Wide_Character'Val (CP);
   end To_Wide_Wide;

   function Lower (C : Wide_Wide_Character) return Wide_Wide_Character is
      CP : constant Natural := Code (C);
   begin
      if not Is_Scalar (CP) then
         return C;
      end if;
      return To_Wide_Wide (Anystrings_UCD_Case.Simple_Lower (CP));
   end Lower;

   --  Final_Sigma (SpecialCasing, Unicode 3.13): the sigma at Index is preceded
   --  by a cased letter, with only case-ignorable characters between them, and
   --  is not followed by case-ignorable characters and then a cased letter.
   --  Only the context inside Run is used.
   function Final_Sigma (Run : Wide_Wide_String; Index : Positive) return Boolean is
      Before : Boolean := False;
      J      : Natural := Index - 1;
      K      : Natural := Index + 1;
   begin
      while J >= Run'First loop
         declare
            CP : constant Natural := Code (Run (J));
         begin
            if not Anystrings_UCD_Case.Is_Case_Ignorable (CP) then
               Before := Anystrings_UCD_Case.Is_Cased (CP);
               exit;
            end if;
         end;
         J := J - 1;
      end loop;
      if not Before then
         return False;
      end if;

      while K <= Run'Last loop
         declare
            CP : constant Natural := Code (Run (K));
         begin
            if not Anystrings_UCD_Case.Is_Case_Ignorable (CP) then
               return not Anystrings_UCD_Case.Is_Cased (CP);
            end if;
         end;
         K := K + 1;
      end loop;
      return True;
   end Final_Sigma;

   procedure Map_At
     (Run   : Wide_Wide_String;
      I     : Positive;
      Upper : Boolean;
      Chars : out Mapped_Chars;
      Count : out Map_Count)
   is
      CP    : constant Natural := Code (Run (I));
      Text  : Anystrings_UCD_Case.Mapped_Text;
      Text_Count : Anystrings_UCD_Case.Mapping_Length;
   begin
      Chars := (others => Wide_Wide_Character'First);
      if not Is_Scalar (CP) then
         Chars (1) := Run (I);
         Count := 1;
      elsif Upper then
         Anystrings_UCD_Case.Full_Upper (CP, Text, Text_Count);
      elsif CP = Anystrings_UCD_Case.Final_Sigma_Source and then Final_Sigma (Run, I) then
         Text := (1 => Anystrings_UCD_Case.Final_Sigma_Target, others => 0);
         Text_Count := 1;
      else
         Anystrings_UCD_Case.Full_Lower (CP, Text, Text_Count);
      end if;

      if Is_Scalar (CP) then
         for K in 1 .. Text_Count loop
            Chars (K) := To_Wide_Wide (Text (K));
         end loop;
         Count := Text_Count;
      end if;
   end Map_At;

   function UTF_16_Size (C : Wide_Wide_Character) return Long_Long_Integer is
   begin
      return (if Code (C) <= 16#FFFF# then 1 else 2);
   end UTF_16_Size;

   function UTF_8_Size (C : Wide_Wide_Character) return Long_Long_Integer is
      CP : constant Natural := Code (C);
   begin
      if CP <= 16#7F# then
         return 1;
      elsif CP <= 16#7FF# then
         return 2;
      elsif CP <= 16#FFFF# then
         return 3;
      else
         return 4;
      end if;
   end UTF_8_Size;

   function Mapped_Code_Points (Run : Wide_Wide_String; Upper : Boolean) return Long_Long_Integer is
      Chars : Mapped_Chars;
      Count : Map_Count;
      Total : Long_Long_Integer := 0;
   begin
      for I in Run'Range loop
         Map_At (Run, I, Upper, Chars, Count);
         Total := Total + Long_Long_Integer (Count);
      end loop;
      return Total;
   end Mapped_Code_Points;

   function Mapped_UTF_16_Units (Run : Wide_Wide_String; Upper : Boolean) return Long_Long_Integer is
      Chars : Mapped_Chars;
      Count : Map_Count;
      Total : Long_Long_Integer := 0;
   begin
      for I in Run'Range loop
         Map_At (Run, I, Upper, Chars, Count);
         for K in 1 .. Count loop
            Total := Total + UTF_16_Size (Chars (K));
         end loop;
      end loop;
      return Total;
   end Mapped_UTF_16_Units;

   function Mapped_UTF_8_Bytes (Run : Wide_Wide_String; Upper : Boolean) return Long_Long_Integer is
      Chars : Mapped_Chars;
      Count : Map_Count;
      Total : Long_Long_Integer := 0;
   begin
      for I in Run'Range loop
         Map_At (Run, I, Upper, Chars, Count);
         for K in 1 .. Count loop
            Total := Total + UTF_8_Size (Chars (K));
         end loop;
      end loop;
      return Total;
   end Mapped_UTF_8_Bytes;

   function Full_Map (Run : Wide_Wide_String; Upper : Boolean) return Wide_Wide_String is
      --  Pass 1 (the precondition bounds the size by Natural'Last); pass 2 fills
      --  exactly that many code points, so Pos never exceeds Size.
      Size  : constant Natural := Natural (Mapped_Code_Points (Run, Upper));
      Buf   : Wide_Wide_String (1 .. Size);
      Pos   : Natural := 0;
      Chars : Mapped_Chars;
      Count : Map_Count;
   begin
      for I in Run'Range loop
         Map_At (Run, I, Upper, Chars, Count);
         for K in 1 .. Count loop
            Pos := Pos + 1;
            Buf (Pos) := Chars (K);
         end loop;
      end loop;
      return Buf;
   end Full_Map;

end Anystrings_Simple_Case;
