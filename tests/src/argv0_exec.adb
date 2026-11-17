-------------------------------------------------------------------------------
--  Argv0_Exec - test-only launcher with a chosen argv[0] (KI-046 L1)
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Replaces this process with <program> through the POSIX execv call, passing
--  <argv0> verbatim as the new process's argv[0] and the remaining arguments
--  as argv[1..]. Usage: argv0_exec <program> <argv0> [<arg> ...].
--
--  @description
--  GNAT.OS_Lib.Spawn cannot do this: it sets argv[0] to the program path.
--  execv is available on Linux and macOS.

with Ada.Command_Line;
with Ada.Text_IO;
with Interfaces.C;
with Interfaces.C.Strings;
with System;

procedure Argv0_Exec is

   use Interfaces.C;
   use Interfaces.C.Strings;

   type Chars_Array is array (Natural range <>) of aliased chars_ptr;

   function Execv (Path : chars_ptr; Argv : System.Address) return int
     with Import, Convention => C, External_Name => "execv";

   N : constant Natural := Ada.Command_Line.Argument_Count;
begin
   if N < 2 then
      Ada.Text_IO.Put_Line ("usage: argv0_exec <program> <argv0> [<arg> ...]");
      Ada.Command_Line.Set_Exit_Status (2);
      return;
   end if;

   declare
      --  argv[0..N-2] are the arguments 2..N; the last entry is the NULL
      --  terminator required by execv.
      Argv : Chars_Array (0 .. N - 1);
      Path : constant chars_ptr := New_String (Ada.Command_Line.Argument (1));
      Result : int;
   begin
      for I in 0 .. N - 2 loop
         Argv (I) := New_String (Ada.Command_Line.Argument (I + 2));
      end loop;
      Argv (N - 1) := Null_Ptr;

      Result := Execv (Path, Argv (0)'Address);
      --  Only reached when execv fails.
      Ada.Text_IO.Put_Line ("argv0_exec: execv failed: " & int'Image (Result));
      Ada.Command_Line.Set_Exit_Status (127);
   end;
end Argv0_Exec;
