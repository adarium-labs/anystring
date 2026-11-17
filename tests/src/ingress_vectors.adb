-------------------------------------------------------------------------------
--  Ingress_Vectors - body
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with String_Types;

package body Ingress_Vectors is

   function Hex_Value (C : Character) return Natural is
   begin
      case C is
         when '0' .. '9' => return Character'Pos (C) - Character'Pos ('0');
         when 'A' .. 'F' => return Character'Pos (C) - Character'Pos ('A') + 10;
         when 'a' .. 'f' => return Character'Pos (C) - Character'Pos ('a') + 10;
         when others     => raise Constraint_Error with "not a hexadecimal digit";
      end case;
   end Hex_Value;

   function Bytes (Hex : String) return String is
      --  Tokens of two digits separated by one space: n tokens take 3 * n - 1
      --  characters, so n = (Hex'Length + 1) / 3.
      Result : String (1 .. (Hex'Length + 1) / 3);
      Last   : Natural := 0;
      I      : Natural := Hex'First;
   begin
      while I <= Hex'Last loop
         if Hex (I) = ' ' then
            I := I + 1;
         else
            Last := Last + 1;
            Result (Last) :=
              Character'Val (Hex_Value (Hex (I)) * 16 + Hex_Value (Hex (I + 1)));
            I := I + 2;
         end if;
      end loop;
      return Result (1 .. Last);
   end Bytes;

   function Code_Points (Hex : String) return Wide_Wide_String is
      Tmp    : Wide_Wide_String (1 .. Hex'Length);
      Count  : Natural := 0;
      Value  : Natural := 0;
      In_Tok : Boolean := False;
   begin
      for C of Hex loop
         if C = ' ' then
            if In_Tok then
               Count := Count + 1;
               Tmp (Count) := Wide_Wide_Character'Val (Value);
               Value := 0;
               In_Tok := False;
            end if;
         else
            Value  := Value * 16 + Hex_Value (C);
            In_Tok := True;
         end if;
      end loop;
      if In_Tok then
         Count := Count + 1;
         Tmp (Count) := Wide_Wide_Character'Val (Value);
      end if;
      return Tmp (1 .. Count);
   end Code_Points;

   --  Minimal uppercase hexadecimal digits of a code point (no leading zeros).
   function Hex_Digits (V : Natural) return String is
      Digit_Chars : constant String := "0123456789ABCDEF";
      Buf         : String (1 .. 8) := (others => '0');
      Pos         : Positive := 8;
      X           : Natural := V;
   begin
      loop
         Buf (Pos) := Digit_Chars (X mod 16 + 1);
         X := X / 16;
         exit when X = 0;
         Pos := Pos - 1;
      end loop;
      return Buf (Pos .. 8);
   end Hex_Digits;

   function Hex_Image (S : Wide_Wide_String) return String is
   begin
      if S'Length = 0 then
         return "-";
      end if;
      declare
         Result : String (1 .. S'Length * 9);
         Last   : Natural := 0;
      begin
         for C of S loop
            declare
               D : constant String := Hex_Digits (Wide_Wide_Character'Pos (C));
            begin
               if Last > 0 then
                  Last := Last + 1;
                  Result (Last) := ' ';
               end if;
               Result (Last + 1 .. Last + D'Length) := D;
               Last := Last + D'Length;
            end;
         end loop;
         return Result (1 .. Last);
      end;
   end Hex_Image;

   function Backend_Class return Positive is
      R   : constant String_Types.UTF_8_Decode_Result :=
        String_Types.From_UTF_8 (Bytes ("F0 9F 98 80"));
      Len : constant Natural := String_Types.Length (String_Types.Get_Value (R));
   begin
      case Len is
         when 4      => return 1;
         when 2      => return 2;
         when others => return 3;
      end case;
   end Backend_Class;

   function Expected_Length (Len_Std, Len_Wide, Len_Other : Natural) return Natural is
   begin
      case Backend_Class is
         when 1      => return Len_Std;
         when 2      => return Len_Wide;
         when others => return Len_Other;
      end case;
   end Expected_Length;

   --  KI-046 Table I, transcribed from the study (section 7.6). Length columns:
   --  standard / wide_string / the other three back ends.
   procedure Emit
     (Visit     : not null Visitor;
      Id        : String;
      Input_Hex : String;
      Cps_Hex   : String;
      Valid     : Boolean;
      CPL       : Natural;
      Len_Std   : Natural;
      Len_Wide  : Natural;
      Len_Other : Natural) is
   begin
      Visit (Id, Input_Hex, Cps_Hex, Valid, CPL, Len_Std, Len_Wide, Len_Other);
   end Emit;

   procedure For_Each_Row (Visit : not null Visitor) is
   begin
      Emit (Visit, "I01", "",                          "",                             True,  0,  0,  0,  0);
      Emit (Visit, "I02", "61 62",                     "61 62",                        True,  2,  2,  2,  2);
      Emit (Visit, "I03", "C3 A9 E2 82 AC F0 9F 98 80", "E9 20AC 1F600",               True,  3,  9,  4,  3);
      Emit (Visit, "I04", "EF BB BF 61",               "FEFF 61",                      True,  2,  4,  2,  2);
      Emit (Visit, "I05", "EF BB BF EF BB BF 61",      "FEFF FEFF 61",                 True,  3,  7,  3,  3);
      Emit (Visit, "I06", "78 E2 82",                  "78 FFFD",                      False, 2,  4,  2,  2);
      Emit (Visit, "I07", "E2 82 61",                  "FFFD 61",                      False, 2,  4,  2,  2);
      Emit (Visit, "I08", "F0 9F 98 61",               "FFFD 61",                      False, 2,  4,  2,  2);
      Emit (Visit, "I09", "C3",                        "FFFD",                         False, 1,  3,  1,  1);
      Emit (Visit, "I10", "61 80 62",                  "61 FFFD 62",                   False, 3,  5,  3,  3);
      Emit (Visit, "I11", "80 80",                     "FFFD FFFD",                    False, 2,  6,  2,  2);
      Emit (Visit, "I12", "C0 80",                     "FFFD FFFD",                    False, 2,  6,  2,  2);
      Emit (Visit, "I13", "C1 BF",                     "FFFD FFFD",                    False, 2,  6,  2,  2);
      Emit (Visit, "I14", "E0 80 80",                  "FFFD FFFD FFFD",               False, 3,  9,  3,  3);
      Emit (Visit, "I15", "F0 80 80 80",               "FFFD FFFD FFFD FFFD",          False, 4, 12,  4,  4);
      Emit (Visit, "I16", "ED A0 80",                  "FFFD FFFD FFFD",               False, 3,  9,  3,  3);
      Emit (Visit, "I17", "ED 9F BF",                  "D7FF",                         True,  1,  3,  1,  1);
      Emit (Visit, "I18", "F4 90 80 80",               "FFFD FFFD FFFD FFFD",          False, 4, 12,  4,  4);
      Emit (Visit, "I19", "F5 80 80 80",               "FFFD FFFD FFFD FFFD",          False, 4, 12,  4,  4);
      Emit (Visit, "I20", "F4 8F BF BF",               "10FFFF",                       True,  1,  4,  2,  1);
      Emit (Visit, "I21", "61 FF 62 FE",               "61 FFFD 62 FFFD",              False, 4,  8,  4,  4);
      Emit (Visit, "I22", "E2 82 E2 82 AC",            "FFFD 20AC",                    False, 2,  6,  2,  2);
      Emit (Visit, "I23", "EF BF BD",                  "FFFD",                         True,  1,  3,  1,  1);
   end For_Each_Row;

end Ingress_Vectors;
