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

   function Full_Map (Run : Wide_Wide_String; Upper : Boolean) return Wide_Wide_String is
      --  Each code point maps to at most three code points.
      Buf : Wide_Wide_String (1 .. 3 * Run'Length);
      N   : Natural := 0;
   begin
      for I in Run'Range loop
         declare
            CP    : constant Natural := Code (Run (I));
            Text  : Anystrings_UCD_Case.Mapped_Text;
            Count : Anystrings_UCD_Case.Mapping_Length;
         begin
            if not Is_Scalar (CP) then
               N := N + 1;
               Buf (N) := Run (I);
            else
               if Upper then
                  Anystrings_UCD_Case.Full_Upper (CP, Text, Count);
               elsif CP = Anystrings_UCD_Case.Final_Sigma_Source and then Final_Sigma (Run, I) then
                  Text := (1 => Anystrings_UCD_Case.Final_Sigma_Target, others => 0);
                  Count := 1;
               else
                  Anystrings_UCD_Case.Full_Lower (CP, Text, Count);
               end if;
               for K in 1 .. Count loop
                  N := N + 1;
                  Buf (N) := To_Wide_Wide (Text (K));
               end loop;
            end if;
         end;
      end loop;
      return Buf (1 .. N);
   end Full_Map;

end Anystrings_Simple_Case;
