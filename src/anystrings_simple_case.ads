-------------------------------------------------------------------------------
--  Anystrings_Simple_Case - Unicode case mapping of scalar values and runs
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Case mapping shared by the backends, on top of the generated UCD tables.
--
--  @description
--  Lower maps one scalar value with the simple lower-case mapping (used by
--  Simple_To_Lower on every backend). Full_Map maps a run of scalar values
--  with the full mapping and the Final_Sigma rule (used by standard To_Lower
--  and To_Upper). The data is Anystrings_UCD_Case, generated from UCD 15.1.0
--  by tools/ucd, so this unit has no dependency outside the crate.
--  Not SPARK: Full_Map returns an unconstrained string. The lookups it calls
--  are in the SPARK-On Anystrings_UCD_Case.

pragma SPARK_Mode (Off);

package Anystrings_Simple_Case is

   --  Simple lower-case form of C. Surrogates and values above U+10FFFF are
   --  returned unchanged.
   function Lower (C : Wide_Wide_Character) return Wide_Wide_Character;

   --  Full case mapping of Run, one code point at a time. Upper selects the
   --  upper-case mapping; otherwise the lower-case mapping, with the
   --  Final_Sigma rule decided from the context inside Run. Run must hold
   --  scalar values only. The result may be longer than Run (for example
   --  U+0130 lower-cases to U+0069 U+0307, and U+00DF upper-cases to "SS").
   function Full_Map (Run : Wide_Wide_String; Upper : Boolean) return Wide_Wide_String;

end Anystrings_Simple_Case;
