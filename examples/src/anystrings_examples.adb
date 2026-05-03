with Ada.wide_wide_Text_IO; use Ada.wide_wide_Text_IO;
--  with Ada.Strings.Wide_Wide_Unbounded;
with String_Types; use String_Types;

procedure Anystrings_Examples is
   S : constant String_Type := To_String_Type ("Bépo 🙂");
begin
   declare
      --  use Ada.Strings.Wide_Wide_Unbounded;
   begin
      Put_Line (To_Wide_Wide_String (S));
   end;
end Anystrings_Examples;
