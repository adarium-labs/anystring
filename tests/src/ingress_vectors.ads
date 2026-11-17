-------------------------------------------------------------------------------
--  Ingress_Vectors - KI-046 Table I (ingress vectors) and formatting helpers
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Test-only data shared by the ingress test suites and the probe program:
--  the Table I byte rows, their decoded code points, and the expected Length
--  on each backend class.
--
--  @description
--  Byte rows and code points are written as hexadecimal tokens separated by
--  single spaces ("C3 A9", "E9 20AC 1F600"); the empty row is "". Backend
--  classes for Length: 1 = standard (bytes), 2 = wide_string (UTF-16 units),
--  3 = wide_wide_string, uxstring and vss (code points).

package Ingress_Vectors is

   --  Visits one Table I row. Valid is True when the row is well-formed UTF-8
   --  (the checked From_UTF_8 must then return Ok).
   type Visitor is access procedure
     (Id        : String;
      Input_Hex : String;
      Cps_Hex   : String;
      Valid     : Boolean;
      CPL       : Natural;
      Len_Std   : Natural;
      Len_Wide  : Natural;
      Len_Other : Natural);

   --  Calls Visit for every Table I row (I01 .. I23), in order.
   procedure For_Each_Row (Visit : not null Visitor);

   --  Bytes of a hexadecimal token list ("" gives the empty string).
   function Bytes (Hex : String) return String;

   --  Code points of a hexadecimal token list ("" gives the empty string).
   function Code_Points (Hex : String) return Wide_Wide_String;

   --  Space-separated uppercase hexadecimal code points, "-" when empty.
   function Hex_Image (S : Wide_Wide_String) return String;

   --  Backend class of the build: 1 standard, 2 wide_string, 3 otherwise.
   --  Measured through the facade: a 4-byte UTF-8 sequence has Length 4 on
   --  standard, 2 on wide_string and 1 elsewhere.
   function Backend_Class return Positive;

   --  The expected Length of a value on the running backend.
   function Expected_Length (Len_Std, Len_Wide, Len_Other : Natural) return Natural;

end Ingress_Vectors;
