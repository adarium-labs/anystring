-------------------------------------------------------------------------------
--  Ingress_Env_Probe - environment part of the ingress probe (KI-046 fix round 1)
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Test-only. Run is called by ingress_probe when it is started without
--  arguments. It prints, through the facade of the running back end:
--    GET <value code points> present|absent   Get_Env of ANYSTRING_P3_V
--    ITER1 <name code points> <value code points>
--                                             Iterate_Env (Process), for each
--                                             variable whose name starts with
--                                             ANYSTRING_P3_
--    ITER2 <name code points> <value code points>
--                                             the same through
--                                             Iterate_Env (Include, Process)
--  Code points are Ingress_Vectors.Hex_Image form ("-" when empty).

package Ingress_Env_Probe is

   procedure Run;

end Ingress_Env_Probe;
