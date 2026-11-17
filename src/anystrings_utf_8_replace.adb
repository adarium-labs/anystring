-------------------------------------------------------------------------------
--  Anystrings_UTF_8_Replace - Shared U+FFFD replacement decoder (body)
--
--  Copyright (c) 2026
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  SPARK_Mode is Off: gnatprove does not analyse this body. Every index I
--  satisfies I in Source'Range, and every remaining length is computed as
--  Source'Last - I (a non-negative difference that fits Natural), never as
--  I + Length. The loops test "Step > Source'Last - I" and only then form
--  I + Step, so no index is formed past Source'Last. The boundary tests of
--  Ingress_Boundary_Test (strings whose bounds are near Positive'Last) and
--  the property gate of Ingress_Replace_Test exercise this body.

package body Anystrings_UTF_8_Replace
  with SPARK_Mode => Off
is

   --  Sanitised code point of a Wide_Wide_Character (policy P): surrogates and
   --  values above U+10FFFF become U+FFFD.
   function Scalar_Or_Replacement (C : Wide_Wide_Character) return Natural is
      P : constant Natural := Wide_Wide_Character'Pos (C);
   begin
      if P in 16#D800# .. 16#DFFF# or else P > 16#10_FFFF# then
         return 16#FFFD#;
      end if;
      return P;
   end Scalar_Or_Replacement;

   procedure Next
     (Source      : String;
      Index       : Integer;
      Scalar      : out Natural;
      Step        : out Positive;
      Well_Formed : out Boolean)
   is
      Lead     : constant Natural := Character'Pos (Source (Index));
      --  Bytes after Index. Index <= Source'Last, so this is never negative,
      --  and every position Index + K with K <= Room is inside Source.
      Room     : constant Natural := Source'Last - Index;
      Need     : Natural := 0;   --  continuation bytes required
      First_Lo : Natural := 16#80#;
      First_Hi : Natural := 16#BF#;
      CP       : Natural := 0;
      Accepted : Natural := 0;   --  continuation bytes accepted so far
   begin
      if Lead <= 16#7F# then
         Scalar      := Lead;
         Step        := 1;
         Well_Formed := True;
         return;

      elsif Lead in 16#C2# .. 16#DF# then
         Need := 1;
         CP   := Lead mod 16#20#;

      elsif Lead = 16#E0# then
         Need     := 2;
         First_Lo := 16#A0#;
         CP       := Lead mod 16#10#;

      elsif Lead in 16#E1# .. 16#EC# | 16#EE# .. 16#EF# then
         Need := 2;
         CP   := Lead mod 16#10#;

      elsif Lead = 16#ED# then
         Need     := 2;
         First_Hi := 16#9F#;
         CP       := Lead mod 16#10#;

      elsif Lead = 16#F0# then
         Need     := 3;
         First_Lo := 16#90#;
         CP       := Lead mod 16#08#;

      elsif Lead in 16#F1# .. 16#F3# then
         Need := 3;
         CP   := Lead mod 16#08#;

      elsif Lead = 16#F4# then
         Need     := 3;
         First_Hi := 16#8F#;
         CP       := Lead mod 16#08#;

      else
         --  80..C1 and F5..FF are never a lead byte: one ill-formed byte.
         Scalar      := 16#FFFD#;
         Step        := 1;
         Well_Formed := False;
         return;
      end if;

      --  Consume the continuation bytes allowed by the table for this lead.
      --  The byte at Index + Accepted + 1 exists exactly when
      --  Accepted + 1 <= Room; the test is made before the position is formed.
      while Accepted < Need loop
         exit when Accepted + 1 > Room;
         declare
            --  Index + (Accepted + 1), not Index + Accepted + 1: the same
            --  evaluation-order rule as Anystrings_UTF_8_Validate.
            B  : constant Natural := Character'Pos (Source (Index + (Accepted + 1)));
            Lo : constant Natural := (if Accepted = 0 then First_Lo else 16#80#);
            Hi : constant Natural := (if Accepted = 0 then First_Hi else 16#BF#);
         begin
            exit when B < Lo or else B > Hi;
            CP       := CP * 64 + B mod 64;
            Accepted := Accepted + 1;
         end;
      end loop;

      if Accepted = Need then
         Scalar      := CP;
         Step        := Need + 1;
         Well_Formed := True;
      else
         --  The lead and the accepted continuation bytes form one maximal
         --  ill-formed subpart; the offending byte (if any) is not consumed.
         Scalar      := 16#FFFD#;
         Step        := Accepted + 1;
         Well_Formed := False;
      end if;
   end Next;

   --  Scan driver shared by the three passes. Each caller handles the empty
   --  string first. The loop never forms an index past Source'Last: it stops
   --  when the step consumed the rest of Source, and otherwise I + Step is at
   --  most Source'Last.

   function Code_Point_Count (Source : String) return Natural is
      Count  : Natural := 0;
      I      : Integer;
      Scalar : Natural;
      Step   : Positive;
      Ok     : Boolean;
   begin
      if Source'Length = 0 then
         return 0;
      end if;
      I := Source'First;
      loop
         Next (Source, I, Scalar, Step, Ok);
         Count := Count + 1;
         exit when Step > Source'Last - I;
         I := I + Step;
      end loop;
      return Count;
   end Code_Point_Count;

   function Decode_Replacing (Source : String) return Wide_Wide_String is
      Result : Wide_Wide_String (1 .. Code_Point_Count (Source));
      J      : Natural := 0;
      I      : Integer;
      Scalar : Natural;
      Step   : Positive;
      Ok     : Boolean;
   begin
      if Source'Length = 0 then
         return Result;
      end if;
      I := Source'First;
      loop
         Next (Source, I, Scalar, Step, Ok);
         J          := J + 1;
         Result (J) := Wide_Wide_Character'Val (Scalar);
         exit when Step > Source'Last - I;
         I := I + Step;
      end loop;
      return Result;
   end Decode_Replacing;

   function Replace_Ill_Formed (Source : String) return String is
      Total  : Natural := 0;
      I      : Integer;
      Scalar : Natural;
      Step   : Positive;
      Ok     : Boolean;
   begin
      if Source'Length = 0 then
         return "";
      end if;

      --  First pass: exact length of the result.
      I := Source'First;
      loop
         Next (Source, I, Scalar, Step, Ok);
         Total := Total + (if Ok then Step else 3);
         exit when Step > Source'Last - I;
         I := I + Step;
      end loop;

      declare
         Result : String (1 .. Total);
         Out_At : Natural := 0;
      begin
         --  Second pass: copy the well-formed subparts, write U+FFFD for the rest.
         I := Source'First;
         loop
            Next (Source, I, Scalar, Step, Ok);
            if Ok then
               for K in 0 .. Step - 1 loop
                  Out_At          := Out_At + 1;
                  Result (Out_At) := Source (I + K);
               end loop;
            else
               Result (Out_At + 1) := Character'Val (16#EF#);
               Result (Out_At + 2) := Character'Val (16#BF#);
               Result (Out_At + 3) := Character'Val (16#BD#);
               Out_At              := Out_At + 3;
            end if;
            exit when Step > Source'Last - I;
            I := I + Step;
         end loop;
         return Result;
      end;
   end Replace_Ill_Formed;

   --  Width in code units of the code point that starts at Source (I): 2 for a
   --  high surrogate followed by a low surrogate, 1 for every other unit. The
   --  test I < Source'Last comes before I + 1 is formed, so no index is built
   --  past Source'Last (which can be Positive'Last).
   function UTF_16_Width (Source : Wide_String; I : Integer) return Positive is
   begin
      if Wide_Character'Pos (Source (I)) in 16#D800# .. 16#DBFF#
        and then I < Source'Last
        and then Wide_Character'Pos (Source (I + 1)) in 16#DC00# .. 16#DFFF#
      then
         return 2;
      end if;
      return 1;
   end UTF_16_Width;

   function UTF_16_Scalar_Count (Source : Wide_String) return Natural is
      Count : Natural := 0;
      I     : Integer;
      Step  : Positive;
   begin
      if Source'Length = 0 then
         return 0;
      end if;
      I := Source'First;
      loop
         Step  := UTF_16_Width (Source, I);
         Count := Count + 1;
         exit when Step > Source'Last - I;
         I := I + Step;
      end loop;
      return Count;
   end UTF_16_Scalar_Count;

   function From_UTF_16 (Source : Wide_String) return Wide_Wide_String is
      Result : Wide_Wide_String (1 .. UTF_16_Scalar_Count (Source));
      J      : Natural := 0;
      I      : Integer;
      Step   : Positive;
   begin
      if Source'Length = 0 then
         return Result;
      end if;
      I := Source'First;
      loop
         Step := UTF_16_Width (Source, I);
         J    := J + 1;
         declare
            CP : constant Natural := Wide_Character'Pos (Source (I));
         begin
            if Step = 2 then
               Result (J) :=
                 Wide_Wide_Character'Val
                   (16#10000# + (CP - 16#D800#) * 16#400#
                    + (Wide_Character'Pos (Source (I + 1)) - 16#DC00#));
            elsif CP in 16#D800# .. 16#DFFF# then
               Result (J) := Wide_Wide_Character'Val (16#FFFD#);   --  lone surrogate
            else
               Result (J) := Wide_Wide_Character'Val (CP);
            end if;
         end;
         exit when Step > Source'Last - I;
         I := I + Step;
      end loop;
      return Result;
   end From_UTF_16;

   function To_UTF_16 (Source : Wide_Wide_String) return Wide_String is
      Units : Natural := 0;
   begin
      for C of Source loop
         Units := Units + (if Scalar_Or_Replacement (C) <= 16#FFFF# then 1 else 2);
      end loop;

      declare
         Result : Wide_String (1 .. Units);
         J      : Natural := 0;
      begin
         for C of Source loop
            declare
               P : constant Natural := Scalar_Or_Replacement (C);
            begin
               if P <= 16#FFFF# then
                  J := J + 1;
                  Result (J) := Wide_Character'Val (P);
               else
                  declare
                     Off : constant Natural := P - 16#10000#;
                  begin
                     J := J + 1;
                     Result (J) := Wide_Character'Val (16#D800# + Off / 16#400#);
                     J := J + 1;
                     Result (J) := Wide_Character'Val (16#DC00# + Off mod 16#400#);
                  end;
               end if;
            end;
         end loop;
         return Result;
      end;
   end To_UTF_16;

end Anystrings_UTF_8_Replace;
