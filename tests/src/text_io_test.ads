--  Anystrings Tests - Text_IO Bridge Encoding Test Suite Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

--  @summary
--  AUnit test suite: String_Types.Text_IO writes and reads UTF-8 on every
--  backend.

--  @description
--  Backend-agnostic: the same source compiles for all five backends. The
--  wide_string and wide_wide_string bridges used to write through
--  Ada.Wide[_Wide]_Text_IO with GNAT's default (brackets / Latin-1)
--  encoding, so non-ASCII text left the process mis-encoded unless the main
--  program was compiled with -gnatW8.
--
--  SPARK Status: Not Applicable (test code).

with AUnit.Test_Cases;

package Text_IO_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding
   function Name (T : Test_Case) return AUnit.Message_String;

   overriding
   procedure Register_Tests (T : in out Test_Case);

private

   --  Put_Line of "é→" writes the UTF-8 bytes C3 A9 E2 86 92 then LF.
   --  @relation FUNC-FACADE-009
   procedure Test_Put_Line_Writes_UTF_8 (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  Put_Line then Get_Line returns the same code points.
   --  @relation FUNC-FACADE-009
   procedure Test_Round_Trip_Non_ASCII (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  Get_Line on a line that is not valid UTF-8 does not raise.
   --  @relation FUNC-FACADE-009
   procedure Test_Get_Line_Invalid_UTF_8_Is_Total (T : in out AUnit.Test_Cases.Test_Case'Class);

   --  Put_Line writes the same UTF-8 bytes whatever the file's wide-character
   --  encoding method: a file opened with WCEM=8 (what -gnatW8 on the main
   --  program gives every file) must not encode the bytes a second time.
   --  @relation FUNC-FACADE-009
   procedure Test_Put_Line_Ignores_File_WCEM (T : in out AUnit.Test_Cases.Test_Case'Class);

end Text_IO_Test;
