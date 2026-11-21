-------------------------------------------------------------------------------
--  Anystrings_UTF_8_Case - Case mapping of UTF-8 storage (shared walker)
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

package body Anystrings_UTF_8_Case
  with SPARK_Mode
is
   pragma Assertion_Policy
     (Ghost => Ignore, Post => Ignore, Loop_Invariant => Ignore, Assert => Ignore, Loop_Variant => Ignore);

   --  Decode the sequence starting at Buf (Start), RFC 3629:
   --    1 byte   0xxxxxxx
   --    2 bytes  110xxxxx 10xxxxxx           U+0080 .. U+07FF
   --    3 bytes  1110xxxx 10xxxxxx 10xxxxxx  U+0800 .. U+FFFF
   --    4 bytes  11110xxx 10xxxxxx 10xxxxxx 10xxxxxx  U+10000 .. U+10FFFF
   --  Anything else (bare continuation, lead 0xC0 / 0xC1 / 0xF5 .. 0xFF, a
   --  truncated sequence, an overlong 3- or 4-byte form, a surrogate, a value
   --  above U+10FFFF) gives U+FFFD with the Step the caller must resynchronise
   --  with: 1 byte, except a surrogate (3 bytes consumed, still replaced).
   --
   --  Every test of the form "Room >= K" below, with Room = Buf'Last - Start,
   --  keeps Start + K from being formed past Buf'Last (it would overflow when
   --  Buf'Last is Positive'Last).
   function Decode (Buf : String; Start : Positive) return Decoded is
      function Is_Cont (C : Character) return Boolean
      is (Character'Pos (C) in 16#80# .. 16#BF#);

      Lead       : constant Natural := Character'Pos (Buf (Start));
      Room       : constant Natural := Buf'Last - Start;
      Code_Point : Natural := 16#FFFD#;
      Step       : Sequence_Length := 1;
   begin
      if Lead <= 16#7F# then
         Code_Point := Lead;

      elsif Lead in 16#C2# .. 16#DF# and then Room >= 1 and then Is_Cont (Buf (Start + 1)) then
         Code_Point := (Lead mod 32) * 64 + (Character'Pos (Buf (Start + 1)) mod 64);
         Step := 2;

      elsif Lead in 16#E0# .. 16#EF#
        and then Room >= 2
        and then Is_Cont (Buf (Start + 1))
        and then Is_Cont (Buf (Start + 2))
      then
         Code_Point :=
           (Lead mod 16) * 4_096
           + (Character'Pos (Buf (Start + 1)) mod 64) * 64
           + (Character'Pos (Buf (Start + 2)) mod 64);
         Step := 3;
         if Code_Point in 16#D800# .. 16#DFFF# then
            Code_Point := 16#FFFD#;
         elsif Code_Point < 16#800# then
            --  Overlong: E0 80..9F is not a shortest form. Resynchronise at the
            --  lead byte, as for any other ill-formed sequence.
            Code_Point := 16#FFFD#;
            Step := 1;
         end if;

      elsif Lead in 16#F0# .. 16#F4#
        and then Room >= 3
        and then Is_Cont (Buf (Start + 1))
        and then Is_Cont (Buf (Start + 2))
        and then Is_Cont (Buf (Start + 3))
      then
         Code_Point :=
           (Lead mod 8) * 262_144
           + (Character'Pos (Buf (Start + 1)) mod 64) * 4_096
           + (Character'Pos (Buf (Start + 2)) mod 64) * 64
           + (Character'Pos (Buf (Start + 3)) mod 64);
         Step := 4;
         if Code_Point > 16#10_FFFF# then
            Code_Point := 16#FFFD#;
         elsif Code_Point < 16#1_0000# then
            --  Overlong: F0 80..8F is not a shortest form.
            Code_Point := 16#FFFD#;
            Step := 1;
         end if;
      end if;

      pragma Assert (Code_Point <= 16#10_FFFF#);
      return (Code_Point => Code_Point, Step => Step);
   end Decode;

   function Run_Last (S : String; I : Positive) return Natural is
      Last : Natural := I - 1;
   begin
      while Last < S'Last loop
         pragma Loop_Invariant (Last in I - 1 .. S'Last);
         pragma Loop_Variant (Increases => Last);
         declare
            Start : constant Positive := Last + 1;
         begin
            exit when not Is_Canonical (S, Start);
            Last := Last + Decode (S, Start).Step;
         end;
      end loop;
      return Last;
   end Run_Last;

   function Case_Length (S : String; Upper : Boolean) return Long_Long_Integer is
      Total : Long_Long_Integer := 0;
      I     : Positive;
      Last  : Positive;
   begin
      if S'Length = 0 then
         return 0;
      end if;
      I := S'First;
      loop
         pragma Loop_Invariant (I in S'Range);
         pragma Loop_Variant (Increases => I);
         pragma Loop_Invariant (Total + Rest_Size (S, I, Upper) = Rest_Size (S, S'First, Upper));
         Last  := Piece_Last (S, I);
         Total := Total + Piece_Size (S, I, Upper);
         exit when Last = S'Last;
         I := Last + 1;
      end loop;
      return Total;
   end Case_Length;

   function Case_Map (S : String; Upper : Boolean) return String is
      Size   : constant Natural := Natural (Case_Length (S, Upper));
      Result : String (1 .. Size) := (others => Character'First);
      Pos    : Natural := 0;
      I      : Positive;
      Last   : Positive;
   begin
      if S'Length = 0 then
         return Result;
      end if;
      I := S'First;
      loop
         pragma Loop_Invariant (I in S'Range);
         pragma Loop_Variant (Increases => I);
         pragma Loop_Invariant (Pos <= Size);
         pragma Loop_Invariant (Long_Long_Integer (Pos) + Rest_Size (S, I, Upper) = Long_Long_Integer (Size));
         declare
            RL : constant Natural := Run_Last (S, I);
         begin
            if RL >= I then
               declare
                  CPs : constant Wide_Wide_String := Anystrings_UTF_8_Replace.Decode_Replacing (S (I .. RL));
               begin
                  Anystrings_Simple_Case.Put_Mapped_UTF_8 (CPs, Upper, Result, Pos);
               end;
               Last := RL;
            else
               declare
                  Step : constant Positive := Raw_Step (S, I);
               begin
                  Result (Pos + 1 .. Pos + Step) := S (I .. I + (Step - 1));
                  Pos  := Pos + Step;
                  Last := I + (Step - 1);
               end;
            end if;
         end;
         exit when Last = S'Last;
         I := Last + 1;
      end loop;
      return Result;
   end Case_Map;

   function Simple_Lower (S : String) return String is
      Result : String := S;
      I      : Positive;
      Last   : Positive;
   begin
      if S'Length = 0 then
         return Result;
      end if;
      I := S'First;
      loop
         pragma Loop_Invariant (I in S'Range);
         pragma Loop_Variant (Increases => I);
         pragma Loop_Invariant (Result'First = S'First and then Result'Last = S'Last);
         declare
            D : constant Decoded := Decode (S, I);
         begin
            Last := I + (D.Step - 1);
            if Is_Canonical (S, I) then
               declare
                  Lower : constant Natural := Anystrings_Simple_Case.Simple_Lower_Code_Point (D.Code_Point);
               begin
                  --  Keep the mapping only when its byte length is unchanged, so
                  --  that the result has the length of S.
                  if Lower /= D.Code_Point and then Anystrings_Simple_Case.UTF_8_Size (Lower) = D.Step then
                     Result (I .. Last) := Anystrings_Simple_Case.UTF_8_Of (Lower);
                  end if;
               end;
            end if;
         end;
         exit when Last = S'Last;
         I := Last + 1;
      end loop;
      return Result;
   end Simple_Lower;

end Anystrings_UTF_8_Case;
