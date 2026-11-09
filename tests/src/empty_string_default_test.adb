-------------------------------------------------------------------------------
--  Anystrings Tests - Empty_String As A Component Default Test Suite Body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with String_Types;     use String_Types;

package body Empty_String_Default_Test is

   --  A predicated subtype, like a bounded failure text of an application.
   subtype Short_Text is String_Type with Dynamic_Predicate => Length (Short_Text) <= 1_000;

   type State is record
      Message : Short_Text := Empty_String;
      Later   : Short_Text := Empty_String;
      Count   : Natural := 0;
      Key     : String_Type := Empty_String;
   end record;

   type State_Array is array (1 .. 20) of State;

   --  Library-level object: default-initialised during elaboration and
   --  finalized at program exit.
   Library_State : State;

   function Make (Text : String) return State is
   begin
      return (Message => To_String_Type (Text), Later => Empty_String, Count => Text'Length, Key => Empty_String);
   end Make;

   overriding
   function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Empty_String Component Default Tests");
   end Name;

   overriding
   procedure Register_Tests (T : in out Test_Case) is
   begin
      Add_Routine
        (T,
         (Routine      => Test_Library_Level_Default'Access,
          Routine_Name => AUnit.Format ("a library-level record defaults its String_Type components to empty")));
      Add_Routine
        (T,
         (Routine      => Test_Local_Defaults_Are_Independent'Access,
          Routine_Name => AUnit.Format ("default-initialised records own independent strings")));
      Add_Routine
        (T,
         (Routine      => Test_Copy_And_Assign'Access,
          Routine_Name => AUnit.Format ("copying and assigning records with defaulted components")));
      Add_Routine
        (T,
         (Routine      => Test_Repeated_Create_And_Finalize'Access,
          Routine_Name => AUnit.Format ("repeated creation and finalization of defaulted records")));
   end Register_Tests;

   procedure Test_Library_Level_Default (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Assert (Length (Library_State.Message) = 0, "Message must default to the empty string");
      Assert (Length (Library_State.Later) = 0, "Later must default to the empty string");
      Assert (Is_Empty (Library_State.Key), "Key must default to the empty string");
      Library_State.Message := To_String_Type ("set");
      Assert (Length (Library_State.Message) = 3, "assignment must replace the default");
      Library_State.Message := Empty_String;
      Assert (Is_Empty (Library_State.Message), "assigning Empty_String must empty the component");
   end Test_Library_Level_Default;

   procedure Test_Local_Defaults_Are_Independent (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
      A : State;
      B : State;
   begin
      A.Message := To_String_Type ("alpha");
      Assert (Length (A.Message) = 5, "A.Message must hold the assigned text");
      Assert (Is_Empty (B.Message), "B.Message must stay empty when A.Message changes");
      Assert (Is_Empty (Library_State.Later), "the library-level record must stay empty");
      B.Later := A.Message & To_String_Type ("!");
      Assert (Length (B.Later) = 6, "B.Later must hold the concatenation");
      Assert (Length (A.Message) = 5, "A.Message must be unchanged");
   end Test_Local_Defaults_Are_Independent;

   procedure Test_Copy_And_Assign (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
      Original : State := Make ("original");
      Copy     : constant State := Original;
      Target   : State;
   begin
      Target := Original;
      Original.Message := Empty_String;
      Assert (Length (Copy.Message) = 8, "a copy must not share the original's buffer");
      Assert (Length (Target.Message) = 8, "an assigned record must not share the original's buffer");
      Assert (Is_Empty (Original.Message), "the original must have been emptied");
      Target := Make ("x");
      Assert (Length (Target.Message) = 1, "assignment from a function result");
      Assert (Length (Copy.Message) = 8, "the copy must be unaffected");
   end Test_Copy_And_Assign;

   procedure Test_Repeated_Create_And_Finalize (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
      Total : Natural := 0;
      Round : Natural := 0;
   begin
      while Round < 200 loop
         Round := Round + 1;
         declare
            Items : State_Array;
            Extra : State := Make ("round");
         begin
            for I in Items'Range loop
               Items (I).Message := Extra.Message & To_String_Type ("-");
               Items (I).Count := I;
            end loop;
            Total := Total + Length (Items (Items'Last).Message);
         end;
      end loop;
      Assert (Total = 200 * 6, "every round must see consistent strings, got" & Natural'Image (Total));
   end Test_Repeated_Create_And_Finalize;

end Empty_String_Default_Test;
