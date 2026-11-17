-------------------------------------------------------------------------------
--  Ingress_Env_Probe - body
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with Ada.Text_IO;
with String_Types;
with String_Types.Environment;
with Ingress_Vectors;

--  The callbacks are library-level subprograms of this package body, so that
--  their access values match the library-level Env_Processor and Env_Filter
--  types of the facade.
package body Ingress_Env_Probe is

   Prefix : constant String := "ANYSTRING_P3_";

   --  True when the decoded name starts with Prefix (an ASCII prefix, so the
   --  comparison is over code points).
   function Has_Prefix (Name : String_Types.String_Type) return Boolean is
      W : constant Wide_Wide_String := String_Types.To_Wide_Wide_String (Name);
   begin
      if W'Length < Prefix'Length then
         return False;
      end if;
      for I in Prefix'Range loop
         if W (W'First + (I - Prefix'First))
           /= Wide_Wide_Character'Val (Character'Pos (Prefix (I)))
         then
            return False;
         end if;
      end loop;
      return True;
   end Has_Prefix;

   function Image (S : String_Types.String_Type) return String is
   begin
      return Ingress_Vectors.Hex_Image (String_Types.To_Wide_Wide_String (S));
   end Image;

   --  Iterate_Env (Process): prints the matching variables.
   procedure Print_Item (Name, Value : String_Types.String_Type) is
   begin
      if Has_Prefix (Name) then
         Ada.Text_IO.Put_Line ("ITER1 " & Image (Name) & " " & Image (Value));
      end if;
   end Print_Item;

   --  Iterate_Env (Include, Process): the filter selects the matches.
   function Match_Item (Name, Value : String_Types.String_Type) return Boolean is
      pragma Unreferenced (Value);
   begin
      return Has_Prefix (Name);
   end Match_Item;

   procedure Print_Item_Included (Name, Value : String_Types.String_Type) is
   begin
      Ada.Text_IO.Put_Line ("ITER2 " & Image (Name) & " " & Image (Value));
   end Print_Item_Included;

   procedure Run is
      V_Name : constant String_Types.String_Type :=
        String_Types.To_String_Type ("ANYSTRING_P3_V");
      Ok     : Boolean;
   begin
      if String_Types.Environment.Env_Exists (V_Name) then
         Ada.Text_IO.Put_Line
           ("GET " & Image (String_Types.Environment.Get_Env (V_Name)) & " present");
      else
         Ada.Text_IO.Put_Line ("GET - absent");
      end if;

      Ok := String_Types.Environment.Iterate_Env (Print_Item'Access);
      if not Ok then
         Ada.Text_IO.Put_Line ("ITER1 ERROR");
      end if;

      Ok := String_Types.Environment.Iterate_Env (Match_Item'Access, Print_Item_Included'Access);
      if not Ok then
         Ada.Text_IO.Put_Line ("ITER2 ERROR");
      end if;
   end Run;

end Ingress_Env_Probe;
