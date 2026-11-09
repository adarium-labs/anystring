-------------------------------------------------------------------------------
--  Proof client - Latin-1 egress length (SPARK)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Proof-only SPARK client of To_Latin_1's length contract. Built only on
--  the backends that carry that contract (see prove_client.gpr).

with String_Types; use String_Types;

package Latin_1_Client
  with SPARK_Mode
is

   --  To_Latin_1 keeps one unit per code point and starts at 1.
   procedure Egress_Keeps_Length (Source : String_Type)
   with Global => null;

end Latin_1_Client;
