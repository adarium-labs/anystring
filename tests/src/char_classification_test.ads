-------------------------------------------------------------------------------
--  Anystrings Tests - Character Classification Test Suite Spec
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test suite: character classification & case mapping primitives.
--
--  @description
--  Validates the 12 character-level operations exposed through every
--  backend (Is_Alphanumeric, Is_Control, Is_Digit, Is_Graphic,
--  Is_Hex_Digit, Is_Letter, Is_Line_Terminator, Is_Lower, Is_Upper,
--  Is_Whitespace, To_Lower, To_Upper). All tests are written against the
--  String_Types facade so they exercise the active backend.
--
--  Coverage strategy: ASCII tests run on every backend; Latin-1
--  supplement tests (U+00E9 etc.) run on every backend since every
--  Character_Type spans at least 0..255; Unicode-only tests (Arabic-Indic
--  digits, Greek capital case mapping above U+00FF) are gated by
--  Character_Type'Last so they're statically skipped on the standard
--  backend.

with AUnit.Test_Cases;

package Char_Classification_Test is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding function Name (T : Test_Case) return AUnit.Message_String;

   overriding procedure Register_Tests (T : in out Test_Case);

private

   procedure Test_ASCII_Digits
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_ASCII_Letters
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_ASCII_Alphanumeric
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_ASCII_Hex_Digits
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_ASCII_Case
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_ASCII_Control_And_Graphic
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_ASCII_Whitespace
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_ASCII_Line_Terminator
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_ASCII_Case_Round_Trip
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Latin_1_Supplement_Letter
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Latin_1_Supplement_Case
     (T : in out AUnit.Test_Cases.Test_Case'Class);

   procedure Test_Unicode_Beyond_Latin_1
     (T : in out AUnit.Test_Cases.Test_Case'Class);

end Char_Classification_Test;
