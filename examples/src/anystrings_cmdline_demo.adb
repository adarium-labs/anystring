--  @summary
--  Demonstrates the Ada.Command_Line bridge exposed through String_Types.
--
--  @description
--  A runnable example showing how application code reads the argument
--  vector, retrieves the command name, and sets the process exit status
--  entirely through the String_Types bridge — without ever importing
--  Ada.Command_Line directly.
--
--  Requirements covered:
--    FUNC-CMDLINE-001 — Argument_Count : Natural
--    FUNC-CMDLINE-002 — Argument (N) : String_Type
--    FUNC-CMDLINE-003 — out-of-range access raises Constraint_Error
--                        (tested in tests/; not demonstrated here)
--    FUNC-CMDLINE-004 — Command_Name : String_Type
--    FUNC-CMDLINE-005 — Exit_Status subtype + Success / Failure constants
--    FUNC-CMDLINE-006 — Set_Exit_Status (Exit_Status overload)
--    FUNC-CMDLINE-007 — Set_Exit_Status (Integer overload)
--    FUNC-CMDLINE-008 — argv conversion uses the backend's To_String_Type path
--    FUNC-CMDLINE-009 — identical surface across all five bundled backends;
--                        this source compiles and runs unchanged for:
--                        standard, wide_string, wide_wide_string, uxstring, vss

with Ada.Text_IO;
with String_Types; use String_Types;
with String_Types.Command_Line; use String_Types.Command_Line;
procedure Anystrings_Cmdline_Demo is
begin
   --  FUNC-CMDLINE-001: query the number of command-line arguments
   Ada.Text_IO.Put_Line ("Argument count:" & Integer'Image (Argument_Count));

   --  FUNC-CMDLINE-002, FUNC-CMDLINE-008: iterate argv.
   for I in 1 .. Argument_Count loop
      Ada.Text_IO.Put_Line
        ("argv["
         & Integer'Image (I)
         & "] = "
         & To_Latin_1 (Get_Value_Or (From_UTF_8 (To_Latin_1 (Argument (I))), Argument (I))));
   end loop;

   --  FUNC-CMDLINE-004: program invocation name as String_Type
   Ada.Text_IO.Put_Line
     ("Command name: " & To_Latin_1 (Get_Value_Or (From_UTF_8 (To_Latin_1 (Command_Name)), Command_Name)));

   --  FUNC-CMDLINE-007, FUNC-CMDLINE-005: no-argument "misuse" branch —
   --  demonstrates the Integer overload (POSIX convention: exit code 2).
   --  Immediately reset to Success so the demo exits cleanly when run
   --  without arguments (e.g. during CI or interactive exploration).
   if Argument_Count = 0 then
      Ada.Text_IO.Put_Line ("Usage: anystrings_cmdline_demo <arg> [<arg> ...]");
      Set_Exit_Status (Integer'(2));   --  FUNC-CMDLINE-007: Integer overload
      Set_Exit_Status (Success);       --  FUNC-CMDLINE-005, FUNC-CMDLINE-006

   end if;

   --  FUNC-CMDLINE-006: typed Exit_Status overload on the normal exit path.
   --  Has no observable effect at this point; the OS reads whatever value is
   --  current when the main procedure returns, so only the last call matters.
   Set_Exit_Status (Success);
end Anystrings_Cmdline_Demo;
