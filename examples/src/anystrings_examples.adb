with Ada.Directories;
with Ada.Text_IO;
with Anystrings_Examples_Support;
with String_Types; use String_Types;
with String_Types.Environment; use String_Types.Environment;
with String_Types.Text_IO; use String_Types.Text_IO;

procedure Anystrings_Examples is
   S           : constant String_Type := To_String_Type ("Bepo");
   Env_Name    : constant String_Type := To_String_Type ("ANYSTRINGS_EXAMPLE_ENV");
   Env_Default : constant String_Type := To_String_Type ("<unset>");
   File_Name   : constant String := "anystrings_examples_io.txt";
   File_Handle : File_Type;
   Read_Back   : String_Type := Empty_String;
begin
   Put_Line (S);

   Create (File_Handle, Out_File, File_Name);
   Put_Line (File_Handle, S);
   Close (File_Handle);

   Open (File_Handle, In_File, File_Name);
   Read_Back := Get_Line (File_Handle);
   Anystrings_Examples_Support.Assert
     (Read_Back = S,
      "Text_IO Get_Line did not round-trip the value");
   Anystrings_Examples_Support.Assert
     (End_Of_File (File_Handle),
      "Text_IO End_Of_File should be true after reading the single line");
   Close (File_Handle);
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

   --  Character classification & case mapping demo. These predicates work
   --  on every backend; non-ASCII coverage depends on Character_Type's
   --  range (see src/strings/AGENTS.md).
   declare
      A_Lower : constant Character_Type := Character_Type'Val (Character'Pos ('a'));
      A_Upper : constant Character_Type := Character_Type'Val (Character'Pos ('A'));
      Digit_5 : constant Character_Type := Character_Type'Val (Character'Pos ('5'));
      Space   : constant Character_Type := Character_Type'Val (Character'Pos (' '));
   begin
      Ada.Text_IO.Put_Line
        ("Is_Letter ('a'):       " & Boolean'Image (Is_Letter (A_Lower)));
      Ada.Text_IO.Put_Line
        ("Is_Digit ('5'):        " & Boolean'Image (Is_Digit (Digit_5)));
      Ada.Text_IO.Put_Line
        ("Is_Upper ('A'):        " & Boolean'Image (Is_Upper (A_Upper)));
      Ada.Text_IO.Put_Line
        ("Is_Whitespace (' '):   " & Boolean'Image (Is_Whitespace (Space)));
      Ada.Text_IO.Put_Line
        ("Is_Alphanumeric ('a'): " & Boolean'Image (Is_Alphanumeric (A_Lower)));
      Anystrings_Examples_Support.Assert
        (To_Upper (A_Lower) = A_Upper,
         "Character-level To_Upper ('a') should equal 'A'");
      Anystrings_Examples_Support.Assert
        (To_Lower (A_Upper) = A_Lower,
         "Character-level To_Lower ('A') should equal 'a'");
   end;
exception
   when others =>
      if Is_Open (File_Handle) then
         Close (File_Handle);
      end if;

      if Ada.Directories.Exists (File_Name) then
         Ada.Directories.Delete_File (File_Name);
      end if;

      raise;
end Anystrings_Examples;
