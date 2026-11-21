-------------------------------------------------------------------------------
--  String_Types - Standard String Configuration (bodies)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

package body String_Types
  with SPARK_Mode
is

   function Full_Lower_Length (Source : String_Type) return Long_Long_Integer
   with SPARK_Mode => Off
   is
   begin
      return Standard_String_Operations.Full_Lower_Length (Source);
   end Full_Lower_Length;

   function Full_Upper_Length (Source : String_Type) return Long_Long_Integer
   with SPARK_Mode => Off
   is
   begin
      return Standard_String_Operations.Full_Upper_Length (Source);
   end Full_Upper_Length;

   function To_Lower (Source : String_Type) return String_Type
   with SPARK_Mode => Off
   is
   begin
      return Standard_String_Operations.To_Lower (Source);
   end To_Lower;

   function To_Upper (Source : String_Type) return String_Type
   with SPARK_Mode => Off
   is
   begin
      return Standard_String_Operations.To_Upper (Source);
   end To_Upper;

   function Simple_To_Lower (Source : String_Type) return String_Type
     with SPARK_Mode => Off
   is
   begin
      return Standard_String_Operations.Simple_To_Lower (Source);
   end Simple_To_Lower;

   procedure Append (Source : in out String_Type; New_Item : String_Type) is
   begin
      Source := Source & New_Item;
   end Append;

end String_Types;
