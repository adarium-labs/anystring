-------------------------------------------------------------------------------
--  Anystrings_Byte_Output - Byte-exact text output for every backend
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Writes already-encoded (UTF-8) bytes to a text file unchanged.
--
--  @description
--  GNAT's narrow Ada.Text_IO.Put encodes every character at or above
--  16#80# with the wide-character method of the MAIN program: under
--  -gnatW8 (added by Alire's default switches) each byte of a UTF-8
--  sequence is taken as a Latin-1 character and encoded again, so U+2026
--  (e2 80 a6) is written as c3 a2 c2 80 c2 a6.  A write through
--  Ada.Text_IO.Text_Streams is not encoded, whatever the main's -gnatW.
--  Pure 7-bit text keeps going through Ada.Text_IO.Put (column tracking
--  unchanged).  Input is not affected: Get_Line returns the raw bytes.

with Ada.Text_IO;

package Anystrings_Byte_Output
  with SPARK_Mode => Off
is

   --  Write Bytes to File as they are.
   procedure Put (File : Ada.Text_IO.File_Type; Bytes : String);

   --  Write Bytes to the current output as they are.
   procedure Put (Bytes : String);

   --  Write Bytes to File as they are, then a line terminator.
   procedure Put_Line (File : Ada.Text_IO.File_Type; Bytes : String);

   --  Write Bytes to the current output as they are, then a line terminator.
   procedure Put_Line (Bytes : String);

end Anystrings_Byte_Output;
