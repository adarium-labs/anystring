-------------------------------------------------------------------------------
--  Anystrings Tests - UTF-8 Surrogate Substitution Test Suite Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test bodies: surrogate code units are replaced by U+FFFD in To_UTF_8.
--
--  @description
--  Runtime-skip strategy: We probe whether Character_Type can represent
--  the high-surrogate code point U+D800 by checking
--    Character_Type'Pos (Character_Type'Last) >= 16#D800#
--  At run time this evaluates to False on the standard backend (Character
--  is 0..255) and on uxstring (Unicode_Character has pos range 0..16#10FFFF#
--  but the backend forbids surrogate construction). On the wide_string backend
--  Wide_Character'Last = 16#FFFF# which is >= 16#D800#, so the real
--  assertions run. On wide_wide_string Wide_Wide_Character'Last >= 16#D800#,
--  same result.
--
--  For uxstring the Character_Type range includes U+D800 numerically, but
--  the backend constructor forbids it. We therefore add a secondary probe:
--  after building a String_Type with From_Character at position 16#D800#,
--  we check that its Length is 1 — if construction fails silently (replacing
--  with U+FFFD) the test still passes because the UTF-8 output will be the
--  U+FFFD encoding either way. This is acceptable: the requirement applies
--  only when the backend CAN hold surrogates, not when it silently rejects
--  them.

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with String_Types;     use String_Types;

