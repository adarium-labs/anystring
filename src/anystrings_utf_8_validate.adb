-------------------------------------------------------------------------------
--  Anystrings_UTF_8_Validate - Shared UTF-8 byte-sequence validator (body)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

package body Anystrings_UTF_8_Validate is

   use Anystrings_UTF_8;

   --  Return an Ok result.
   function Ok return Validate_Result
   is (Validate_Result'(Is_Ok => True));

   --  Return a failed result with the given error category.
   function Fail (E : UTF_8_Decode_Error) return Validate_Result
   is (Validate_Result'(Is_Ok => False, Error => E));

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-010
   function Validate (Source : String) return Validate_Result is

      --  Byte value as Natural for arithmetic comparisons.
      function B (I : Positive) return Natural
      is (Character'Pos (Source (I)));

      --  Extract low N bits of a Natural by taking mod 2**N.
      --  Used instead of 'and' to avoid bitwise-operator type restrictions.
      function Low_5 (X : Natural) return Natural
      is (X mod 32);
      function Low_4 (X : Natural) return Natural
      is (X mod 16);
      function Low_3 (X : Natural) return Natural
      is (X mod 8);
      function Low_6 (X : Natural) return Natural
      is (X mod 64);

      I          : Positive;
      Seq_Length : Natural;  --  Expected total bytes in current sequence
      Code_Point : Natural;  --  Accumulated code point value

   begin
      if Source'Length = 0 then
         return Ok;
      end if;

      I := Source'First;

      loop
         declare
            Lead : constant Natural := B (I);
         begin
            --  Classify lead byte and determine expected sequence length.
            if Lead <= 16#7F# then
               --  ASCII — single byte; always valid.
               Seq_Length := 1;
               Code_Point := Lead;

            elsif Lead in 16#C0# .. 16#DF# then
               --  2-byte sequence; code points U+0080..U+07FF.
               --  C0/C1 are structural 2-byte leads but always overlong
               --  (they would encode U+0000..U+007F); the overlong check
               --  below will catch them and return Overlong_Encoding.
               Seq_Length := 2;
               Code_Point := Low_5 (Lead);

            elsif Lead in 16#E0# .. 16#EF# then
               --  3-byte sequence; code points U+0800..U+FFFF.
               Seq_Length := 3;
               Code_Point := Low_4 (Lead);

            elsif Lead in 16#F0# .. 16#F4# then
               --  4-byte sequence; code points U+10000..U+10FFFF.
               Seq_Length := 4;
               Code_Point := Low_3 (Lead);

            elsif Lead in 16#80# .. 16#BF# then
               --  Bare continuation byte used as lead — rule 1.
               return Fail (Invalid_Lead_Byte);

            else
               --  Lead >= F5: would imply 5-byte or longer sequence,
               --  outside RFC 3629 range — treat as invalid lead.
               return Fail (Invalid_Lead_Byte);
            end if;

            --  For multi-byte sequences, check continuation bytes.
            for J in 2 .. Seq_Length loop
               declare
                  Pos : constant Positive := I + J - 1;
               begin
                  --  Check that the continuation byte is within the input.
                  if Pos > Source'Last then
                     return Fail (Truncated_Sequence);
                  end if;

                  declare
                     Cont : constant Natural := B (Pos);
                  begin
                     --  Every continuation byte must be 10xxxxxx.
                     if Cont not in 16#80# .. 16#BF# then
                        return Fail (Invalid_Continuation);
                     end if;
                     Code_Point := Code_Point * 64 + Low_6 (Cont);
                  end;
               end;
            end loop;

            --  Overlong encoding checks (rule 4).
            --  A 2-byte sequence must encode >= U+0080.
            --  A 3-byte sequence must encode >= U+0800.
            --  A 4-byte sequence must encode >= U+10000.
            if Seq_Length = 2 and then Code_Point < 16#0080# then
               return Fail (Overlong_Encoding);
            elsif Seq_Length = 3 and then Code_Point < 16#0800# then
               return Fail (Overlong_Encoding);
            elsif Seq_Length = 4 and then Code_Point < 16#10000# then
               return Fail (Overlong_Encoding);
            end if;

            --  Surrogate range check (rule 5): U+D800..U+DFFF.
            if Code_Point in 16#D800# .. 16#DFFF# then
               return Fail (Surrogate_Code_Point);
            end if;

            --  Out-of-range check (rule 6): scalar > U+10FFFF.
            if Code_Point > 16#10FFFF# then
               return Fail (Code_Point_Out_Of_Range);
            end if;

            I := I + Seq_Length;
         end;

         exit when I > Source'Last;
      end loop;

      return Ok;
   end Validate;

end Anystrings_UTF_8_Validate;
