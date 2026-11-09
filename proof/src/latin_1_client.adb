-------------------------------------------------------------------------------
--  Proof client - Latin-1 egress length (SPARK)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

package body Latin_1_Client
  with SPARK_Mode
is

   procedure Egress_Keeps_Length (Source : String_Type) is
      L : constant String := To_Latin_1 (Source);
   begin
      pragma Assert (L'First = 1);
      pragma Assert (L'Length = Length (Source));
   end Egress_Keeps_Length;

end Latin_1_Client;
