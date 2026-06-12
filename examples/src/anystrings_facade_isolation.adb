--  Anystrings_Facade_Isolation - dependency-isolation witness program
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
--
--  @summary
--  Minimal program whose context clause is `with String_Types;` only.
--
--  @description
--  This program does no useful work. Its sole purpose is to act as a
--  build-time witness for FUNC-FACADE-004: after the facade split, a
--  consumer that pulls in only `String_Types` MUST NOT acquire
--  `Ada.Command_Line` in its semantic dependence closure.
--
--  The accompanying check in examples/run_all_backends_demo.sh inspects
--  the generated .ali file for this main and asserts the absence of any
--  `Ada.Command_Line` reference.
--
--  @relation FUNC-FACADE-001, FUNC-FACADE-004

with String_Types;

procedure Anystrings_Facade_Isolation is
   Dummy : String_Types.String_Type := String_Types.Empty_String;
   pragma Unreferenced (Dummy);
begin
   null;
end Anystrings_Facade_Isolation;
