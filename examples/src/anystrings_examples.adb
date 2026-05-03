with Ada.Text_IO; use Ada.Text_IO;
with String_Types; use String_Types;

procedure Anystrings_Examples is
   S : constant String_Type := To_String_Type ("Bépo");
begin
   Put_Line (To_Latin_1 (S));
end Anystrings_Examples;
