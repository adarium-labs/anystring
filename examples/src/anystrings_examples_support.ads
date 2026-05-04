with String_Types;

package Anystrings_Examples_Support is

   procedure Assert (Condition : Boolean; Message : String);

   type Wide_Env_Encoding_Kind is (UTF_8, Latin_1);

   function Selected_Wide_Env_Encoding
     (Policy : Wide_Env_Encoding_Kind) return String;

   function Expected_Environment_Bytes
     (Policy : Wide_Env_Encoding_Kind;
      Source : String) return String;

   procedure Reset_Regression_Tracking;

   procedure Configure_Regression_Entry
     (Name  : String_Types.String_Type;
      Value : String_Types.String_Type);

   procedure Verify_Regression_Entry
     (Name  : String_Types.String_Type;
      Value : String_Types.String_Type);

   function Regression_Entry_Seen return Boolean;

   procedure Print_Env
     (Name  : String_Types.String_Type;
      Value : String_Types.String_Type);

   function Has_Example_Prefix
     (Name  : String_Types.String_Type;
      Value : String_Types.String_Type) return Boolean;

end Anystrings_Examples_Support;
