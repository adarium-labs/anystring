-------------------------------------------------------------------------------
--  Ingress_Probe - test-only program for the ingress vectors (KI-046 L1)
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Prints, through the facade of the running backend, the Command_Name and
--  Argument (1) as "CMD <code points> <Code_Point_Length> <Length>" and
--  "ARG <code points> <Code_Point_Length> <Length>". Code points are uppercase
--  hexadecimal, "-" when empty (see Ingress_Vectors.Hex_Image).

with Ada.Strings.Fixed;
with Ada.Text_IO;
with String_Types;
with String_Types.Command_Line;
with Ingress_Vectors;

procedure Ingress_Probe is

   function Trim (N : Natural) return String is
   begin
      return Ada.Strings.Fixed.Trim (Natural'Image (N), Ada.Strings.Both);
   end Trim;

   procedure Report (Tag : String; Value : String_Types.String_Type) is
   begin
      Ada.Text_IO.Put_Line
        (Tag & " "
         & Ingress_Vectors.Hex_Image (String_Types.To_Wide_Wide_String (Value))
         & " " & Trim (String_Types.Code_Point_Length (Value))
         & " " & Trim (String_Types.Length (Value)));
   end Report;

begin
   Report ("CMD", String_Types.Command_Line.Command_Name);
   Report ("ARG", String_Types.Command_Line.Argument (1));
end Ingress_Probe;
