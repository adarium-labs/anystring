-------------------------------------------------------------------------------
--  Anystrings_Byte_Output - Byte-exact text output for every backend
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Text_IO.Text_Streams;

package body Anystrings_Byte_Output
  with SPARK_Mode => Off
is

   --  True when every byte is 7-bit (nothing for -gnatW8 to encode).
   function Is_Seven_Bit (Bytes : String) return Boolean
   is (for all B of Bytes => Character'Pos (B) < 16#80#);

   procedure Put (File : Ada.Text_IO.File_Type; Bytes : String) is
   begin
      if Is_Seven_Bit (Bytes) then
         Ada.Text_IO.Put (File, Bytes);
      else
         String'Write (Ada.Text_IO.Text_Streams.Stream (File), Bytes);
      end if;
   end Put;

   procedure Put (Bytes : String) is
   begin
      Put (Ada.Text_IO.Current_Output, Bytes);
   end Put;

   procedure Put_Line (File : Ada.Text_IO.File_Type; Bytes : String) is
   begin
      Put (File, Bytes);
      Ada.Text_IO.New_Line (File);
   end Put_Line;

   procedure Put_Line (Bytes : String) is
   begin
      Put_Line (Ada.Text_IO.Current_Output, Bytes);
   end Put_Line;

end Anystrings_Byte_Output;
