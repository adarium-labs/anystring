-------------------------------------------------------------------------------
--  Standard_Text_IO - Ada.Text_IO bridge for the standard backend
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Stand-alone Ada.Text_IO bridge for the standard (Unbounded_String)
--  backend.  Spec SPARK_Mode On; body SPARK_Mode Off.
--
--  @relation FUNC-FACADE-009, NFR-FACADE-002

with Ada.Strings.Unbounded;
with Ada.Text_IO;

package Standard_Text_IO with SPARK_Mode is

   subtype String_Type is Ada.Strings.Unbounded.Unbounded_String;

   subtype File_Type is Ada.Text_IO.File_Type;
   subtype File_Mode is Ada.Text_IO.File_Mode;

   In_File     : constant File_Mode := Ada.Text_IO.In_File;
   Out_File    : constant File_Mode := Ada.Text_IO.Out_File;
   Append_File : constant File_Mode := Ada.Text_IO.Append_File;

   procedure Create (File : in out File_Type; Mode : File_Mode := Out_File; Name : String := "");
   procedure Open (File : in out File_Type; Mode : File_Mode; Name : String);
   procedure Close (File : in out File_Type) renames Ada.Text_IO.Close;
   function Is_Open (File : File_Type) return Boolean renames Ada.Text_IO.Is_Open;

   function Current_Input return File_Type renames Ada.Text_IO.Current_Input;
   function Current_Output return File_Type renames Ada.Text_IO.Current_Output;
   procedure Set_Input (File : File_Type) renames Ada.Text_IO.Set_Input;
   procedure Set_Output (File : File_Type) renames Ada.Text_IO.Set_Output;

   procedure Put (Item : String_Type);
   procedure Put (File : File_Type; Item : String_Type);
   procedure Put_Line (Item : String_Type);
   procedure Put_Line (File : File_Type; Item : String_Type);

   function Get_Line return String_Type;
   function Get_Line (File : File_Type) return String_Type;
   procedure Get_Line (Item : out String_Type);
   procedure Get_Line (File : File_Type; Item : out String_Type);

   procedure New_Line;
   procedure New_Line (File : File_Type);

   function End_Of_File return Boolean renames Ada.Text_IO.End_Of_File;
   function End_Of_File (File : File_Type) return Boolean renames Ada.Text_IO.End_Of_File;

end Standard_Text_IO;
