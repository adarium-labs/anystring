-------------------------------------------------------------------------------
--  Anystrings Tests - UTF-8 Non-Raising Property Test Suite Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test suite: From_UTF_8 never raises for any adversarial input.
--
--  @description
--  Sweeps:
--    1. Every singleton byte 0..255 — none may cause From_UTF_8 to raise.
--    2. Two-byte combinations for a representative set of lead bytes
--       (0x80, 0xC0, 0xC1, 0xC2, 0xE0, 0xED, 0xF0, 0xF4, 0xF5) each
--       followed by second bytes 0x00, 0x40, 0x80, 0xBF, 0xC0.
--
--  Each call is wrapped in a begin/exception block; any exception escaping
--  From_UTF_8 is caught and reported as a test failure.
--
--  Requirements Coverage: NFR-UTF8-005, NFR-UTF8-008
--
--  External Effects: None
--  Thread Safety: N/A
--  SPARK Status: Not Applicable (test code)

with AUnit.Test_Cases;

--  @relation NFR-UTF8-005
package UTF8_Non_Raising_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   --  @relation NFR-UTF8-005, NFR-UTF8-008
   procedure Test_No_Exception_On_All_Singleton_Bytes
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation NFR-UTF8-005, NFR-UTF8-008
   procedure Test_No_Exception_On_Two_Byte_Adversarial_Inputs
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end UTF8_Non_Raising_Test;
