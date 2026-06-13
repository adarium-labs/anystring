--  Width_Tests_Registry — Enabled body (ANYSTRING_WITH_WIDTH=true)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

with Width_Core_Test;
with Width_Clusters_Test;
with Width_Helpers_Test;
with Width_Config_Test;
with Width_Parity_Test;

package body Width_Tests_Registry is

   procedure Add_To_Suite (S : AUnit.Test_Suites.Access_Test_Suite) is
   begin
      S.Add_Test (new Width_Core_Test.Test_Case);
      S.Add_Test (new Width_Clusters_Test.Test_Case);
      S.Add_Test (new Width_Helpers_Test.Test_Case);
      S.Add_Test (new Width_Config_Test.Test_Case);
      S.Add_Test (new Width_Parity_Test.Test_Case);
   end Add_To_Suite;

end Width_Tests_Registry;
