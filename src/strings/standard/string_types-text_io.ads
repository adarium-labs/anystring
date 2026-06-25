-------------------------------------------------------------------------------
--  String_Types.Text_IO - Text_IO bridge re-exports
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Child package of String_Types exposing the Text_IO bridge.
--
--  @description
--  Pure renames of the per-backend Standard_Text_IO implementation
--  package, so that consumers can opt in to the Text I/O API with
--  `with String_Types.Text_IO;` without forcing Ada.Text_IO into the
--  dependency closure of every `with String_Types;`.
--
--  Public surface is identical across all five backends
--  (FUNC-FACADE-003), only the rename targets differ.
--
--  @relation FUNC-FACADE-002, FUNC-FACADE-003, FUNC-FACADE-009, NFR-FACADE-002

with Standard_Text_IO;

package String_Types.Text_IO with SPARK_Mode is

   subtype File_Type is Standard_Text_IO.File_Type;
   subtype File_Mode is Standard_Text_IO.File_Mode;

   In_File     : constant File_Mode := Standard_Text_IO.In_File;
   Out_File    : constant File_Mode := Standard_Text_IO.Out_File;
   Append_File : constant File_Mode := Standard_Text_IO.Append_File;

   procedure Create (File : in out File_Type; Mode : File_Mode := Out_File; Name : String := "")
     renames Standard_Text_IO.Create;
   procedure Open (File : in out File_Type; Mode : File_Mode; Name : String)
     renames Standard_Text_IO.Open;
   procedure Close (File : in out File_Type) renames Standard_Text_IO.Close;
   function Is_Open (File : File_Type) return Boolean renames Standard_Text_IO.Is_Open;

   function Current_Input return File_Type renames Standard_Text_IO.Current_Input;
   function Current_Output return File_Type renames Standard_Text_IO.Current_Output;
   procedure Set_Input (File : File_Type) renames Standard_Text_IO.Set_Input;
   procedure Set_Output (File : File_Type) renames Standard_Text_IO.Set_Output;

   function Standard_Input return File_Type renames Standard_Text_IO.Standard_Input;
   function Standard_Output return File_Type renames Standard_Text_IO.Standard_Output;
   function Standard_Error return File_Type renames Standard_Text_IO.Standard_Error;

   procedure Put (Item : String_Type) renames Standard_Text_IO.Put;
   procedure Put (File : File_Type; Item : String_Type) renames Standard_Text_IO.Put;
   procedure Put_Line (Item : String_Type) renames Standard_Text_IO.Put_Line;
   procedure Put_Line (File : File_Type; Item : String_Type) renames Standard_Text_IO.Put_Line;

   function Get_Line return String_Type renames Standard_Text_IO.Get_Line;
   function Get_Line (File : File_Type) return String_Type renames Standard_Text_IO.Get_Line;
   procedure Get_Line (Item : out String_Type) renames Standard_Text_IO.Get_Line;
   procedure Get_Line (File : File_Type; Item : out String_Type) renames Standard_Text_IO.Get_Line;

   procedure New_Line renames Standard_Text_IO.New_Line;
   procedure New_Line (File : File_Type) renames Standard_Text_IO.New_Line;

   function End_Of_File return Boolean renames Standard_Text_IO.End_Of_File;
   function End_Of_File (File : File_Type) return Boolean renames Standard_Text_IO.End_Of_File;

end String_Types.Text_IO;
