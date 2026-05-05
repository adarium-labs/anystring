with Ada.Directories;
with Ada.Text_IO;
with Anystrings_Examples_Support;
with String_Types; use String_Types;

procedure Anystrings_Examples is
   S           : constant String_Type := To_String_Type ("Bepo");
   Env_Name    : constant String_Type := To_String_Type ("ANYSTRINGS_EXAMPLE_ENV");
   Env_Default : constant String_Type := To_String_Type ("<unset>");
   File_Name   : constant String := "anystrings_examples_io.txt";
   File_Handle : String_Types.File_Type;
   Read_Back   : String_Type := Empty_String;
begin
   String_Types.Put_Line (S);

   String_Types.Create (File_Handle, String_Types.Out_File, File_Name);
   String_Types.Put_Line (File_Handle, S);
   String_Types.Close (File_Handle);

   String_Types.Open (File_Handle, String_Types.In_File, File_Name);
   Read_Back := String_Types.Get_Line (File_Handle);
   Anystrings_Examples_Support.Assert
     (Read_Back = S,
      "Text_IO Get_Line did not round-trip the value");
   Anystrings_Examples_Support.Assert
     (String_Types.End_Of_File (File_Handle),
      "Text_IO End_Of_File should be true after reading the single line");
   String_Types.Close (File_Handle);
   Ada.Directories.Delete_File (File_Name);

   Ada.Text_IO.Put_Line
     ("Set result: "
      & Boolean'Image (Set_Env (Env_Name, To_String_Type ("bonjour"))));
   Ada.Text_IO.Put_Line
     ("ANYSTRINGS_EXAMPLE_ENV exists:" & Boolean'Image (Env_Exists (Env_Name)));
   Ada.Text_IO.Put_Line
     ("ANYSTRINGS_EXAMPLE_ENV value: "
      & To_Latin_1 (Get_Env (Env_Name, Env_Default)));
   Ada.Text_IO.Put_Line
     ("Filtered iteration success:"
      & Boolean'Image
          (Iterate_Env
             (Anystrings_Examples_Support.Has_Example_Prefix'Access,
              Anystrings_Examples_Support.Print_Env'Access)));
   Ada.Text_IO.Put_Line
     ("Clear result: " & Boolean'Image (Clear_Env (Env_Name)));
exception
   when others =>
      if String_Types.Is_Open (File_Handle) then
         String_Types.Close (File_Handle);
      end if;

      if Ada.Directories.Exists (File_Name) then
         Ada.Directories.Delete_File (File_Name);
      end if;

      raise;
end Anystrings_Examples;
