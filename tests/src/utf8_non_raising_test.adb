-------------------------------------------------------------------------------
--  Anystrings Tests - UTF-8 Non-Raising Test Suite Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  AUnit test bodies: From_UTF_8 must not raise for ANY byte sequence.

with Ada.Exceptions;
with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with String_Types;     use String_Types;

package body UTF8_Non_Raising_Test is

   overriding function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("UTF8 Non-Raising Property Tests");
   end Name;

   overriding procedure Register_Tests (T : in out Test_Case) is

   begin
      Add_Routine
        (T, (Routine      => Test_No_Exception_On_All_Singleton_Bytes'Access,
             Routine_Name => AUnit.Format ("From_UTF_8 does not raise for any singleton byte 0..255")));
      Add_Routine
        (T, (Routine      => Test_No_Exception_On_Two_Byte_Adversarial_Inputs'Access,
             Routine_Name => AUnit.Format ("From_UTF_8 does not raise for adversarial two-byte inputs")));
   end Register_Tests;

   --------------------------------------------------------------------------
   --  Internal helper: call From_UTF_8 and report any exception as failure.
   procedure Assert_No_Exception (Input : String; Label : String) is
      Dummy : UTF_8_Decode_Result;
      pragma Warnings (Off, Dummy);
   begin
      begin
         Dummy := From_UTF_8 (Input);
      exception
         when E : others =>
            Assert (False,
                    "From_UTF_8 raised an exception for " & Label & ": "
                    & Ada.Exceptions.Exception_Name (E));
      end;
   end Assert_No_Exception;

   --------------------------------------------------------------------------
   --  @relation NFR-UTF8-005, NFR-UTF8-008
   procedure Test_No_Exception_On_All_Singleton_Bytes
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      for Byte_Val in 0 .. 255 loop
         declare
            Input : constant String := (1 => Character'Val (Byte_Val));
         begin
            Assert_No_Exception
              (Input, "singleton byte 0x" & Byte_Val'Image);
         end;
      end loop;
      Assert (True, "All 256 singleton bytes processed without exception");
   end Test_No_Exception_On_All_Singleton_Bytes;

   --------------------------------------------------------------------------
   --  @relation NFR-UTF8-005, NFR-UTF8-008
   procedure Test_No_Exception_On_Two_Byte_Adversarial_Inputs
     (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      --  Lead bytes representative of interesting boundary conditions:
      --  0x80 (bare continuation), 0xC0/0xC1 (overlong leads),
      --  0xC2 (first valid 2-byte lead), 0xE0 (3-byte lead),
      --  0xED (surrogate-range lead), 0xF0 (4-byte lead),
      --  0xF4 (near-boundary 4-byte lead), 0xF5 (invalid 4-byte lead)
      subtype Lead_Index is Positive range 1 .. 9;
      Lead_Bytes : constant array (Lead_Index) of Natural :=
        (16#80#, 16#C0#, 16#C1#, 16#C2#, 16#E0#,
         16#ED#, 16#F0#, 16#F4#, 16#F5#);

      subtype Second_Index is Positive range 1 .. 5;
      Second_Bytes : constant array (Second_Index) of Natural :=
        (16#00#, 16#40#, 16#80#, 16#BF#, 16#C0#);
   begin
      for L in Lead_Index loop
         for S in Second_Index loop
            declare
               Input : constant String :=
                 Character'Val (Lead_Bytes (L)) & Character'Val (Second_Bytes (S));
            begin
               Assert_No_Exception
                 (Input,
                  "two-byte 0x" & Lead_Bytes (L)'Image
                  & " 0x" & Second_Bytes (S)'Image);
            end;
         end loop;
      end loop;
      Assert (True,
              "All representative two-byte adversarial inputs processed without exception");
   end Test_No_Exception_On_Two_Byte_Adversarial_Inputs;

end UTF8_Non_Raising_Test;
