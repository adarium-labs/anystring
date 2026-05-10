-------------------------------------------------------------------------------
--  Anystrings Tests - UTF-8 Error Mapping Test Suite Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test suite: canonical invalid UTF-8 sequences map to correct errors.
--
--  @description
--  For each UTF_8_Decode_Error variant (FUNC-UTF8-001), supplies one
--  canonical byte sequence and asserts:
--    Is_Ok (From_UTF_8 (seq)) = False
--    Get_Error (From_UTF_8 (seq)) = <expected variant>
--
--  Canonical sequences per tech-spec §10 #6:
--    Invalid_Lead_Byte      : Character'Val (16#80#)
--    Truncated_Sequence     : Character'Val (16#C3#) alone
--    Invalid_Continuation   : Character'Val (16#C3#) & Character'Val (16#28#)
--    Overlong_Encoding      : Character'Val (16#C0#) & Character'Val (16#AF#)
--    Surrogate_Code_Point   : 16#ED# 16#A0# 16#80# (U+D800)
--    Code_Point_Out_Of_Range: 16#F4# 16#90# 16#80# 16#80# (U+110000)
--
--  Requirements Coverage: FUNC-UTF8-010, NFR-UTF8-008
--
--  External Effects: None
--  Thread Safety: N/A
--  SPARK Status: Not Applicable (test code)

with AUnit.Test_Cases;

--  @relation FUNC-UTF8-010
package UTF8_Error_Mapping_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   --  @relation FUNC-UTF8-010
   procedure Test_Bare_Continuation_Byte_Is_Invalid_Lead_Byte
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-010
   procedure Test_Lone_Lead_Byte_Is_Truncated_Sequence
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-010
   procedure Test_Lead_Plus_ASCII_Is_Invalid_Continuation
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-010
   procedure Test_Overlong_Sequence_Is_Overlong_Encoding
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-010
   procedure Test_Surrogate_UTF8_Is_Surrogate_Code_Point
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  @relation FUNC-UTF8-010
   procedure Test_Beyond_Unicode_Is_Code_Point_Out_Of_Range
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end UTF8_Error_Mapping_Test;
