-------------------------------------------------------------------------------
--  Anystrings Tests - UTF-8 Get_Value_Or Accessor Test Suite Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  Package: UTF8_Get_Value_Or_Test
--
--  Purpose: Verify the Get_Value_Or fallback accessor on UTF_8_Decode_Result.
--
--  Responsibilities:
--    * Check that Get_Value_Or returns the decoded value on success.
--    * Check that Get_Value_Or returns Fallback unchanged on failure.
--    * Check that Get_Value_Or is callable without an Is_Ok guard.
--
--  Requirements Coverage: FUNC-UTF8-002, FUNC-UTF8-014, NFR-UTF8-002
--
--  External Effects: None
--  Thread Safety: N/A
--  SPARK Status: Not Applicable (test code)

with AUnit.Test_Cases;

--  @relation FUNC-UTF8-014
package UTF8_Get_Value_Or_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   --  Success case: Get_Value_Or returns the decoded value when Is_Ok (R).
   --  @relation FUNC-UTF8-002, FUNC-UTF8-014
   procedure Test_Get_Value_Or_Returns_Value_On_Success
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  Failure case: Get_Value_Or returns Fallback unchanged when not Is_Ok (R).
   --  @relation FUNC-UTF8-014
   procedure Test_Get_Value_Or_Returns_Fallback_On_Failure
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  Fallback identity: distinct fallback values are preserved verbatim.
   --  @relation FUNC-UTF8-014
   procedure Test_Get_Value_Or_Fallback_Value_Is_Preserved_Exactly
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  Guard-free usage: Get_Value_Or is callable without a prior Is_Ok check.
   --  @relation FUNC-UTF8-014
   procedure Test_Get_Value_Or_Usable_Without_Is_Ok_Guard
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  Success semantics: result equals Get_Value (R) when Is_Ok (R) is True.
   --  @relation FUNC-UTF8-002, FUNC-UTF8-014
   procedure Test_Get_Value_Or_Result_Equals_Get_Value_On_Success
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end UTF8_Get_Value_Or_Test;
