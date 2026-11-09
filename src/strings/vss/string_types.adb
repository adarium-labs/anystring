-------------------------------------------------------------------------------
--  String_Types - VSS Configuration (bodies)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Bodies of the length-contracted declarations in string_types.ads.
--
--  @description
--  SPARK_Mode is Off: the contracts declared in the specification are
--  trusted, not proved, on this backend. Run-time checks of those contracts
--  are performed by the test suite, which is built with assertions enabled.
--  See src/strings/AGENTS.md ("Proof boundaries").

package body String_Types
  with SPARK_Mode => Off
is

   function Length (Source : String_Type) return Natural
   is (VSS_Operations.Length (Source));

   function Is_Empty (Source : String_Type) return Boolean
   is (VSS_Operations.Is_Empty (Source));

   function "&" (Left : String_Type; Right : String_Type) return String_Type
   is (VSS_Operations.Concat_Strings (Left, Right));

   function "&" (Left : String_Type; Right : Character_Type) return String_Type
   is (VSS_Operations.Concat_String_Character (Left, Right));

   function "&" (Left : Character_Type; Right : String_Type) return String_Type
   is (VSS_Operations.Concat_Character_String (Left, Right));

   function "&" (Left : String_Type; Right : String) return String_Type
   is (VSS_Operations.Concat_String_Latin_1 (Left, Right));

   function "&" (Left : String; Right : String_Type) return String_Type
   is (VSS_Operations.Concat_Latin_1_String (Left, Right));

   function Concat (Left : String_Type; Right : String_Type) return String_Type
   is (Left & Right);

   function Append_Character (Left : String_Type; Right : Character_Type) return String_Type
   is (Left & Right);

   function Prepend_Character (Left : Character_Type; Right : String_Type) return String_Type
   is (Left & Right);

   function Null_String_Value return String_Type
   is (VSS_Operations.To_Virtual_String (""));

   procedure Append (Source : in out String_Type; New_Item : String_Type) is
   begin
      Source := Source & New_Item;
   end Append;

   function To_String_Type (Source : String) return String_Type
   is (VSS_Operations.To_Virtual_String (Source));

   function To_Latin_1 (Source : String_Type) return String
   is (VSS_Operations.To_String (Source));

   function Slice (Source : String_Type; Low : Positive; High : Natural) return String_Type
   is (VSS_Operations.Slice (Source, Low, High));

end String_Types;
