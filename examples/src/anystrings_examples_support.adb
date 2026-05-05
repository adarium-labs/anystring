with Ada.Text_IO;
with String_Types; use String_Types;

package body Anystrings_Examples_Support is

   Env_Prefix                : constant String_Type := To_String_Type ("ANYSTRINGS_");
   Expected_Regression_Name  : String_Type := Empty_String;
   Expected_Regression_Value : String_Type := Empty_String;
   Saw_Regression_Entry      : Boolean := False;

   procedure Assert (Condition : Boolean; Message : String) is
   begin
      if not Condition then
         raise Program_Error with Message;
      end if;
   end Assert;

   function Selected_Wide_Env_Encoding
     (Policy : Wide_Env_Encoding_Kind) return String
   is
   begin
      case Policy is
         when UTF_8 =>
            return "utf_8";
         when Latin_1 =>
            return "latin_1";
      end case;
   end Selected_Wide_Env_Encoding;

   function Encode_UTF_8_From_Latin_1 (Source : String) return String is
      Result_Length : Natural := 0;
   begin
      for C of Source loop
         if Character'Pos (C) <= 16#7F# then
            Result_Length := Result_Length + 1;
         else
            Result_Length := Result_Length + 2;
         end if;
      end loop;

      declare
         Result : String (1 .. Result_Length);
         Last   : Natural := 0;
      begin
         for C of Source loop
            declare
               Code : constant Natural := Character'Pos (C);
            begin
               if Code <= 16#7F# then
                  Last := Last + 1;
                  Result (Last) := C;
               else
                  Last := Last + 1;
                  Result (Last) := Character'Val (16#C0# + Code / 64);
                  Last := Last + 1;
                  Result (Last) := Character'Val (16#80# + Code mod 64);
               end if;
            end;
         end loop;

         return Result;
      end;
   end Encode_UTF_8_From_Latin_1;

   function Expected_Environment_Bytes
     (Policy : Wide_Env_Encoding_Kind;
      Source : String) return String
   is
   begin
      case Policy is
         when UTF_8 =>
            return Encode_UTF_8_From_Latin_1 (Source);
         when Latin_1 =>
            return Source;
      end case;
   end Expected_Environment_Bytes;

   procedure Reset_Regression_Tracking is
   begin
      Expected_Regression_Name := Empty_String;
      Expected_Regression_Value := Empty_String;
      Saw_Regression_Entry := False;
   end Reset_Regression_Tracking;

   procedure Configure_Regression_Entry
     (Name  : String_Type;
      Value : String_Type)
   is
   begin
      Expected_Regression_Name := Name;
      Expected_Regression_Value := Value;
      Saw_Regression_Entry := False;
   end Configure_Regression_Entry;

   procedure Verify_Regression_Entry
     (Name  : String_Type;
      Value : String_Type)
   is
   begin
      if Name = Expected_Regression_Name then
         Saw_Regression_Entry := True;
         Assert (Value = Expected_Regression_Value, "Iterate_Env returned the wrong value");
      end if;
   end Verify_Regression_Entry;

   function Regression_Entry_Seen return Boolean is (Saw_Regression_Entry);

   procedure Print_Env
     (Name  : String_Type;
      Value : String_Type)
   is
   begin
      Ada.Text_IO.Put_Line
        ("ENV " & To_Latin_1 (Name) & " = " & To_Latin_1 (Value));
   end Print_Env;

   function Has_Example_Prefix
     (Name  : String_Type;
      Value : String_Type) return Boolean
   is
      pragma Unreferenced (Value);
   begin
      return Starts_With (Name, Env_Prefix);
   end Has_Example_Prefix;

end Anystrings_Examples_Support;
