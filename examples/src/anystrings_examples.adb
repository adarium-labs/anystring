with Ada.Text_IO; use Ada.Text_IO;
with Anystrings_Examples_Support;
with String_Types; use String_Types;

procedure Anystrings_Examples is
   S            : constant String_Type := To_String_Type ("Bépo");
   Env_Name     : constant String_Type := To_String_Type ("ANYSTRINGS_EXAMPLE_ENV");
   Env_Default  : constant String_Type := To_String_Type ("<unset>");
begin
   Put_Line (To_Latin_1 (S));
   Put_Line ("Set result: " & Boolean'Image (Set_Env (Env_Name, To_String_Type ("bonjour"))));
   Put_Line ("ANYSTRINGS_EXAMPLE_ENV exists:" & Boolean'Image (Env_Exists (Env_Name)));
   Put_Line ("ANYSTRINGS_EXAMPLE_ENV value: " & To_Latin_1 (Get_Env (Env_Name, Env_Default)));
   Put_Line ("Filtered iteration success:"
             & Boolean'Image
                 (Iterate_Env
                    (Anystrings_Examples_Support.Has_Example_Prefix'Access,
                     Anystrings_Examples_Support.Print_Env'Access)));
   Put_Line ("Clear result: " & Boolean'Image (Clear_Env (Env_Name)));
end Anystrings_Examples;
