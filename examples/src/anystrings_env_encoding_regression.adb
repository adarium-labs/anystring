with Ada.Environment_Variables;
with Ada.Text_IO; use Ada.Text_IO;
with Anystrings_Examples_Support;
with String_Types; use String_Types;

procedure Anystrings_Env_Encoding_Regression is
   use type Anystrings_Examples_Support.Wide_Env_Encoding_Kind;

   Name_Text  : constant String := "ANYSTRINGS_ENV_REGRESSION";
   Value_Text : constant String := "caf" & Character'Val (16#E9#);

   function Detect_Policy return Anystrings_Examples_Support.Wide_Env_Encoding_Kind is
      Probe_Name    : constant String := "ANYSTRINGS_ENV_POLICY_PROBE";
      Probe_Name_T  : constant String_Type := To_String_Type (Probe_Name);
      Probe_Value   : constant String := (1 => Character'Val (16#E9#));
      Probe_Value_T : constant String_Type := To_String_Type (Probe_Value);
      UTF_8_Bytes   : constant String :=
        Anystrings_Examples_Support.Expected_Environment_Bytes
          (Anystrings_Examples_Support.UTF_8, Probe_Value);
      Latin_1_Bytes : constant String :=
        Anystrings_Examples_Support.Expected_Environment_Bytes
          (Anystrings_Examples_Support.Latin_1, Probe_Value);
   begin
      Anystrings_Examples_Support.Assert
        (Set_Env (Probe_Name_T, Probe_Value_T),
         "Policy probe Set_Env failed");
      Anystrings_Examples_Support.Assert
        (Ada.Environment_Variables.Exists (Probe_Name),
         "Policy probe raw name missing");

      declare
         Actual_Bytes : constant String := Ada.Environment_Variables.Value (Probe_Name);
      begin
         Anystrings_Examples_Support.Assert
           (Clear_Env (Probe_Name_T),
            "Policy probe Clear_Env failed");

         if Actual_Bytes = UTF_8_Bytes then
            return Anystrings_Examples_Support.UTF_8;
         elsif Actual_Bytes = Latin_1_Bytes then
            return Anystrings_Examples_Support.Latin_1;
         else
            raise Program_Error with "Unable to infer wide environment encoding policy";
         end if;
      end;
   end Detect_Policy;

   Env_Name   : constant String_Type := To_String_Type (Name_Text);
   Env_Value  : constant String_Type := To_String_Type (Value_Text);
   High_Value : constant String_Type :=
     To_String_Type ("wide-") & From_Character (Character_Type'Val (16#20AC#));

   procedure Cleanup
     (Policy   : Anystrings_Examples_Support.Wide_Env_Encoding_Kind;
      Is_Ready : Boolean)
   is
      Raw_Name : constant String :=
        Anystrings_Examples_Support.Expected_Environment_Bytes (Policy, Name_Text);
   begin
      if Is_Ready and then Env_Exists (Env_Name) then
         Anystrings_Examples_Support.Assert
           (Clear_Env (Env_Name),
            "Cleanup failed through String_Types");
      elsif Is_Ready and then Ada.Environment_Variables.Exists (Raw_Name) then
         Ada.Environment_Variables.Clear (Raw_Name);
      end if;
   exception
      when others =>
         null;
   end Cleanup;
begin
   declare
      Policy   : constant Anystrings_Examples_Support.Wide_Env_Encoding_Kind := Detect_Policy;
      Raw_Name : constant String :=
        Anystrings_Examples_Support.Expected_Environment_Bytes (Policy, Name_Text);
      Raw_Value : constant String :=
        Anystrings_Examples_Support.Expected_Environment_Bytes (Policy, Value_Text);
   begin
      Ada.Environment_Variables.Clear;
      Cleanup (Policy, True);
      Anystrings_Examples_Support.Reset_Regression_Tracking;
      Anystrings_Examples_Support.Configure_Regression_Entry (Env_Name, Env_Value);

      Anystrings_Examples_Support.Assert (Set_Env (Env_Name, Env_Value), "Set_Env failed");
      Anystrings_Examples_Support.Assert
        (Env_Exists (Env_Name),
         "Env_Exists failed after Set_Env");
      Anystrings_Examples_Support.Assert
        (Ada.Environment_Variables.Exists (Raw_Name),
         "Encoded environment name was not created in Ada.Environment_Variables");
      Anystrings_Examples_Support.Assert
        (Ada.Environment_Variables.Value (Raw_Name) = Raw_Value,
         "Encoded environment value does not match selected policy");
      Anystrings_Examples_Support.Assert
        (Get_Env (Env_Name, Empty_String) = Env_Value,
         "Get_Env failed to decode the stored value");
      Anystrings_Examples_Support.Assert
        (Iterate_Env (Anystrings_Examples_Support.Verify_Regression_Entry'Access),
         "Iterate_Env reported failure");
      Anystrings_Examples_Support.Assert
        (Anystrings_Examples_Support.Regression_Entry_Seen,
         "Iterate_Env did not yield the regression entry");
      Anystrings_Examples_Support.Assert (Clear_Env (Env_Name), "Clear_Env failed");
      Anystrings_Examples_Support.Assert
        (not Ada.Environment_Variables.Exists (Raw_Name),
         "Clear_Env left raw entry behind");

      if Policy = Anystrings_Examples_Support.Latin_1 then
         Anystrings_Examples_Support.Assert
           (not Set_Env (Env_Name, High_Value),
            "latin_1 policy should reject values outside Latin-1");
         Anystrings_Examples_Support.Assert
           (Get_Env (Env_Name, Empty_String) = Empty_String,
            "Failed latin_1 Set_Env should not create a value");
      end if;

      Put_Line
        ("PASS anystrings_env_encoding_regression policy="
         & Anystrings_Examples_Support.Selected_Wide_Env_Encoding (Policy));
   exception
      when others =>
         Cleanup (Detect_Policy, True);
         raise;
   end;
end Anystrings_Env_Encoding_Regression;
