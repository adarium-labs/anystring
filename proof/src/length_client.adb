-------------------------------------------------------------------------------
--  Proof client - length contracts of String_Types (SPARK)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

package body Length_Client
  with SPARK_Mode
is

   procedure Empty_Has_Zero_Length is
   begin
      pragma Assert (Length (Empty_String) = 0);
      pragma Assert (Is_Empty (Empty_String));
   end Empty_Has_Zero_Length;

   procedure Concat_Adds_Lengths (A, B : String_Type) is
      R : constant String_Type := A & B;
   begin
      pragma Assert (Length (R) = Length (A) + Length (B));
      pragma Assert (Length (Concat (A, B)) = Length (A) + Length (B));
      pragma Assert (Length (A & 'x') = Length (A) + 1);
      pragma Assert (Length ('x' & B) = 1 + Length (B));
   end Concat_Adds_Lengths;

   procedure Append_Adds_Length (Source : in out String_Type; New_Item : String_Type) is
      Before : constant Natural := Length (Source);
   begin
      Append (Source, New_Item);
      pragma Assert (Length (Source) = Before + Length (New_Item));
   end Append_Adds_Length;

   procedure Slice_Lengths (Source : String_Type; Low : Positive; High : Natural) is
      R    : constant String_Type := Slice (Source, Low, High);
      Full : constant String_Type := Slice (Source, 1, Length (Source));
   begin
      pragma Assert (Length (R) = (if High < Low then 0 else High - Low + 1));
      pragma Assert (Length (Full) = Length (Source));
   end Slice_Lengths;

   procedure Literal_Length is
      S : constant String_Type := To_String_Type ("; ");
   begin
      pragma Assert (Length (S) = 2);
   end Literal_Length;

end Length_Client;
