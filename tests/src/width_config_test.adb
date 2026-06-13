--  Width_Config_Test — Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

with AUnit.Assertions;   use AUnit.Assertions;
with AUnit.Test_Cases;   use AUnit.Test_Cases;
with String_Types;       use String_Types;
with String_Types.Width; use String_Types.Width;

package body Width_Config_Test is

   --  ---- corpus helpers ----

   --  "hello" — Display_Width 5 under any sane configuration
   Hello_Bytes : constant String := "hello";

   --  "日本語" — Display_Width 6; CJK fullwidth in both Narrow and Wide contexts
   Nihongo_Bytes : constant String :=
     Character'Val (16#E6#) & Character'Val (16#97#) & Character'Val (16#A5#) &
     Character'Val (16#E6#) & Character'Val (16#9C#) & Character'Val (16#AC#) &
     Character'Val (16#E8#) & Character'Val (16#AA#) & Character'Val (16#9E#);

   function Mk (S : String) return String_Type is
   begin
      return Get_Value_Or (From_UTF_8 (S), Empty_String);
   end Mk;

   --  ---- Name / Register ----

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Width Configuration Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine (T,
         (Routine      => Test_Default_Linux_Gives_Correct_ASCII_Width'Access,
          Routine_Name => AUnit.Format ("Default_Linux: ASCII hello has width 5")));
      Add_Routine (T,
         (Routine      => Test_Default_Linux_Is_Default_Conf_Argument'Access,
          Routine_Name => AUnit.Format ("Default_Linux: is the default Conf parameter")));
      Add_Routine (T,
         (Routine      => Test_Default_Strict_Gives_Same_Width_On_Valid_Input'Access,
          Routine_Name => AUnit.Format ("Default_Strict: same result as Linux on valid input")));
      Add_Routine (T,
         (Routine      => Test_Narrow_Wide_Context_Constants_Are_Accessible'Access,
          Routine_Name => AUnit.Format ("Narrow/Wide: context literals accessible via use")));
      Add_Routine (T,
         (Routine      => Test_Best_Effort_Does_Not_Raise_On_Raw_Byte'Access,
          Routine_Name => AUnit.Format ("NFR-WIDTH-004: best-effort does not raise on raw byte")));
      Add_Routine (T,
         (Routine      => Test_Best_Effort_Single_Byte_Width_Is_One'Access,
          Routine_Name => AUnit.Format ("NFR-WIDTH-004: each non-ASCII raw byte counted width 1")));
   end Register_Tests;

   --  ---- FUNC-WIDTH-006 / NFR-WIDTH-003 ----

   --  NFR-WIDTH-003: Default_Linux matches Linux wcwidth — ASCII is 1 cell/char.
   procedure Test_Default_Linux_Gives_Correct_ASCII_Width
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S : constant String_Type := Mk (Hello_Bytes);
      W : constant Natural     := Display_Width (S, Default_Linux);
   begin
      Assert (W = 5,
              "Display_Width (hello, Default_Linux) must be 5");
      Assert (Grapheme_Count (S, Default_Linux) = 5,
              "Grapheme_Count (hello, Default_Linux) must be 5");
   end Test_Default_Linux_Gives_Correct_ASCII_Width;

   --  FUNC-WIDTH-003 / NFR-WIDTH-003: Default_Linux is the default Conf value.
   procedure Test_Default_Linux_Is_Default_Conf_Argument
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S : constant String_Type := Mk (Hello_Bytes);
   begin
      Assert (Display_Width (S) = Display_Width (S, Default_Linux),
              "Display_Width default argument must equal Default_Linux result");
      Assert (Grapheme_Count (S) = Grapheme_Count (S, Default_Linux),
              "Grapheme_Count default argument must equal Default_Linux result");
   end Test_Default_Linux_Is_Default_Conf_Argument;

   --  FUNC-WIDTH-006: Default_Strict is usable; valid input gives same width.
   procedure Test_Default_Strict_Gives_Same_Width_On_Valid_Input
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S       : constant String_Type := Mk (Hello_Bytes);
      W_Linux  : constant Natural    := Display_Width (S, Default_Linux);
      W_Strict : constant Natural    := Display_Width (S, Default_Strict);
   begin
      --  On valid ASCII input both configurations must agree.
      Assert (W_Linux = W_Strict,
              "Default_Linux and Default_Strict must agree on valid ASCII input");
      Assert (W_Strict = 5,
              "Display_Width (hello, Default_Strict) must be 5");
   end Test_Default_Strict_Gives_Same_Width_On_Valid_Input;

   --  FUNC-WIDTH-006: Narrow / Wide context literals are accessible after
   --  "use String_Types.Width" and can be used to construct Width_Configuration.
   procedure Test_Narrow_Wide_Context_Constants_Are_Accessible
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      S        : constant String_Type := Mk (Nihongo_Bytes);
      W_Narrow : constant Natural     := Display_Width (S, Default_Linux);
      --  Build a Strict configuration with Wide context — exercises all fields.
      Wide_Conf : constant Width_Configuration :=
        (Context                => Wide,
         Honor_Emoji_Selectors  => False,
         Honor_Emoji_Modifiers  => True,
         Reject_Illegal         => False);
      W_Wide : constant Natural := Display_Width (S, Wide_Conf);
   begin
      --  Both Narrow and Wide context must return >= 1 for CJK text.
      Assert (W_Narrow >= 1,
              "Display_Width CJK with Default_Linux (Narrow context) must be >= 1");
      Assert (W_Wide >= 1,
              "Display_Width CJK with Wide context must be >= 1");
      --  CJK fullwidth chars are Width=2 in both Narrow and Wide contexts
      --  per UAX #11; the aggregate above exercises the Width_Configuration record.
      Assert (W_Narrow = 6,
              "Display_Width (Nihongo, Default_Linux) expected 6 (3 fullwidth x 2 cells)");
   end Test_Narrow_Wide_Context_Constants_Are_Accessible;

   --  ---- NFR-WIDTH-004 ----

   --  NFR-WIDTH-004: Reject_Illegal = False → no exception on non-UTF-8 bytes.
   --  Using To_String_Type with a raw 0xFF byte — on the standard backend
   --  To_UTF_8 is byte-identity, so 0xFF reaches UMWI as an invalid lead byte.
   procedure Test_Best_Effort_Does_Not_Raise_On_Raw_Byte
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  0xFF is an invalid UTF-8 lead byte.
      Raw      : constant String_Type :=
        To_String_Type (String'(1 => Character'Val (16#FF#)));
      W        : Natural := 0;
   begin
      W := Display_Width (Raw, Default_Linux);
      Assert (W >= 1,
              "Best-effort Display_Width on 0xFF byte must not raise and return >= 1");
   end Test_Best_Effort_Does_Not_Raise_On_Raw_Byte;

   --  NFR-WIDTH-004: each raw non-ASCII byte is counted as a cluster of width 1.
   procedure Test_Best_Effort_Single_Byte_Width_Is_One
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Three raw bytes: "AB" (valid ASCII, width 2) plus one invalid byte 0xFE.
      --  Best-effort total must be 3 (2 ASCII + 1 for 0xFE).
      Mixed : constant String_Type :=
        To_String_Type ("AB" & Character'Val (16#FE#));
      W     : constant Natural := Display_Width (Mixed, Default_Linux);
   begin
      Assert (W = 3,
              "Best-effort Display_Width for ""AB"" + 0xFE must be 3 (2 ASCII + 1 raw)");
   end Test_Best_Effort_Single_Byte_Width_Is_One;

end Width_Config_Test;
