-------------------------------------------------------------------------------
--  Proof client - length contracts of String_Types (SPARK)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Proof-only SPARK client. Each procedure states a length fact a client
--  relies on and checks it with pragma Assert. Nothing here is executed.
--
--  @description
--  The operands are bounded so that the non-overflow preconditions of "&"
--  and Append hold. The proofs use only the contracts declared on
--  String_Types, never the bodies.

with String_Types; use String_Types;

package Length_Client
  with SPARK_Mode
is

   --  Length (Empty_String) = 0 and Is_Empty (Empty_String).
   procedure Empty_Has_Zero_Length
   with Global => null;

   --  Length (A & B) = Length (A) + Length (B) for bounded operands.
   procedure Concat_Adds_Lengths (A, B : String_Type)
   with Global => null, Pre => Length (A) <= 1_000 and then Length (B) <= 1_000;

   --  Append grows Source by Length (New_Item).
   procedure Append_Adds_Length (Source : in out String_Type; New_Item : String_Type)
   with Global => null, Pre => Length (Source) <= 1_000 and then Length (New_Item) <= 1_000;

   --  Slice length for any valid range, and the full range keeps Length.
   procedure Slice_Lengths (Source : String_Type; Low : Positive; High : Natural)
   with Global => null, Pre => Low - 1 <= Length (Source) and then High <= Length (Source);

   --  Length (To_String_Type ("; ")) = 2 on every backend.
   procedure Literal_Length
   with Global => null;

end Length_Client;
