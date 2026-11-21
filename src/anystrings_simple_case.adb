-------------------------------------------------------------------------------
--  Anystrings_Simple_Case - Unicode simple lower-case mapping of one scalar
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with VSS.Characters;

package body Anystrings_Simple_Case is

   function Lower (C : Wide_Wide_Character) return Wide_Wide_Character is
      Surrogate_First : constant Natural := 16#D800#;
      Surrogate_Last  : constant Natural := 16#DFFF#;
      Max_Scalar      : constant Natural := 16#10_FFFF#;
      CP              : constant Natural := Wide_Wide_Character'Pos (C);
   begin
      if CP in Surrogate_First .. Surrogate_Last or else CP > Max_Scalar then
         return C;
      end if;

      declare
         Mapped : constant VSS.Characters.Virtual_Character :=
           VSS.Characters.Get_Simple_Lowercase_Mapping
             (VSS.Characters.Virtual_Character'Val (CP));
      begin
         return Wide_Wide_Character'Val (VSS.Characters.Virtual_Character'Pos (Mapped));
      end;
   end Lower;

end Anystrings_Simple_Case;
