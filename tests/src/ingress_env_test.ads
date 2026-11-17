-------------------------------------------------------------------------------
--  Anystrings Tests - Ingress Environment Child-Process Test Suite Spec
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test suite: malformed environment NAMES and VALUES, read by a child
--  process (ingress_probe, no arguments) whose environment the parent sets
--  for each Table I row. Each child reads the variable through Get_Env and
--  through both Iterate_Env overloads, and the output is compared with the
--  Table I code points.
--
--  @description
--  Two cases per row, each in its own child:
--    value case: ANYSTRING_P3_V = <row bytes>. Get_Env of ANYSTRING_P3_V must
--                give the decoded value; both Iterate_Env overloads must give
--                the variable name "ANYSTRING_P3_V" and the decoded value.
--    name case:  ANYSTRING_P3_<row bytes> = <row bytes>. Both Iterate_Env
--                overloads must give the decoded name and value. Get_Env of
--                ANYSTRING_P3_V is absent in this child.
--  The parent clears each variable right after its child has run, so every
--  child sees only the variables of its own case.
--
--  Requirements Coverage: FUNC-UTF8-007, FUNC-UTF8-010, NFR-UTF8-004
--
--  SPARK Status: Not Applicable (test code)

with AUnit.Test_Cases;

package Ingress_Env_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   --  @relation FUNC-UTF8-007, NFR-UTF8-004
   procedure Test_Env_Children_Through_Get_Env_And_Iterate_Env
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end Ingress_Env_Test;
