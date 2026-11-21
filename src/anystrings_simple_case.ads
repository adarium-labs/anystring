-------------------------------------------------------------------------------
--  Anystrings_Simple_Case - Unicode simple lower-case mapping of one scalar
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Simple (one-to-one) lower-case mapping of a single Unicode scalar value.
--
--  @description
--  Every backend uses this one unit for Simple_To_Lower, so all five apply the
--  same mapping. The data is the Simple_Lowercase_Mapping property of the
--  Unicode Character Database, read through VSS.Characters. The GNAT tables
--  behind Ada.Wide_Wide_Characters.Handling.To_Lower do not give it for every
--  code point (U+0130 and U+1E9E among them), so they are not used here.
--  Surrogates and values above U+10FFFF are returned unchanged.
--  Not SPARK: the body calls VSS.

pragma SPARK_Mode (Off);

package Anystrings_Simple_Case is

   --  Simple lower-case form of C (Unicode Simple_Lowercase_Mapping).
   function Lower (C : Wide_Wide_Character) return Wide_Wide_Character;

end Anystrings_Simple_Case;