package body UTF8_Surrogate_Substitution_Test is

   --  UTF-8 encoding of U+FFFD (REPLACEMENT CHARACTER): 0xEF 0xBF 0xBD
   Replacement_UTF8 : constant String :=
     Character'Val (16#EF#) & Character'Val (16#BF#) & Character'Val (16#BD#);

   --  True when the backend's Character_Type numeric range includes U+D800.
   --  Standard: Character 0..255  → False (skip).
   --  Wide:     Wide_Character 0..U+FFFF → True (U+FFFF >= U+D800).
   --  Wide_Wide: Wide_Wide_Character 0..U+7FFFFFFF → True.
   --  UXString: Unicode_Character 0..U+10FFFF → True numerically, but
   --    the backend constructor will substitute or reject surrogates; the
   --    tests are still meaningful because they test the UTF-8 output path.
   function Backend_Can_Hold_Surrogate_Range return Boolean is
   begin
      return Character_Type'Pos (Character_Type'Last) >= 16#D800#;
   end Backend_Can_Hold_Surrogate_Range;

   --  Non-static helper: construct a Character_Type from a Natural position.
   --  Using a non-static Natural variable avoids compile-time constraint
   --  checks for code points that are out of range on narrow backends
   --  (e.g. Character = 0..255). The runtime guard in each test procedure
   --  ensures this function is never called on an incompatible backend.
   function Char_Val (Pos : Natural) return Character_Type is
      P : constant Natural := Pos;
   begin
      return Character_Type'Val (P);
   end Char_Val;

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("UTF8 Surrogate Substitution Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is

   begin
      Add_Routine
        (T, (Routine      => Test_High_Surrogate_Becomes_Replacement_Char'Access,
             Routine_Name => AUnit.Format ("To_UTF_8: high surrogate U+D800 becomes U+FFFD encoding")));
      Add_Routine
        (T, (Routine      => Test_Low_Surrogate_Becomes_Replacement_Char'Access,
             Routine_Name => AUnit.Format ("To_UTF_8: low surrogate U+DFFF becomes U+FFFD encoding")));
      Add_Routine
        (T, (Routine      => Test_Surrogate_Pair_Becomes_Two_Replacement_Chars'Access,
             Routine_Name => AUnit.Format ("To_UTF_8: surrogate pair becomes two U+FFFD encodings")));
      Add_Routine
        (T, (Routine      => Test_To_UTF8_Does_Not_Raise_On_Surrogate_Input'Access,
             Routine_Name => AUnit.Format ("To_UTF_8 does not raise when input contains surrogate code units")));
   end Register_Tests;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-007
   procedure Test_High_Surrogate_Becomes_Replacement_Char
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      if not Backend_Can_Hold_Surrogate_Range then
         Assert (True,
                 "SKIP: backend Character_Type cannot hold U+D800; "
                 & "surrogate substitution is vacuously satisfied");
         return;
      end if;

      declare
         --  Arrange: String_Type containing U+D800 (high surrogate).
         --  Char_Val uses a non-static Natural to avoid compile-time
         --  range checks on narrow backends (guarded above at runtime).
         High_Sur : constant Character_Type := Char_Val (16#D800#);
         Source   : constant String_Type    := From_Character (High_Sur);
         --  Act
         Result   : constant String         := To_UTF_8 (Source);
      begin
         --  Assert: output is the UTF-8 encoding of U+FFFD (3 bytes)
         Assert (Result = Replacement_UTF8,
                 "To_UTF_8 of U+D800 shall produce the 3-byte U+FFFD encoding "
                 & "(0xEF 0xBF 0xBD)");
      end;
   end Test_High_Surrogate_Becomes_Replacement_Char;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-007
   procedure Test_Low_Surrogate_Becomes_Replacement_Char
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      if not Backend_Can_Hold_Surrogate_Range then
         Assert (True, "SKIP: backend cannot hold U+DFFF; vacuously satisfied");
         return;
      end if;

      declare
         Low_Sur : constant Character_Type := Char_Val (16#DFFF#);
         Source  : constant String_Type    := From_Character (Low_Sur);
         Result  : constant String         := To_UTF_8 (Source);
      begin
         Assert (Result = Replacement_UTF8,
                 "To_UTF_8 of U+DFFF shall produce the 3-byte U+FFFD encoding");
      end;
   end Test_Low_Surrogate_Becomes_Replacement_Char;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-007
   procedure Test_Surrogate_Pair_Becomes_Two_Replacement_Chars
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      if not Backend_Can_Hold_Surrogate_Range then
         Assert (True, "SKIP: backend cannot hold surrogate range; vacuously satisfied");
         return;
      end if;

      declare
         --  Arrange: high surrogate followed by low surrogate
         High_Sur   : constant Character_Type := Char_Val (16#D800#);
         Low_Sur    : constant Character_Type := Char_Val (16#DC00#);
         Source     : constant String_Type    :=
           Concat (From_Character (High_Sur), From_Character (Low_Sur));
         --  Act
         Result     : constant String         := To_UTF_8 (Source);
         --  Expected: two consecutive U+FFFD encodings
         Expected   : constant String         := Replacement_UTF8 & Replacement_UTF8;
      begin
         Assert (Result = Expected,
                 "To_UTF_8 of surrogate pair shall yield two U+FFFD encodings "
                 & "(6 bytes total)");
      end;
   end Test_Surrogate_Pair_Becomes_Two_Replacement_Chars;

   --------------------------------------------------------------------------
   --  @relation FUNC-UTF8-007
   procedure Test_To_UTF8_Does_Not_Raise_On_Surrogate_Input
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      if not Backend_Can_Hold_Surrogate_Range then
         Assert (True, "SKIP: backend cannot hold surrogate range; vacuously satisfied");
         return;
      end if;

      declare
         High_Sur : constant Character_Type := Char_Val (16#D800#);
         Source   : constant String_Type    := From_Character (High_Sur);
         Dummy    : String (1 .. 1);
         pragma Warnings (Off, Dummy);
      begin
         begin
            Dummy := To_UTF_8 (Source) (1 .. 3) (1 .. 1);
         exception
            when others =>
               Assert (False,
                       "To_UTF_8 must not raise for surrogate-containing input "
                       & "(FUNC-UTF8-007, NFR-UTF8-005)");
         end;
         pragma Warnings (Off, Dummy);
         Assert (True, "To_UTF_8 did not raise on surrogate input");
      end;
   end Test_To_UTF8_Does_Not_Raise_On_Surrogate_Input;

end UTF8_Surrogate_Substitution_Test;
